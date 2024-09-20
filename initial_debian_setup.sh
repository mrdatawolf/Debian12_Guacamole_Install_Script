#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Prompt the user for the static IP address, gateway, and primary user
read -p "Enter the static IP address (e.g., 192.168.1.100): " static_ip
read -p "Enter the gateway address (e.g., 192.168.1.1): " gateway
read -p "Enter primary user to have sudo: " primary_user

# Find the first allow-hotplug line and extract the interface name
interface=$(grep -m 1 'allow-hotplug' /etc/network/interfaces | awk '{print $2}')

apt-get update && apt-get upgrade -y && apt-get install -y sudo vim curl

usermod -aG sudo "$primary_user"

sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/' /etc/default/grub
update-grub

new_config=$(cat <<EOF
# The primary network interface
allow-hotplug $interface
iface $interface inet dhcp

# if you are doing static assignment
allow-hotplug $interface
iface $interface inet static
 address $static_ip
 netmask 255.255.255.0
 gateway $gateway

auto ${interface}:1
allow-hotplug ${interface}:1
iface ${interface}:1 inet static
 address 10.92.92.4
 netmask 255.255.255.0
EOF
)

new_issue=$(cat << EOF
Debian - Biztech - Remote X
    Access IP: \4{$interface}
Management IP: \4{$interface:1}
    Guacamole: \4{$interface}:8080
EOF
)

cp /etc/network/interfaces /etc/network/interfaces.bak

echo "$new_config" > /etc/network/interfaces
echo "$new_issue" > /etc/issue

#systemctl restart networking
