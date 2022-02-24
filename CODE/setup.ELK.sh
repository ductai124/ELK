#! /bin/bash

source ./setup.conf.sh

echo "Kiểm tra máy chủ"
if systemctl is-active --quiet elasticsearch; then
    echo "elasticsearch Đã được cài đặt, Không đạt yêu cầu..."
    exit
fi
if systemctl is-active --quiet kibana; then
    echo "Kibana Đã được cài đặt, Không đạt yêu cầu..."
    exit
fi
if systemctl is-active --quiet logstash; then
    echo "logstash Đã được cài đặt, Không đạt yêu cầu..."
    exit
fi

echo "Máy chủ đạt yêu cầu để cài đặt ELK"


echo "Update và cài đặt java"
yum update -y
yum install java-1.8.0-openjdk-devel -y

echo "thêm repo cho elasticsreach"
echo '[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
' > /etc/yum.repos.d/elasticsearch.repo

echo "Cài đặt ELK"
yum install elasticsearch -y
yum install kibana -y
yum install logstash -y

echo "Cấu hình cho elasticsearch"
systemctl enable elasticsearch.service
systemctl start elasticsearch.service

echo "Cấu hình cho kibana"
echo 'server.host: 0.0.0.0' >> /etc/kibana/kibana.yml

echo "Cấu hình cho logstash"
echo "cấu hình để nó nhân đầu vào do Beats gửi đến cổng beats"
echo 'input {
  beats {
    host => "0.0.0.0"
    port => 5044
  }
}' > /etc/logstash/conf.d/02-beats-input.conf

echo "Cấu hình sau khi Logstash nhận dữ liệu đầu vào từ Beats, nó xử lý rồi gửi đến Elasticsearch"

echo 'output {
  elasticsearch {
    hosts => ["localhost:9200"]
    manage_template => false
    index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
  }
}' > /etc/logstash/conf.d/30-elasticsearch-output.conf

echo "Định dạng lại các dòng log ở dạng dễ đọc, dễ hiểu hơn thì cấu hình định dạng lại cấu trúc system log, lấy theo hướng dẫn tại document của Logstash"

echo 'filter {
  if [fileset][module] == "system" {
    if [fileset][name] == "auth" {
      grok {
        match => { "message" => ["%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} sshd(?:\[%{POSINT:[system][auth][pid]}\])?: %{DATA:[system][auth][ssh][event]} %{DATA:[system][auth][ssh][method]} for (invalid user )?%{DATA:[system][auth][user]} from %{IPORHOST:[system][auth][ssh][ip]} port %{NUMBER:[system][auth][ssh][port]} ssh2(: %{GREEDYDATA:[system][auth][ssh][signature]})?",
                  "%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} sshd(?:\[%{POSINT:[system][auth][pid]}\])?: %{DATA:[system][auth][ssh][event]} user %{DATA:[system][auth][user]} from %{IPORHOST:[system][auth][ssh][ip]}",
                  "%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} sshd(?:\[%{POSINT:[system][auth][pid]}\])?: Did not receive identification string from %{IPORHOST:[system][auth][ssh][dropped_ip]}",
                  "%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} sudo(?:\[%{POSINT:[system][auth][pid]}\])?: \s*%{DATA:[system][auth][user]} :( %{DATA:[system][auth][sudo][error]} ;)? TTY=%{DATA:[system][auth][sudo][tty]} ; PWD=%{DATA:[system][auth][sudo][pwd]} ; USER=%{DATA:[system][auth][sudo][user]} ; COMMAND=%{GREEDYDATA:[system][auth][sudo][command]}",
                  "%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} groupadd(?:\[%{POSINT:[system][auth][pid]}\])?: new group: name=%{DATA:system.auth.groupadd.name}, GID=%{NUMBER:system.auth.groupadd.gid}",
                  "%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} useradd(?:\[%{POSINT:[system][auth][pid]}\])?: new user: name=%{DATA:[system][auth][user][add][name]}, UID=%{NUMBER:[system][auth][user][add][uid]}, GID=%{NUMBER:[system][auth][user][add][gid]}, home=%{DATA:[system][auth][user][add][home]}, shell=%{DATA:[system][auth][user][add][shell]}$",
                  "%{SYSLOGTIMESTAMP:[system][auth][timestamp]} %{SYSLOGHOST:[system][auth][hostname]} %{DATA:[system][auth][program]}(?:\[%{POSINT:[system][auth][pid]}\])?: %{GREEDYMULTILINE:[system][auth][message]}"] }
        pattern_definitions => {
          "GREEDYMULTILINE"=> "(.|\n)*"
        }
        remove_field => "message"
      }
      date {
        match => [ "[system][auth][timestamp]", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
      }
      geoip {
        source => "[system][auth][ssh][ip]"
        target => "[system][auth][ssh][geoip]"
      }
    }
    else if [fileset][name] == "syslog" {
      grok {
        match => { "message" => ["%{SYSLOGTIMESTAMP:[system][syslog][timestamp]} %{SYSLOGHOST:[system][syslog][hostname]} %{DATA:[system][syslog][program]}(?:\[%{POSINT:[system][syslog][pid]}\])?: %{GREEDYMULTILINE:[system][syslog][message]}"] }
        pattern_definitions => { "GREEDYMULTILINE" => "(.|\n)*" }
        remove_field => "message"
      }
      date {
        match => [ "[system][syslog][timestamp]", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
      }
    }
  }
}
' > /etc/logstash/conf.d/10-syslog-filter.conf

echo "Kiểm tra"
sudo -u logstash /usr/share/logstash/bin/logstash --path.settings /etc/logstash -t
echo "Cấu hình tường lửa"

dnf install firewalld -y
systemctl enable firewalld.service
systemctl start firewalld.service

echo "Tạo zone dịch vụ"
firewall-cmd --permanent --new-zone=dichvu
echo "Mở cổng cho dịch vụ elasticsearch"
firewall-cmd --zone=dichvu --add-port=9200/tcp --permanent
echo "Mở cổng cho dịch vụ kibana"
firewall-cmd --zone=dichvu --add-port=5601/tcp --permanent
echo "Mở cổng cho dịch vụ logstash"
firewall-cmd --zone=dichvu --add-port=5044/tcp --permanent
echo "add source cho máy người dùng và máy sử dụng filebeat thu tập log"
firewall-cmd --zone=dichvu --add-source="$ip_user" --permanent
firewall-cmd --zone=dichvu --add-source="$ip_filebeat" --permanent
firewall-cmd --reload
echo "Hoàn tất thiết lập Firewall"

echo "Khởi động toàn bộ các dịch vụ ELK"
systemctl enable logstash
systemctl start logstash
systemctl enable kibana
systemctl start kibana
systemctl enable elasticsearch.service
systemctl start elasticsearch.service

exit 0
