#!/bin/bash
# Nginx Proxy Generator Script by Perez Jnr O. 2024
# Tested on Ubuntu 24.04 LTS but should work on other Debian-based systems
# This script generates Nginx configuration file for proxying requests to an internal web server. 
# Useful for setting up reverse proxy for web applications running on different ports or servers behind a DMZ and or firewall.

echo "Nginx Proxy Generator"
echo "This script generates Nginx configuration file for proxying requests to an internal web server."
echo "The script prompts for user input for listen port, domain name, and internal web server IP address."
echo "The script checks if Nginx is installed and if the Nginx sites-available directory exists."
echo "If Nginx is not installed, the script prompts the user to install Nginx."
echo "If the Nginx sites-available directory does not exist, the script prompts the user to create it."
echo "The script creates an Nginx configuration file with the user input and checks for Nginx syntax errors."
echo "If the configuration file is valid, the script links the configuration file to the sites-enabled directory and restarts Nginx."
echo "The script displays a success message if Nginx is restarted successfully."
echo "Existing file will be overwritten with new configuration file."

# Set default listen port if not provided
listen_port=${listen_port:-80}
nginx_sites=/etc/nginx/sites-available/  # Nginx sites-available directory
# Check if Nginx is installed and sites-available directory exists
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

checks
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

create_nginx_config

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

# Generate SSL certificate for the domain if user agrees to generate it and Certbot is installed on 
# the system and user agrees to install it if not installed on the system and user agrees to install it if not installed on the system 
generate_ssl_certificate
