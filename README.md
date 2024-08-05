# multi_proxy_ipv6
Tạo hàng loạt proxy ipv6 từ 1 ipv4. Chú ý: Các trang web không phân giải được ipv6 sẽ không truy cập được qua proxy ipv6

## Yêu cầu
- Centos
- Ipv6 \64

## các bước thực hiện

- bước 1:
chạy lệnh : ip link show
- bước 2:
lấy interface thay vào interface trong code:
- bước 3:
chạy lệnh: sudo nano /usr/local/bin/setup_squid_ipv6_auth.sh ( tạo file setup_squid_ipv6_auth.sh)
- bước 4:
dán nội dung file install.sh vào setup_squid_ipv6_auth.sh -> ctrl+o -> enter -> ctrl+x
- bước 5: chạy lệnh cấp quyền thực thi script
sudo chmod +x /usr/local/bin/setup_squid_ipv6_auth.sh
-bước 6: chạy script
sudo /usr/local/bin/setup_squid_ipv6_auth.sh

