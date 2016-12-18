require 'packetfu'
require './ouis.rb'
include PacketFu

def get_capture(iface)
  cap = Capture.new(iface: iface, start: true)
  cap.stream.each do |pkt|
    time = Time.now.strftime("%Y-%m-%d %H:%M:%S.%6N")

    if UDPPacket.can_parse?(pkt)
      udp_packet = UDPPacket.parse(pkt)
      src_ip = IPHeader.octet_array(udp_packet.ip_src).join('.')
      dst_ip = IPHeader.octet_array(udp_packet.ip_dst).join('.')
      src_port = udp_packet.udp_src
      dst_port = udp_packet.udp_dst
      src_mac, dst_mac, vendor_name = get_common_values(udp_packet)
      puts "time:#{time}, src_mac:#{src_mac}, dst_mac:#{dst_mac}, src_ip:#{src_ip}, dst_ip:#{dst_ip}, src_port:#{src_port}, dst_port:#{dst_port}, protocol:udp, vendor: #{vendor_name}"
      next
    end

    if ARPPacket.can_parse?(pkt)
      arp_packet = ARPPacket.parse(pkt)
      src_ip = arp_packet.arp_saddr_ip
      dst_ip = arp_packet.arp_daddr_ip
      src_mac, dst_mac, vendor_name = get_common_values(arp_packet)
      puts "time:#{time}, src_mac:#{src_mac}, dst_mac:#{dst_mac}, src_ip:#{src_ip}, dst_ip:#{dst_ip}, protocol:arp, vendor: #{vendor_name}"
    end
  end
end

def get_common_values(packet)
  src_mac = EthHeader.str2mac(packet.eth_src)
  dst_mac = EthHeader.str2mac(packet.eth_dst)
  vendor_name = get_vendor_name(src_mac)
  return src_mac, dst_mac, vendor_name
end

def get_vendor_name(mac)
  oui = mac.split(':').slice(0, 3).join('-')
  OUIS[oui.upcase]
end

if $0 == __FILE__
  iface = ARGV[0]
  puts "Capturing for interface: #{iface}"
  get_capture(iface)
end
