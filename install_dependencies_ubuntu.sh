#!/bin/bash

echo "Installing dependencies for Sinkhole..."

# Update and install system packages
sudo apt update
sudo apt install -y python3 python3-pip python3-venv iptables openssl mysql-server libssl-dev build-essential python3-pymysql python3-openssl

# Upgrade pip and setuptools
python3 -m pip install --upgrade pip setuptools

# Confirm pymysql is installed
python3 -c "import pymysql; print('pymysql installed successfully.')"

echo "All dependencies installed successfully."
