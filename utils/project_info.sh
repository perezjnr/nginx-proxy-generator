display_info() {
    cat <<-EOF
####################################################################
# Nginx Proxy Generator Script
# Version: 1.0
# Author: PeeJay O.
# Date: 2025
# License: MIT License
# Description: 
This script generates Nginx configuration files for proxying requests to an internal web server.
It allows you to add or remove websites easily and provides options for SSL certificate generation.
The script is designed to be run on Debian-based systems (e.g., Ubuntu) and requires sudo permissions to run.
####################################################################

# NGINX Installation Check:
If Nginx is installed and if the Nginx sites-available directory exists.
If Nginx is installed,for the Nginx version and displays it.
If Nginx is not installed, the script prompts the user to install Nginx.
If the Nginx sites-available directory does not exist, the script prompts the user to create it.
####################################################################

# Usage:
    To run the script, use the following command:
    ./Nginx_Proxy_Generator.sh [options]
    # Options:
    -a, --add       Add a new website
    -r, --remove    Remove an existing website
    -h, --help      Display this help message
####################################################################

# Sript Functionality:
    The script prompts the user for input to add a new website configuration.
    It collects the following information:
    - Origin web server listen port (default is 80)
    - Domain name (e.g., example.com www.example.com)
    - Internal web server IP address or FQDN
    - Scheme of the internal web server (HTTP or HTTPS)

    - The script validates the user input for the internal web server IP address or FQDN.
    - If the input is invalid or empty, it prompts the user to re-enter the information up to two times.
    - If the user input is still invalid after two attempts, the script exits with an error message.
    - The script also checks if the listen port is valid and sets the proxy pass URL accordingly.

# The script creates an Nginx configuration file in the sites-available directory.
    1. The configuration file includes the server block with the specified listen port, domain name, and proxy pass URL.
    2. The proxy pass URL is constructed based on the user input for the internal web server IP address or FQDN and the scheme (HTTP or HTTPS).
    3. Sets the necessary proxy headers for the Nginx server block.
    4. The configuration file is named after the domain name provided by the user (e.g., example.com.conf).
    5. Check for Nginx syntax errors using the 'nginx -t' command.
    6. If the configuration file is valid, the script creates a symbolic link to the configuration file in the sites-enabled directory.
    7. If the configuration file is invalid, the script displays an error message and exits.
    8. The script also prompts the user to generate an SSL certificate for the domain using Certbot.
    9. If the user agrees, the script generates a self-signed SSL certificate and private key.
    10. If the user does not agree, the script skips the SSL certificate generation step.
    11. The script also provides an option to remove an existing Nginx website configuration.

# The script lists the current websites configured in Nginx and prompts the user to select a website to remove.
If the user selects a website to remove, the script disables the site by removing the symbolic link
from the sites-enabled directory and deletes the configuration file from the sites-available directory.

# Reloads the Nginx service to apply the changes.

####################################################################
# Note:
This script is intended for use on Debian-based systems (e.g., Ubuntu).
It requires sudo permissions to run.
Make sure to run the script with sudo or as root user.
####################################################################
# Example:
To add a new website configuration, run the script with the -a or --add option:
./Nginx_Proxy_Generator.sh -a
To remove an existing website configuration, run the script with the -r or --remove option:
./Nginx_Proxy_Generator.sh -r
# To display the help message, run the script with the -h or --help option:
./Nginx_Proxy_Generator.sh -h
####################################################################
# This script is provided as-is and is not guaranteed to work in all environments.
# Use it at your own risk. It is recommended to test the script in a safe environment
# before using it in production.
#################################################################### 
EOF
}
