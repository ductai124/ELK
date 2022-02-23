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

# TÀI LIỆU HƯỚNG DẪN CÀI ĐĂT 1 MÔ HÌNH HỆ THỐNG ELK (Elasticsearch logstash kibana)
## Người viết : Phạm Đức Tài
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
* Chuẩn bị 2 máy 1 máy chứa 
  * Elasticsearch, Logstash, Kibana với ip là 192.168.1.11 
  * 1 máy chứa Beats với ip là 192.168.1.12

## 2.	Tiến hành cài đặt
* Việc đầu tiên ở tất cả các máy chúng ta sẽ tiến hành tắt SELINUX, tải các gói wget, unzip (tải kho code về máy) và reboot lại hệ thống
```php
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/sysconfig/selinux
sed -i 's/\(^SELINUX=\).*/\SELINUX=disabled/' /etc/selinux/config
yum -y install wget unzip

reboot
```
## ***Tải kho code và cấu hình trước khi tiến hành thiết lập các thông số trên toàn bộ các máy***
```php
#Để tải kho code về, ta dùng wget và làm như sau:

wget https://github.com/ductai124/ELK/CODE/main.zip

unzip  main.zip

#Sau đó chúng ta tiếp tục cd vào thư mục như sau:

cd /ELK/CODE 

#Hãy truy cập vào file config có tên là setup.conf.sh và điền đúng ip dải ip theo máy của mình
#Như mô hình trên thì file config sẽ được cấu hình như sau
#Hãy sửa file setup.conf.sh theo như các máy của mình
#LƯU Ý: File config này sẽ được dùng cho tất cả các máy
vi setup.conf.sh

#! /bin/bash

ip_ELK="192.168.1.11"
ip_user="192.168.1.2"
ip_filebeat="192.168.1.12"

```
* ### ***Lưu ý:*** file config trên ở tất cả các máy sẽ phải giống nhau nếu không sẽ dẫn đến việc cài đặt sai
* Sau khi đã thiết lập xong các thông số thì sẽ đến bước tiếp theo

## ***Sau đó ta sẽ tiến hành cài đặt bắt đầu từ có IP 192.168.1.11 đầu tiên***
# Sau đó ta tiến hành cài đặt
```php
#Truy cập vào thư mục sau
cd ELK/CODE/ 

#Trước khi cài đặt hãy chắc chắn rằng file setup.conf.sh của các máy được thiết lập các thông số giống nhau

#Phân quyền
chmod 777 setup*

#Chạy tools cài đặt
bash setup.ELK.sh
```

## ***Tiếp theo sẽ tiến hành cài đặt máy có IP 192.168.1.12*** (đảm bảo rằng máy đã cài đặt mariadb từ trước)
```php
#Truy cập vào thư mục sau
cd ELK/CODE/ 

#Trước khi cài đặt hãy chắc chắn r file setup.conf.sh của các máy được thiết lập các thông số giống nhau

#Phân quyền 
chmod 777 setup*

#Chạy tools cài đặt
bash setup.filebeat.sh
```

