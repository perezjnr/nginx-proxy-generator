# Nginx Proxy Generator Script

A lightweight Bash script for generating Nginx reverse proxy configuration files without the overhead of full UI-based solutions.

This script was created to provide more **direct control over Nginx reverse proxy configuration**, especially for users who prefer or require CLI-driven workflows. While tools like **Nginx Proxy Manager** offer a great web interface, this script focuses on direct file manipulation and scripting flexibility. The long-term goal is to also offer a web interface that complements the CLI by writing and editing configuration files directly.

---

## 🚀 Features

- Interactive menu-based or CLI usage
- Create or remove Nginx proxy site configurations
- Displays current Nginx version and directories
- Performs syntax validation on config before enabling
- Automatically restarts Nginx if changes are applied
- Works well for self-hosted apps behind firewalls, DMZs, or internal networks

---
## ✅ Prerequisites

- Tested on **Ubuntu 24.04 LTS**, but compatible with other Debian-based systems.
- **Nginx**.

To install Nginx:
## How It Works

- The script checks if Nginx is installed and if the `sites-available` directory exists.
- If Nginx is not installed, the script prompts the user to install it.
- If the `sites-available` directory does not exist, the script prompts the user to create it.
- The script creates an Nginx configuration file with the user input and checks for Nginx syntax errors.
- If the configuration file is valid, the script links the configuration file to the `sites-enabled` directory and restarts Nginx.
- The script displays a success message if Nginx is restarted successfully.
- Existing files will be overwritten with the new configuration file.

# Menu
## Menu Items
1. Add a new website"
2. Remove an existing website"
3. Display usage information"
4. Display script information"
5. Display current Nginx version"
6. Display current Nginx sites-available directory"
7. Display current Nginx sites-enabled directory"
8. Exit"
## CLI Options
- -a, --add       Add a new website
- -r, --remove    Remove an existing website
- -h, --help      Display this help message
- -i, --info      Display information about the script
- -v, --version   Display current Nginx version
- -s, --sites-available Display current Nginx sites-available directory
- -e, --sites-enabled Display current Nginx sites-enabled directory
- -a, --add       Add a new website
# Execution of Script
1. Ensure the script has execute permissions:
    ```sh
    sudo chmod +x Nginx_Proxy_Generator.sh
    ```
3. Run the script:
   Display menu
    ```sh
    sudo ./Nginx_Proxy_Generator.sh
    ```
   Add new website
   ```sh
   sudo ./Nginx_Proxy_Generator.sh -a
   ```
4. Follow the prompts to provide the necessary information:
    - Listen port (default is 80)
    - Domain name
    - Internal web server IP address
