#!/bin/bash
# Squid proxy startup script for GCP VM

set -e

PROXY_PORT=${proxy_port:-3128}

echo "Installing Squid proxy..."

# Update system
apt-get update
apt-get install -y squid

# Backup original config
cp /etc/squid/squid.conf /etc/squid/squid.conf.backup

# Configure Squid
cat > /etc/squid/squid.conf <<EOF
# Squid configuration for firewall-restricted environment
# Port configuration
http_port ${PROXY_PORT}

# ACL definitions
acl localnet src 10.0.0.0/8
acl localnet src 172.16.0.0/12
acl localnet src 192.168.0.0/16

# SSL ports
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777

# Allow local network
http_access allow localnet

# Deny unsafe ports
http_access deny !Safe_ports

# Deny CONNECT to non-SSL ports
http_access deny CONNECT !SSL_ports

# Allow all other traffic (proxy will forward)
http_access allow all

# Cache configuration (minimal for proxy-only)
cache_dir ufs /var/spool/squid 100 16 256
coredump_dir /var/spool/squid

# Logging
access_log /var/log/squid/access.log squid
cache_log /var/log/squid/cache.log

# Refresh patterns (allow caching)
refresh_pattern . 0 20% 4320 override-expire override-lastmod reload-into-ims
EOF

# Create cache directory
mkdir -p /var/spool/squid
chown proxy:proxy /var/spool/squid
squid -z

# Enable and start Squid
systemctl enable squid
systemctl restart squid

# Verify Squid is running
systemctl status squid

echo "Squid proxy installed and configured on port ${PROXY_PORT}"
echo "Proxy is accessible at: http://$(hostname -I | awk '{print $1}'):${PROXY_PORT}"

