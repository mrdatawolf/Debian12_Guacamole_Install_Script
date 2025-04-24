#!/bin/bash

# Check if the script is running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# Check for DNS resolution
if ! nslookup google.com > /dev/null 2>&1; then
  echo "DNS resolution failed. Please check your network settings." >&2
  exit 1
fi

# Check for internet connectivity
if ! ping -c 1 8.8.8.8 > /dev/null 2>&1; then
  echo "Internet connectivity check failed. Please ensure you are connected to the internet." >&2
  exit 1
fi

# Install wget
if ! apt update; then
  echo "apt update failed. Please check your sources list and try again." >&2
  exit 1
fi

if ! apt install -y wget; then
  echo "apt install wget failed. Please check your network connection and try again." >&2
  exit 1
fi

# Download the scripts from the GitHub repository
if ! wget -O initial_debian_setup.sh https://raw.githubusercontent.com/mrdatawolf/Debian12_Guacamole_Install_Script/main/initial_debian_setup.sh; then
  echo "Failed to download initial_debian_setup.sh. Please check the URL and try again." >&2
  exit 1
fi

if ! wget -O d12_guac_install.sh https://raw.githubusercontent.com/mrdatawolf/Debian12_Guacamole_Install_Script/main/d12_guac_install.sh; then
  echo "Failed to download d12_guac_install.sh. Please check the URL and try again." >&2
  exit 1
fi

# Make the scripts executable
chmod +x initial_debian_setup.sh
chmod +x d12_guac_install.sh

# Run the scripts in order and log output
./initial_debian_setup.sh | tee initial_debian_setup.log
./d12_guac_install.sh | tee d12_guac_install.log

rm -f initial_debian_setup.sh d12_guac_install.sh

if [[ "$*" == *"--allowLogin"* ]]; then
  # Download the file from GitHub
  if ! wget -O allow_login_script.sh https://raw.githubusercontent.com/yourusername/yourrepo/main/allow_login_script.sh; then
    echo "Failed to download allow_login_script.sh. Please check the URL and try again." >&2
    exit 1
  fi
  chmod +x allow_login_script.sh
  ./allow_login_script.sh | tee allow_login_script.log
  rm -f allow_login_script.sh

  echo "Allow login script executed successfully. Log is available in allow_login_script.log."
fi

echo "Scripts executed successfully. Logs are available in initial_debian_setup.log and d12_guac_install.log."

