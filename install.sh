#!/bin/bash

# Biến cấu hình
interface="enp0s3"
base_ip="2001:db8:abcd::"
port=3128

# Cập nhật hệ thống
echo "Updating system..."
sudo yum update -y

# Cài đặt Squid
echo "Installing Squid..."
sudo yum install squid -y

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
http_access allow all

# Cấu hình cổng proxy
EOL

for i in {1..50}; do
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
    curl -x [${base_ip}${i}]:${port} http://ifconfig.co
done

echo "Setup complete."
