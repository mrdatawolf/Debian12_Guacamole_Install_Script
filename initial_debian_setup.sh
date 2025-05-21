#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi
LOG_FILE="/var/log/setup_network.log"
exec > >(tee -a "$LOG_FILE") 2>&1

# Function to validate IP address format
validate_ip() {
  local ip=$1
  local valid_regex="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
  if [[ $ip =~ $valid_regex ]]; then
    IFS='.' read -r -a octets <<< "$ip"
    for octet in "${octets[@]}"; do
      if ((octet < 0 || octet > 255)); then
        return 1
      fi
    done
    return 0
  else
    return 1
  fi
}

# Prompt and validate user input
while true; do
  read -p "Enter the static IP address for the main interface (e.g., 192.168.1.100): " static_ip
  validate_ip "$static_ip" && break || echo "Invalid IP format. Try again."
done

while true; do
  read -p "Enter the netmask for the main interface (e.g., 255.255.255.0): " netmask
  validate_ip "$netmask" && break || echo "Invalid netmask format. Try again."
done

while true; do
  read -p "Enter the gateway address (e.g., 192.168.1.1): " gateway
  validate_ip "$gateway" && break || echo "Invalid gateway format. Try again."
done

read -p "Enter the primary user to grant sudo access: " primary_user

# Detect the first network interface listed in /etc/network/interfaces
interface=$(grep -m 1 'allow-hotplug' /etc/network/interfaces | awk '{print $2}')
echo "Detected interface: $interface"

# Install essential packages
echo "Updating and installing packages..."
apt-get update && apt-get upgrade -y && apt-get install -y sudo vim curl

# Add the user to the sudo group
echo "Adding $primary_user to sudo group..."
usermod -aG sudo "$primary_user"

# Speed up GRUB boot time
echo "Updating GRUB timeout..."
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/' /etc/default/grub
update-grub

# Backup the current interfaces file
echo "Backing up /etc/network/interfaces..."
cp /etc/network/interfaces /etc/network/interfaces.bak

# Write new network configuration
echo "Writing new network configuration..."
cat <<EOF > /etc/network/interfaces
# Main interface with static IP
auto $interface
allow-hotplug $interface
iface $interface inet static
 address $static_ip
 netmask $netmask
 gateway $gateway

# Virtual interface with secondary static IP
auto ${interface}:1
allow-hotplug ${interface}:1
iface ${interface}:1 inet static
 address 10.92.92.4
 netmask 255.255.255.0
EOF

# Update /etc/issue with network info
echo "Updating /etc/issue..."
cat <<EOF > /etc/issue
Debian - Biztech - Remote X
    Access IP: \4{$static_ip}
    Management IP: 10.92.92.4
    Guacamole: \4{$static_ip}:8080
EOF

echo "Setup complete. Log saved to $LOG_FILE"
# Uncomment to apply changes immediately
# systemctl restart networking
