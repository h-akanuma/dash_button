require 'packetfu'
require 'open3'
require 'json'
include PacketFu

FILTER = nil
MAC_OF_DASH = 'Dash Button の MACアドレス'
SLACK_API_URL = 'Slack Incoming Webhook URL'
INTERVAL_MICRO_SECONDS = 2_000_000

@last_processed_time = 0

def get_capture(iface)
  cap = Capture.new(iface: iface, filter: FILTER, start: true)
  cap.stream.each do |pkt|
    next if !ARPPacket.can_parse?(pkt) && !UDPPacket.can_parse?(pkt)

    packet = Packet.parse(pkt)
    next if EthHeader.str2mac(packet.eth_src) != MAC_OF_DASH
    next if !past_since_last_processed?

    post_to_slack
    @last_processed_time = current_unixtime_with_micro_seconds

    t_stamp = Time.now.strftime("%Y-%m-%d %H:%M:%S.%6N")
    puts "#{t_stamp} Posted to Slack."
  end
end

def current_unixtime_with_micro_seconds
  now = Time.now
  "#{now.to_i}#{now.usec}".to_i
end

def past_since_last_processed?
  current_unixtime_with_micro_seconds - @last_processed_time >= INTERVAL_MICRO_SECONDS
end

def post_to_slack
  api_url = SLACK_API_URL
  payload = {
    channel:    '#akanuma_private',
    username:   'dash',
    icon_emoji: ':squirrel:',
    text:       'Hello World from Dash Button!!'
  }
  command = "curl -X POST --data-urlencode 'payload=#{payload.to_json}' #{api_url}"
  puts command
  output, std_error, status = Open3.capture3(command)
  puts output
  puts std_error
  puts status
end

if $0 == __FILE__
  iface = ARGV[0]
  puts "Capturing for interface: #{iface}"
  get_capture(iface)
end
