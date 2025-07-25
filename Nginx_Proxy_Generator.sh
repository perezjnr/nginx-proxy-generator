#!/bin/bash
# Nginx Proxy Generator Script by Perez Jnr O. 2024
# Tested on Ubuntu 24.04 LTS but should work on other Debian-based systems
# This script generates Nginx configuration file for proxying requests to an internal web server. 
# Useful for setting up reverse proxy for web applications running on different ports or servers behind a DMZ and or firewall.

display_info() {
    cat <<EOF 
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
The script checks if Nginx is installed and if the Nginx sites-available directory exists.
If Nginx is installed, the script checks for the Nginx version and displays it.
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
    3. The script also sets the necessary proxy headers for the Nginx server block.
    4. The configuration file is named after the domain name provided by the user (e.g., example.com.conf).
    5. The script checks for Nginx syntax errors using the `nginx -t` command.
    6. If the configuration file is valid, the script creates a symbolic link to the configuration file in the sites-enabled directory.
    7. If the configuration file is invalid, the script displays an error message and exits.
    8. The script also prompts the user to generate an SSL certificate for the domain using Certbot.
    9. If the user agrees, the script generates a self-signed SSL certificate and private key.
    10. If the user does not agree, the script skips the SSL certificate generation step.
    11. The script also provides an option to remove an existing Nginx website configuration.

# The script lists the current websites configured in Nginx and prompts the user to select a website to remove.
If the user selects a website to remove, the script disables the site by removing the symbolic link
from the sites-enabled directory and deletes the configuration file from the sites-available directory.

# The script then reloads the Nginx service to apply the changes.

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



# Set default listen port if not provided
listen_port=${listen_port:-80}
nginx_sites=/etc/nginx/sites-available/  # Nginx sites-available directory
# Check if Nginx is installed and sites-available directory exists


# Function to check if the script is run as a sudoer
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo "This script must be run as root. Please run with sudo permissions."
        exit 1
    fi
}

# Run the sudo check
#check_sudo

usage() {
cat <<EOF
"Usage: $0 [options]"
Options:
  -a, --add       Add a new website
  -r, --remove    Remove an existing website
  -h, --help      Display this help message
  -i, --info      Display information about the script
  -v, --version   Display current Nginx version
  -s, --sites-available Display current Nginx sites-available directory
  -e, --sites-enabled Display current Nginx sites-enabled directory
  -a, --add       Add a new website
EOF
}

#menu_options options
menu_options() {
    echo "Menu:"
    echo "1. Add a new website"
    echo "2. Remove an existing website"
    echo "3. Display usage information"
    echo "4. Display script information"
    echo "5. Display current Nginx version"
    echo "6. Display current Nginx sites-available directory"
    echo "7. Display current Nginx sites-enabled directory"
    echo "8. Exit"
}

# Function to display the menu and handle user input
diplay_menu(){
while true; do
        menu_options
        read -rp "Enter your choice (1-8): " choice

        case $choice in
            1)
                add_nginx_website
                break
                ;;
            2)
                remove_nginx_website
                break
                ;;
            3)
                usage
                continue
                ;;
            4)
                display_info 
                continue           
                ;;
            5)
                display_nginx_version  
                continue              
                ;;
            6)
                display_nginx_sites_available 
                continue               
                ;;
            7)
                display_nginx_sites_enabled 
                continue               
                ;;
            8)
                echo "Exiting..."
                exit 0
                break
                ;;
            *)
                echo "Invalid choice. Please enter 1 or 8."
                read -p "Enter your choice (1 or 8): " choice
                ;;
        esac
    done
}

