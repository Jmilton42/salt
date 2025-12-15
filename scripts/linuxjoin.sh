#!/bin/bash

# Configuration
JOIN_USER="Administrator"
JOIN_PASSWORD="machine-PLACE-4!"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo "Starting domain join process..."

# 1. Get the primary IP address and extract the 3rd octet
# We use 'hostname -I' to get IPs, take the first one, and cut the 3rd field.
IP_ADDR=$(hostname -I | awk '{print $1}')
THIRD_OCTET=$(echo "$IP_ADDR" | cut -d. -f3)

if [ -z "$THIRD_OCTET" ]; then
    echo "Error: Could not determine IP address or 3rd octet."
    exit 1
fi

DOMAIN="MACHINE.PLACE${THIRD_OCTET}"
DNS_SERVER="192.168.${THIRD_OCTET}.86"

echo "Detected IP: $IP_ADDR"
echo "Derived Domain: $DOMAIN"
echo "Derived DNS Server: $DNS_SERVER"

# 2. Configure DNS
# Using resolvectl (systemd-resolved) which is standard on modern Ubuntu
echo "Configuring DNS..."
INTERFACE=$(ip route get 8.8.8.8 | awk -- '{print $5}')

if [ -z "$INTERFACE" ]; then
    echo "Error: Could not determine primary network interface."
    exit 1
fi

# Set the DNS server for the interface
resolvectl dns "$INTERFACE" "$DNS_SERVER"
# Set the domain for the interface
resolvectl domain "$INTERFACE" "$DOMAIN"
resolvectl flush-caches "$INTERFACE"

echo "DNS configured on interface $INTERFACE."
echo "Debug: Current resolvectl status:"
resolvectl status "$INTERFACE"

# 3. Install Dependencies
echo "Installing dependencies..."
apt-get update -q
apt-get install -y realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin packagekit ntpdate krb5-user

# ... (DNS and Hosts config remains the same) ...

# 4. Join Domain
echo "Joining domain $DOMAIN..."

# Function to ensure SSSD is running
ensure_sssd_running() {
    echo "Ensuring SSSD is configured and running..."
    if [ -f /etc/sssd/sssd.conf ]; then
        chmod 600 /etc/sssd/sssd.conf
        chown root:root /etc/sssd/sssd.conf
    fi
    
    # Unmask just in case
    systemctl unmask sssd
    systemctl enable sssd
    systemctl restart sssd
    
    if systemctl is-active --quiet sssd; then
        echo "SSSD started successfully."
    else
        echo "Error: SSSD failed to start."
        systemctl status sssd --no-pager
        # Don't exit here, we want to allow troubleshooting
    fi
}

# Check if already joined
if realm list | grep -iq "$DOMAIN"; then
    echo "Machine is already joined to $DOMAIN."
    # Even if joined, ensure SSSD is actually running (fix for 'inactive' state)
    ensure_sssd_running
    exit 0
fi

# Pipe the password to realm join
# We add --install=/ to prevent package install prompts if they were causing issues, though we installed deps already.
echo "$JOIN_PASSWORD" | realm join --user="$JOIN_USER" "$DOMAIN" --verbose --install=/

JOIN_RET=$?

if [ $JOIN_RET -eq 0 ]; then
    echo "Successfully joined $DOMAIN."
    
    # Optional: Configure automatic home directory creation
    if ! grep -q "pam_mkhomedir.so" /etc/pam.d/common-session; then
        echo "session required pam_mkhomedir.so skel=/etc/skel/ umask=0077" >> /etc/pam.d/common-session
        echo "Configured automatic home directory creation."
    fi
    
    ensure_sssd_running
else
    echo "Failed to join domain (Exit Code: $JOIN_RET)."
    # Sometimes realm fails but writes config. Check if we are partially joined.
    if realm list | grep -iq "$DOMAIN"; then
        echo "Partial join detected. Attempting to fix SSSD..."
        ensure_sssd_running
    else
        exit 1
    fi
fi

echo "Done."

