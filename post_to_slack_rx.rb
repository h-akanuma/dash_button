require 'packetfu'
require 'open3'
require 'json'
require 'rx'
include PacketFu

FILTER = nil
MAC_OF_DASH = 'Dash Button の MACアドレス'
SLACK_API_URL = 'Slack Incoming Webhook URL'
INTERVAL_SECONDS = 2

class Rx::BehaviorSubject
  public :check_unsubscribed
end

def get_capture(iface)
  subject = Rx::BehaviorSubject.new('')
  subject.select {|pkt| target_dash_pushed?(pkt) }.debounce(INTERVAL_SECONDS).subscribe(
    lambda {|pkt| post_to_slack },
    lambda {|err| puts "Error: #{err}" },
    lambda { puts 'Completed.' }
  )

  cap = Capture.new(iface: iface, filter: FILTER, start: true)
  cap.stream.each do |pkt|
    subject.on_next pkt
  end
end

def target_dash_pushed?(pkt)
  return false unless EthPacket.can_parse?(pkt)
  EthHeader.str2mac(EthPacket.parse(pkt).eth_src) == MAC_OF_DASH
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

  t_stamp = Time.now.strftime("%Y-%m-%d %H:%M:%S.%6N")
  puts "#{t_stamp} Posted to Slack."
end

if $0 == __FILE__
  iface = ARGV[0]
  puts "Capturing for interface: #{iface}"
  get_capture(iface)
end