# Function to prompt user to add or remove a website
manage_nginx_websites()  {
    if [[ $# -eq 0 ]]; then
        echo "Displaying Menu..."
    diplay_menu
else
    while [[ "$1" != "" ]]; do
    
        case $1 in
            -a | --add )
                add_nginx_website
                exit
                ;;
            -r | --remove )
                remove_nginx_website
                exit
                ;;
            -h | --help )
                usage
                exit
                ;;

            -i | --info )
                display_info
                exit
                ;;
            -v | --version )
                display_nginx_version
                exit
                ;;
            -s | --sites-available )
                display_nginx_sites_available
                exit
                ;;
            -e | --sites-enabled )
                display_nginx_sites_enabled
                exit
                ;;
            * )
                usage
                exit
                ;;
        esac
        shift
    done
fi

}

# Function to display current Nginx sites-available directory
display_nginx_sites_available() {
    echo "Current Nginx sites-available directory: $nginx_sites"
    echo "List of available sites:"
    if [ -d "$nginx_sites" ]; then
        ls "$nginx_sites"
    else
        echo "Nginx sites-available directory does not exist. Please create it first."
        exit 1
    fi
}

# Function to display current Nginx version
display_nginx_version() {
    if command -v nginx > /dev/null 2>&1; then
        nginx_version=$(nginx -v 2>&1)
        echo "Current Nginx version: $nginx_version"
    else
        echo "Nginx is not installed. Please install Nginx to use this script."
        exit 1
    fi
}

#Display enabled Nginx Sites
display_nginx_sites_enabled() {
    echo "Current Nginx sites-enabled directory: /etc/nginx/sites-enabled/"
    echo "List of enabled sites:"
    ls /etc/nginx/sites-enabled/
}

# Function to add a new website
add_nginx_website() {
    prompt_user_input
    create_nginx_config
    generate_ssl_certificate
    restart_nginx
}

# Function: checks
# Description: This function performs various checks required for the script to run correctly.
# It ensures that all necessary conditions and dependencies are met before proceeding.
checks() {
        # Check if Nginx is installed
    if command -v nginx > /dev/null 2>&1; then
        nginx_version=$(nginx -v 2>&1)
        echo "Nginx is installed: $nginx_version"
    else
        echo "Nginx is not installed. Do you want to install Nginx? (y/n)"
        read install_nginx
        if [ "$install_nginx" == "y" ]; then
            apt-get update
            apt-get install nginx -y
        else
            echo "Nginx is required for this script to work. Exiting..."
            exit 1
        fi
    fi
    # Check if Nginx sites-available directory exists
    if [ ! -d "$nginx_sites" ]; then
        echo "Nginx sites-available directory does not exist. Do you want to create it? (y/n)"
        read create_sites_available
        if [ "$create_sites_available" == "y" ]; then
            mkdir -p "$nginx_sites"
        else
            echo "Nginx sites-available directory is required for this script to work. Exiting..."
            exit 1
        fi
    fi
}

