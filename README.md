# dash_button

Amazon Dash Button が押された時に色々処理をさせるのを試すためのリポジトリです。

### Amazon Dash Button の MACアドレスを確認する

capture.rb でLAN内のパケットをキャプチャすることでMACアドレスを確認できます。

```bash
$ sudo ruby capture.rb en0 | grep -i amazon
/Users/akanuma/workspace/dash_button/ouis.rb:8296: warning: key "00-01-C8" is duplicated and overwritten on line 8309
/Users/akanuma/workspace/dash_button/ouis.rb:12779: warning: key "08-00-30" is duplicated and overwritten on line 17381
/Users/akanuma/workspace/dash_button/ouis.rb:12779: warning: key "08-00-30" is duplicated and overwritten on line 22049
time:2016-12-17 20:52:06.677957, src_mac:88:71:e5:f0:89:71, dst_mac:ff:ff:ff:ff:ff:ff, src_ip:0.0.0.0, dst_ip:255.255.255.255, src_port:68, dst_port:67, protocol:udp, vendor: Amazon Technologies Inc.
time:2016-12-17 20:52:06.689735, src_mac:88:71:e5:f0:89:71, dst_mac:ff:ff:ff:ff:ff:ff, src_ip:192.168.10.10, dst_ip:192.168.10.1, protocol:arp, vendor: Amazon Technologies Inc.
```

### Dash Button が押されたら Slack にポストする

post_to_slack.rb でパケットをキャプチャしてSlackにポストします。

```bash
$ sudo ruby post_to_slack.rb en0
Capturing for interface: en0
curl -X POST --data-urlencode 'payload={"channel":"#akanuma_private","username":"dash","icon_emoji":":squirrel:","text":"Hello World from Dash Button!!"}' https://hooks.slack.com/services/XXXXXXXXXXX
ok
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   192  100     2  100   190      4    409 --:--:-- --:--:-- --:--:--   409
pid 53526 exit 0
2016-12-17 21:26:54.018919 Posted to Slack.
```
