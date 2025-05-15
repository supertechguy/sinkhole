
#!/bin/bash

echo "Sinkhole Installer"

INSTALL_DIR="/opt/sinkhole"
SERVICE_FILE="/etc/systemd/system/sinkhole.service"
MYSQL_SCRIPT="mysql_setup.sql"

# Create install directory
sudo mkdir -p $INSTALL_DIR
sudo cp -r * $INSTALL_DIR
cd $INSTALL_DIR

# Ask user if they want a new certificate
read -p "Do you want to generate a new self-signed certificate? (y/n): " gen_cert

if [[ "$gen_cert" == "y" || "$gen_cert" == "Y" ]]; then
    echo "Generating new certificate..."
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
        -keyout key.pem -out cert.pem \
        -subj "/C=US/ST=Sinkhole/L=Trap/O=Sinkhole/CN=sinkhole.local"
else
    echo "Using existing certificate."
fi

# MySQL setup
echo "Setting up MySQL database..."
sudo mysql < $MYSQL_SCRIPT

# Install iptables script
sudo chmod +x iptables_setup.sh

# Setup systemd service
echo "Installing systemd service..."
sudo cp sinkhole.service $SERVICE_FILE
sudo systemctl daemon-reexec
sudo systemctl enable sinkhole
sudo systemctl start sinkhole

echo "Sinkhole installation complete."
