
#!/bin/bash

echo "Installing dependencies for Sinkhole..."

# Update system
sudo apt update

# Install required packages
sudo apt install -y python3 python3-pip python3-venv iptables openssl mysql-server libssl-dev build-essential

# Install Python dependencies
pip3 install pymysql pyOpenSSL

echo "All dependencies installed successfully."
