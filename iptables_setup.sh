
#!/bin/bash

# Flush old rules
iptables -t nat -F

# Allow SSH through
iptables -t nat -A PREROUTING -p tcp --dport 22 -j ACCEPT

# Redirect all external TCP to 4433 except localhost, SSH, and MySQL
iptables -t nat -A PREROUTING -p tcp ! -s 127.0.0.1 --dport 1:65535 ! --dport 22 ! --dport 3306 -j REDIRECT --to-port 4433

# Redirect all external UDP to 4433 except localhost
iptables -t nat -A PREROUTING -p udp ! -s 127.0.0.1 --dport 1:65535 -j REDIRECT --to-port 4433
