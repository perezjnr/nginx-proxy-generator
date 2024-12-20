#!/bin/bash
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
    if [ ! -d $nginx_sites ]; then
        echo "Nginx sites-available directory does not exist. Do you want to create it? (y/n)"
        read create_sites_available
        if [ $create_sites_available == "y" ]; then
            mkdir -p $nginx_sites
        else
            echo "Nginx sites-available directory is required for this script to work. Exiting..."
            exit 1
        fi
    fi
}

checks
# Prompt for user input
read -p "Enter listen port (press enter for default HTTP (80)): " listen_port
if [ -z "$listen_port" ]; then
    # Default listen port
    listen_port=80
fi
read -p "Enter domain name- 'e.g example.com www.example.com': " domain_name
if [ -z "$domain_name" ]; then
    echo "Domain name cannot be empty. Exiting..."
    exit 1
fi
read -p "Enter Internal web server IP address: " proxy_pass_ip
if [ -z "$proxy_pass_ip" ]; then
    echo "Proxy pass IP address cannot be empty. Exiting..."
    exit 1
fi

# Set default listen port if not provided
listen_port=${listen_port:-80}
nginx_sites=/etc/nginx/sites-available  # Nginx sites-available directory

# Create Nginx configuration file
create_nginx_config() {
    # Create Nginx configuration file
    cat > $nginx_sites/${domain_name}.conf <<EOF
    server {
        listen $listen_port;
        server_name $domain_name;

        location / {
            proxy_pass http://$proxy_pass_ip;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
EOF
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
        echo "Nginx configuration is invalid. Please check the configuration file for errors."
        exit 1
    fi
}
link_nginx_config() {
    ln -s $nginx_sites/${domain_name}.conf /etc/nginx/sites-enabled/
    if [ $? -eq 0 ]; then
        echo "Configuration file linked successfully."
    else
        echo "Failed to link configuration file. Exiting..."
        exit 1
    fi
}
create_nginx_config

read -p "DO you want to generate ssl certificate for this domain? (y/n): " ssl_cert

if [ "$ssl_cert" == "y" ]; then
    echo "Generating SSL certificate for $domain_name"
    cerbot_check
    echo "Waiting for 2 minutes before requesting SSL certificate..."
    sleep 120
    certbot --nginx -d $domain_name
    if [ $? -eq 0 ]; then
        echo "SSL certificate generated successfully."
    else
        echo "Failed to generate SSL certificate. Please check the Certbot logs for more details."
        exit 1
    fi
fi
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