# Function to prompt for user input
prompt_user_input() {
    # Prompt for user input
    read -p "Enter origin web server listen port (press enter for default HTTP (80)): " listen_port
    if [ -z "$listen_port" ]; then
        # Default listen port
        listen_port=80
    fi
    read -p "Enter domain name- 'e.g example.com www.example.com': " domain_name
    if [ -z "$domain_name" ]; then
        echo "Domain name cannot be empty. Exiting..."
        exit 1
    fi
    # IP address or FQDN of internal web server
    read -p "Enter Internal web server IP address: " proxy_pass_ip
    retry_count=0
    # Validate IP address or FQDN of internal web server and prompt for input if invalid or empty until valid input is provided or retry count is reached
    while [ -z "$proxy_pass_ip" ] || [[ ! "$proxy_pass_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && [[ ! "$proxy_pass_ip" =~ ^[a-zA-Z0-9.-]+$ ]]; do
        if [ $retry_count -ge 2 ]; then
            echo "Invalid IP address or domain name. Exiting..."
            exit 1
        fi
        echo "Proxy pass IP/FQDN address is empty or invalid. Please try again."
        read -p "Enter Internal web server IP address: " proxy_pass_ip
        retry_count=$((retry_count + 1))
    done
    if [[ ! "$proxy_pass_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && [[ ! "$proxy_pass_ip" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        echo "Invalid IP address or domain name. Exiting..."
        exit 1
    fi
    read -p "Is internal web server in http or https? (1 for http, 2 for https): " proxy_pass_scheme
    if [ -z "$proxy_pass_scheme" ]; then
        echo "Scheme cannot be empty. Exiting..."
        exit 1
    fi  # Set proxy pass scheme based on user input (1 for http, 2 for https)
    if [ "$proxy_pass_scheme" == "1" ]; then
        if [ "$listen_port" -ne 80 ] && [ "$listen_port" -ne 443 ]; then
            proxy_pass_ip="http://$proxy_pass_ip:$listen_port"
        else
            proxy_pass_ip="http://$proxy_pass_ip"
        fi
    elif [ "$proxy_pass_scheme" == "2" ]; then
        if [ "$listen_port" -ne 80 ] && [ "$listen_port" -ne 443 ]; then
            proxy_pass_ip="https://$proxy_pass_ip:$listen_port"
        else
            proxy_pass_ip="https://$proxy_pass_ip"
        fi
    else
        echo "Invalid scheme. Exiting..."
        exit 1
    fi
}

# Create Nginx configuration file
create_nginx_config() {
    # Create Nginx configuration file
    cat > $nginx_sites/${domain_name}.conf <<EOF
    server {
        listen 80;
        server_name $domain_name;

        location / {
            proxy_pass $proxy_pass_ip;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
EOF
# Check if configuration file is created successfully
    if [ -d /$nginx_sites ]; then
        echo "Configuration file generated as '${domain_name}.conf' and saved in "
    else
        echo "Error generating configuration file. Exiting..."
        exit 1
    fi
    # Check for Nginx syntax errors
    nginx -t
    if [ $? -eq 0 ]; then

        link_nginx_config
        echo "Nginx configuration is valid. Restarting Nginx..."
        systemctl restart nginx
        if [ $? -eq 0 ]; then
            echo "Nginx restarted successfully."
        else
            echo "Failed to restart Nginx. Please check the Nginx logs for more details."
            exit 1
        fi
    else
        nginx -t 2>&1 | grep "nginx: \[emerg\]"
        echo "Nginx configuration is invalid. Please check the configuration file for errors."
        exit 1
    fi
}

# Create symbolic link for Nginx configuration file
link_nginx_config() {
    if [ ! -L /etc/nginx/sites-enabled/${domain_name}.conf ]; then
        echo "Creating symbolic link for /etc/nginx/sites-enabled/${domain_name}.conf"
        ln -s $nginx_sites/${domain_name}.conf /etc/nginx/sites-enabled/
    else
        echo "Symbolic link already exists for /etc/nginx/sites-enabled/${domain_name}.conf"
    fi
    if [ $? -eq 0 ]; then
        echo "Configuration file symbolic link created."
    else
        echo "Failed to create symbolic link for configuration file. Exiting..."
        exit 1
    fi
}

# Generates an SSL certificate for the Nginx proxy.
# This function creates a self-signed SSL certificate and private key.
# The generated certificate and key are stored in the specified directory.
# Usage:
#   generate_ssl_certificate <domain> <output_directory>
# Arguments:
#   domain: The domain name for which the SSL certificate is generated.
#   output_directory: The directory where the certificate and key will be saved.
generate_ssl_certificate() {
    read -p "Do you want to generate SSL certificate for this domain? (y/n): " ssl_cert

    if [ "$ssl_cert" == "y" ]; then
        echo "Generating SSL certificate for $domain_name"
        cerbot_check
        read -p "Do you want to wait to verify DNS configuration before generating the certificate? (y/n): " wait_dns
        echo "Waiting for 1 minute before requesting SSL certificate..."
        if [ "$wait_dns" == "y" ]; then
            read -p "Enter the number of seconds to wait: " wait_seconds
            if [[ "$wait_seconds" =~ ^[0-9]+$ ]]; then
                echo "Waiting for $wait_seconds seconds to verify DNS configuration..."
                while [ $wait_seconds -gt 0 ]; do
                    echo -ne "$wait_seconds\033[0K\r"
                    sleep 1
                    : $((wait_seconds--))
                done
            else
                echo "Invalid input. Exiting..."
                exit 1
            fi
        fi

        if [ -d "/etc/letsencrypt/live/$domain_name" ]; then
            echo "SSL certificate already exists for $domain_name."
            echo "Reinstalling SSL certificate for $domain_name..."
            certbot --nginx --reinstall -d $domain_name
            if [ $? -eq 0 ]; then
                echo "SSL certificate reinstalled successfully."
            else
                echo "Failed to reinstall SSL certificate. Please check the Certbot logs for more details."
                exit 1
            fi
            exit 0
        else
            echo "No existing SSL certificate found for $domain_name. Proceeding to generate a new one..."
        fi
        certbot --nginx -d $domain_name
        if [ $? -eq 0 ]; then
            echo "SSL certificate generated successfully."
        else
            echo "Failed to generate SSL certificate. Please check the Certbot logs for more details."
            exit 1
        fi
    fi
}

# Check if Certbot is installed and install Certbot if not installed and user agrees to install it
cerbot_check() {
    if command -v certbot > /dev/null 2>&1; then
        echo "Certbot is installed"
    else
        echo "Certbot is not installed. Do you want to install Certbot? (y/n)"
        read install_certbot
        if [ "$install_certbot" == "y" ]; then
            apt-get update
            apt-get install certbot python3-certbot-nginx -y
        else
            echo "Certbot is required for this script to work. Exiting..."
            exit 1
        fi
    fi
}

# This function removes an existing Nginx website configuration.
# It takes the website's domain name as an argument, disables the site,
# removes the configuration file, and reloads the Nginx service to apply changes.
remove_nginx_website() {
    # List current websites
    echo "Current websites:"
    websites=($(ls $nginx_sites | sed 's/.conf//'))
    for i in "${!websites[@]}"; do
        echo "$((i+1)). ${websites[$i]}"
    done

    # Prompt user to enter the number of the website to delete
    read -p "Enter the number of the website you want to remove: " website_number
    if ! [[ "$website_number" =~ ^[0-9]+$ ]] || [ "$website_number" -le 0 ] || [ "$website_number" -gt "${#websites[@]}" ]; then
        echo "Invalid number. Exiting..."
        exit 1
    fi

    remove_domain_name=${websites[$((website_number-1))]}

    # Confirm with user
    read -p "Are you sure you want to remove the website '$remove_domain_name'? (Y/N): " confirm
    if [[ "$confirm" != "Y" && "$confirm" != "y" ]]; then
        echo "Operation cancelled. Exiting..."
        exit 1
    fi

    # Remove configuration file
    if [ -f "$nginx_sites/${remove_domain_name}.conf" ]; then
        rm "$nginx_sites/${remove_domain_name}.conf"
        echo "Removed configuration file for $remove_domain_name"
    else
        echo "Configuration file for $remove_domain_name does not exist."
    fi

    # Remove symbolic link
    if [ -L "/etc/nginx/sites-enabled/${remove_domain_name}.conf" ]; then
        rm "/etc/nginx/sites-enabled/${remove_domain_name}.conf"
        echo "Removed symbolic link for $remove_domain_name"
    else
        echo "Symbolic link for $remove_domain_name does not exist."
    fi
    restart_nginx
}

restart_nginx(){
        # Restart Nginx
    echo "Restarting Nginx..."
    systemctl restart nginx
    if [ $? -eq 0 ]; then
        echo "Nginx restarted successfully."
    else
        echo "Failed to restart Nginx. Please check the Nginx logs for more details."
        exit 1
    fi
}

# Run the sudo check
check_sudo
# check dependencies
checks
# Run the manage websites flow
manage_nginx_websites "$@"
