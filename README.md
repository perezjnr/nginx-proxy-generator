# Nginx Proxy Generator Script

This script generates an Nginx configuration file for proxying requests to an internal web server. It is useful for setting up a reverse proxy for web applications running on different ports or servers behind a DMZ and/or firewall.

## Prerequisites

- Tested on Ubuntu 24.04 LTS but should work on other Debian-based systems.
- Nginx must be installed on the system.

## Usage

1. Ensure the script has execute permissions:
    ```sh
    chmod +x Nginx_Proxy_Generator.sh
    ```

2. Run the script:
    ```sh
    ./Nginx_Proxy_Generator.sh
    ```

3. Follow the prompts to provide the necessary information:
    - Listen port (default is 80)
    - Domain name
    - Internal web server IP address

## How It Works

- The script checks if Nginx is installed and if the `sites-available` directory exists.
- If Nginx is not installed, the script prompts the user to install it.
- If the `sites-available` directory does not exist, the script prompts the user to create it.
- The script creates an Nginx configuration file with the user input and checks for Nginx syntax errors.
- If the configuration file is valid, the script links the configuration file to the `sites-enabled` directory and restarts Nginx.
- The script displays a success message if Nginx is restarted successfully.
- Existing files will be overwritten with the new configuration file.
