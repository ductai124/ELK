<!--
# h1
## h2
### h3
#### h4
##### h5
###### h6

*in nghiêng*

**bôi đậm**

***vừa in nghiêng vừa bôi đậm***

`inlide code`

```php

echo ("highlight code");

```

[Link test](https://viblo.asia/helps/cach-su-dung-markdown-bxjvZYnwkJZ)

![markdown](https://images.viblo.asia/518eea86-f0bd-45c9-bf38-d5cb119e947d.png)

* mục 3
* mục 2
* mục 1

1. item 1
2. item 2
3. item 3

***
horizonal rules

> text

{@youtube: https://www.youtube.com/watch?v=HndN6P9ke6U}
* Cài đặt nginx bằng câu lệnh sau
```php
dnf -y install nginx
```
*	Cấu hình nginx như sau
```php
vi /etc/nginx/nginx.conf

 Server{
     ...
     server_name www.srv.world;
     ...
 }
 
-->

# TÀI LIỆU HƯỚNG DẪN CÀI ĐĂT MỘT  MÔ HÌNH HỆ THỐNG ELK (Elasticsearch logstash kibana)
## Người viết : Phạm Đức Tài, Phùng Công Việt Anh
## SDT : 0837686717
## Mail : phamductai123456@gmail.com

***
# Mục lục
[1. Giới thiệu mô hình](https://github.com/ductai124/ELK#1gi%E1%BB%9Bi-thi%E1%BB%87u-m%C3%B4-h%C3%ACnh)

[2. Tiến hành cài đặt](https://github.com/ductai124/ELK#2ti%E1%BA%BFn-h%C3%A0nh-c%C3%A0i-%C4%91%E1%BA%B7t)


***
## 1.	Giới thiệu mô hình
* Elastic Stack bao gồm:
    * Elasticsearch - máy chủ lưu trữ và tìm kiếm dữ liệu
    * Logstash - thành phần xử lý dữ liệu, sau đó nó gửi dữ liệu nhận được cho Elasticsearch để lưu trữ
    * Kibana - ứng dụng nền web để tìm kiếm và xem trực quan các logs
    * Beats - gửi dữ liệu thu thập từ log của máy đến Logstash
* Chuẩn bị 2 máy 1 máy chứa:
  * Elasticsearch, Logstash, Kibana với IP là 192.168.1.11 (tối thiểu 2gb RAM để mô hình chạy ổn định)
  * 1 máy chứa Beats với IP là 192.168.1.12 (chuẩn bị máy đã được cài đặt nginx, mariadb)
  * Nếu có nhiều máy thì chúng ta lặp lại quá trình trên
* Việc kiểm soát log là vô cùng quan trọng và để việc đó trở nên dễ dàng hơn thì mô hình ELK là giải pháp cho việc kiểm soát log nhanh chóng và dễ dàng

## 2.	Tiến hành cài đặt
* Việc đầu tiên ở tất cả các máy chúng ta sẽ tiến hành tắt SELINUX, tải các gói wget, unzip (tải kho code về máy) và reboot lại hệ thống
```bash
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/sysconfig/selinux
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config
yum -y install wget unzip

reboot
```
## ***Tải kho code và cấu hình trước khi tiến hành thiết lập các thông số trên toàn bộ các máy***
```bash
#Để tải kho code về, ta dùng wget và làm như sau:
cd /root
wget https://github.com/ductai124/ELK/archive/refs/heads/main.zip

unzip  main.zip

#Sau đó chúng ta tiếp tục cd vào thư mục theo đường dẫn như sau:

cd /root/ELK-main/CODE

#Hãy truy cập vào file config có tên là setup.conf.sh và điền đúng ip dải ip theo máy của mình
#Hãy sửa file setup.conf.sh theo như các máy của mình
#LƯU Ý: File config này sẽ được dùng cho tất cả các máy
vi setup.conf.sh

#! /bin/bash

ip_ELK="192.168.1.11" (IP máy cài đặt ELK)
ip_user="192.168.1.2" (IP máy thật người dùng)
ip_filebeat="192.168.1.12" (IP máy cài đặt filebeat)

```
* ### ***Lưu ý:*** file config trên ở tất cả các máy sẽ phải giống nhau nếu không sẽ dẫn đến việc cài đặt sai
* Sau khi đã thiết lập xong các thông số thì sẽ đến bước tiếp theo

## ***Sau đó ta sẽ tiến hành cài đặt bắt đầu từ máy Elastic Stack (có IP 192.168.1.11) đầu tiên***
### Ta tiến hành cài đặt như sau:

```bash
#Truy cập vào thư mục sau theo đường dẫn:
cd /root/ELK-main/CODE

#Trước khi cài đặt hãy chắc chắn rằng file setup.conf.sh của các máy được thiết lập các thông số giống nhau

#Phân quyền
chmod 777 setup*

#Chạy tools cài đặt
bash setup.ELK.sh

#Kiểm tra đã hoàn tất cài đặt như sau:

systemctl status elasticsearch
systemctl status kibana
systemctl status logstash
```

## ***Tiếp theo sẽ tiến hành cài đặt máy Beats trên các webserrer có IP 192.168.1.12*** (nếu có nhiều webserver chúng ta sẽ phải lặp lại quá trình này cho các máy đó)

```bash
#Truy cập vào thư mục sau theo đường dẫn:
cd /root/ELK-main/CODE

#Trước khi cài đặt hãy chắc chắn rằng file setup.conf.sh của các máy được thiết lập các thông số giống nhau

#Phân quyền 
chmod 777 setup*

#Chạy tools cài đặt
bash setup.filebeat.sh

##Kiểm tra đã hoàn tất cài đặt như sau:
systemctl status filebeat

#Ta thiết lập các module tùy theo nhu cầu sử dụng
#Modules hệ thống
filebeat modules enable system
#Modules nginx
filebeat modules enable nginx
#Modules mysql
filebeat modules enable mysql
```

## ***Xem log trong kibana*** 

Đến đây bạn đã có một ELK (một trung tâm quản lý log), nó đang nhận log từ một server gửi đến bằng Filebeat (nếu muốn server khác gửi đến nữa thì cài Filebeat trên server nguồn và cấu hình như trên)

Truy cập vào Kibana theo địa chỉ IP của ELK, ví dụ http://192.168.1.11:5601, nhấn vào phần Discover, chọn mục Index Management của Elasticsearch, bạn sẽ thấy các index có tiền tố là filebeat-*, chính là các index lưu dữ liệu log do Filebeat gửi đến Logstash và Logstash để chuyển lưu tại Elasticsearch (nếu có nhiều server gửi đến thì có nhiều index dạng này)

Cuối cùng, bấm vào Discover để xem thông tin về các log. Mặc định đang liệt kê các log 15 phút cuối

## ***Setup mariadb slow log*** 
```bash
#Đăng nhập vào file conf của mariadb:
vi /etc/my.cnf

#Sau đó thêm các dòng lệnh như sau:
[mariadb]
slow_query_log
slow_query_log_file=mariadb-slow.log
slow_query_log_file=/var/log/mariadb-slow.log
log_output=FILE
long_query_time=1.0
log_queries_not_using_indexes=ON

```
## ***Cách kiểm tra log mariadb*** 
```bash
#Đầu tiên hãy đăng nhập vào mariadb, sau đó chạy các lệnh sau:

show variables like '%SLOW%';
SHOW GLOBAL VARIABLES LIKE 'slow\_%';
SELECT SLEEP(3);
SELECT SLEEP(4);

#Thoát mariadb, sau đó kiểm tra log như sau:

vi /var/log/mariadb-slow.log
```
