# Guacamole Installation Script for Debian 12 

This script automates the installation of Guacamole on Debian 12 using PostgreSQL. 

## First, thanks to MysticRyuujin for the version that works on Debian 11!!!
[Link to MysticRyuujin's Guac-Install](https://github.com/MysticRyuujin/guac-install)
```sh
wget -O guac-install.sh https://git.io/fxZq5; chmod +x guac-install.sh; sudo ./guac-install.sh
```

## Prerequisites 
- Debian 12 system
- Internet connection 

## Least Effort Usage 
1. **Download the script**:
   - [Download Script](https://raw.githubusercontent.com/mrdatawolf/Debian12_Guacamole_Install_Script/main/runme.sh)
   - Or use `wget`:
     ```sh
     wget https://raw.githubusercontent.com/mrdatawolf/Debian12_Guacamole_Install_Script/main/runme.sh
     ```
2. **Run the script** with elevated privileges:
   ```sh
   chmod +x ./runme.sh
   sudo ./runme.sh
   ```
3. Check if it worked by navigating to `http://<ip>:8080`.
   
## Just Guacamole Setup
1. Download the script:
- [Download Script](https://raw.githubusercontent.com/mrdatawolf/Debian12_Guacamole_Install_Script/main/d12_guac_install.sh?form=MG0AV3)
- Or use wget:
 ```sh
wget https://raw.githubusercontent.com/mrdatawolf/Debian12_Guacamole_Install_Script/main/d12_guac_install.sh
```
2. Run the script:
```sh
sudo ./d12_guac_install.sh
```
3. Check if it worked by navigating to `http://<ip>:8080`.

## ISO Setup
There are ongoing tests to integrate this script into the installation process, but it is not functional yet.

## Old Setup
1. Download the script:
- [Download Script](https://raw.githubusercontent.com/mrdatawolf/Debian12_Guacamole_Install_Script/main/d12_guac_install.sh?form=MG0AV3)
-Or use wget:
```sh
wget https://raw.githubusercontent.com/mrdatawolf/Debian12_Guacamole_Install_Script/main/d12_guac_install.sh
```
2. **Set the password**: Open the script in a text editor and set the PASSWORD variable to the desired password for the guacamole_user database user.
3. Make the script executable:
```sh
chmod +x d12_guacamole_install_p1.sh
```
4. Run the script with sudo:
```sh
sudo ./d12_guacamole_install_p1.sh
```

The script will automatically install all necessary packages, download and install Guacamole, configure it to use PostgreSQL, and set up a `guacamole_user` database user.

## Post-Installation
After the script has finished running, you should be able to access the Guacamole web interface by navigating to `http://your-server-address:8080/` in your web browser. The default username is `guacadmin` and the password is `guacadmin`.

## Troubleshooting
If you encounter any issues while running the script, check the following:

Ensure you're running the script with sudo.

Ensure your Debian system is up-to-date.

Check the output of the script for any error messages.

## License
This script is released under the MIT license. See [LICENSE](https://license/?form=MG0AV3) for more details.

<!-- INSTALL_COMMAND:  wget https://raw.githubusercontent.com/mrdatawolf/Debian12_Guacamole_Install_Script/main/runme.sh -->
<!-- RUN_COMMAND: sudo ./runme.sh -->
