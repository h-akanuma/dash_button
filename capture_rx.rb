require 'packetfu'
require 'rx'
require './ouis.rb'
include PacketFu

class Rx::BehaviorSubject
  public :check_unsubscribed
end

def get_capture(iface)
  subject = Rx::Subject.new
  subject.select {|pkt| dash_packet?(pkt) }.subscribe(
    lambda {|pkt| capture(pkt) },
    lambda {|err| puts "Error: #{err}" },
    lambda { puts 'Completed.' }
  )

  cap = Capture.new(iface: iface, start: true)
  cap.stream.each do |pkt|
    subject.on_next pkt
  end
end

def dash_packet?(pkt)
  return false unless EthPacket.can_parse?(pkt)
  get_vendor_name(EthHeader.str2mac(EthPacket.parse(pkt).eth_src)).downcase.include?('amazon')
end

def capture(pkt)
  time = Time.now.strftime("%Y-%m-%d %H:%M:%S.%6N")

  if UDPPacket.can_parse?(pkt)
    packet = UDPPacket.parse(pkt)
    src_ip = IPHeader.octet_array(packet.ip_src).join('.')
    dst_ip = IPHeader.octet_array(packet.ip_dst).join('.')
    protocol = 'udp'
  elsif ARPPacket.can_parse?(pkt)
    packet = ARPPacket.parse(pkt)
    src_ip = packet.arp_saddr_ip
    dst_ip = packet.arp_daddr_ip
    protocol = 'arp'
  else
    return
  end

  src_mac, dst_mac, vendor_name = get_common_values(packet)
  output(time, src_mac, dst_mac, src_ip, dst_ip, protocol, vendor_name)
end

def output(time, src_mac, dst_mac, src_ip, dst_ip, protocol, vendor_name)
  puts "time:#{time}, src_mac:#{src_mac}, dst_mac:#{dst_mac}, src_ip:#{src_ip}, dst_ip:#{dst_ip}, protocol:#{protocol}, vendor:#{vendor_name}"
end

def get_common_values(packet)
  src_mac = EthHeader.str2mac(packet.eth_src)
  dst_mac = EthHeader.str2mac(packet.eth_dst)
  vendor_name = get_vendor_name(src_mac)
  return src_mac, dst_mac, vendor_name
end

def get_vendor_name(mac)
  return '' if mac.nil?
  oui = mac.split(':').slice(0, 3).join('-')
  OUIS[oui.upcase]
end

if $0 == __FILE__
  iface = ARGV[0]
  puts "Capturing for interface: #{iface}"
  get_capture(iface)
end
