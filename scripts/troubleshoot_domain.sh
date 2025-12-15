#!/bin/bash

# troubleshoot_domain.sh
# Diagnoses common domain join and SSSD issues

echo "=== 1. IP and Hostname Info ==="
hostname -f
hostname -I
cat /etc/hosts

echo -e "\n=== 2. Realm Status ==="
realm list

echo -e "\n=== 4. SSSD Status ==="
systemctl status sssd --no-pager

echo -e "\n=== 4. Kerberos Ticket Info ==="
klist -k /etc/krb5.keytab

echo -e "\n=== 5. User Resolution Check ==="
# Calculate Domain
IP_ADDR=$(hostname -I | awk '{print $1}')
THIRD_OCTET=$(echo "$IP_ADDR" | cut -d. -f3)
DOMAIN="MACHINE.PLACE${THIRD_OCTET}"

echo "Checking for Administrator@$DOMAIN..."
id "Administrator@$DOMAIN" || echo "Failed to find Administrator"

echo "Checking for gabe@$DOMAIN..."
id "gabe@$DOMAIN" || echo "Failed to find gabe"

echo -e "\n=== 6. SSSD Config Check ==="
# Show config but hide password
grep -v "password" /etc/sssd/sssd.conf

echo -e "\n=== 7. NSSwitch Config ==="
grep "passwd" /etc/nsswitch.conf
grep "group" /etc/nsswitch.conf

echo -e "\n=== 8. Recent SSSD Logs ==="
tail -n 20 /var/log/sssd/sssd_$DOMAIN.log 2>/dev/null || echo "No domain log found"
tail -n 20 /var/log/sssd/sssd_nss.log 2>/dev/null || echo "No NSS log found"

