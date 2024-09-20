# Guacamole Installation Script for Debian 12

This script automates the installation of Guacamole on Debian 12 using PostgreSQL.

## Warning this does not work yet! (Thanks Sam)

## Prerequisites

- Debian 12 system.
- Internet connection.

## Usage

1. **Download the script**: You can download the script using wget or curl, or you can clone the repository where the script is located.
  - [Download Script](https://raw.githubusercontent.com/mrdatawolf/Debian12_Guacamole_Install_Script/main/d12_guac_install.sh)
  - Or wget https://raw.githubusercontent.com/mrdatawolf/Debian12_Guacamole_Install_Script/main/d12_guac_install.sh
3. **Set the password**: Open the script in a text editor and set the `PASSWORD` variable to the password you want to use for the `guacamole_user` database user.

4. **Make the script executable**: Run `chmod +x d12_guacamole_install_p1.sh` to make the script executable.

5. **Run the script**: Run the script with sudo: `sudo ./d12_guacamole_install_p1.sh`.

The script will automatically install all necessary packages, download and install Guacamole, configure Guacamole to use PostgreSQL, and set up a `guacamole_user` database user.

## Post-Installation

After the script has finished running, you should be able to access the Guacamole web interface by navigating to `http://your-server-address:8080/` in your web browser. The default username is `guacadmin` and the password is `guacadmin`.

## Troubleshooting

If you encounter any issues while running the script, check the following:

- Ensure you're running the script with sudo.
- Ensure your Debian system is up-to-date.
- Check the output of the script for any error messages.

## License

This script is released under the MIT license. See `LICENSE` for more details.
