#!/bin/bash

# Biến cấu hình
interface="enp0s3"
base_ip="2001:db8:abcd::"
start_port=3128
end_port=3177
username="proxyuser"
password="proxypassword"

# Cập nhật hệ thống
echo "Updating system..."
sudo yum update -y

# Cài đặt Squid
echo "Installing Squid..."
sudo yum install squid -y

# Cài đặt httpd-tools để sử dụng htpasswd
echo "Installing httpd-tools..."
sudo yum install httpd-tools -y

# Tạo tệp chứa thông tin người dùng
echo "Creating password file..."
sudo htpasswd -cb /etc/squid/passwd $username $password

# Thêm địa chỉ IPv6 vào giao diện mạng
echo "Adding IPv6 addresses to network interface..."
for i in {1..50}; do
    sudo ip -6 addr add ${base_ip}${i}/64 dev $interface
done

# Cấu hình Squid
echo "Configuring Squid..."
sudo tee /etc/squid/squid.conf > /dev/null <<EOL
# Default Squid configuration
http_access allow localhost
http_access deny all

# Cấu hình xác thực
auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic children 5
auth_param basic realm Proxy Authentication
auth_param basic credentialsttl 2 hours
auth_param basic casesensitive off
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
http_access deny all

# Cấu hình các cổng proxy
EOL

for i in {1..50}; do
    port=$((start_port + i - 1))
    echo "http_port [${base_ip}${i}]:${port}" | sudo tee -a /etc/squid/squid.conf
done

echo "acl localnet src ${base_ip}0/64" | sudo tee -a /etc/squid/squid.conf
echo "http_access allow localnet" | sudo tee -a /etc/squid/squid.conf
echo "http_access deny all" | sudo tee -a /etc/squid/squid.conf

# Khởi động lại dịch vụ Squid
echo "Restarting Squid service..."
sudo systemctl restart squid

# Kiểm tra trạng thái của Squid
echo "Checking Squid service status..."
sudo systemctl status squid

# Kiểm tra kết nối proxy
echo "Testing proxy connections..."
for i in {1..50}; do
    curl -x [${base_ip}${i}]:$((start_port + i - 1)) -U $username:$password http://ifconfig.co
done

echo "Setup complete."
