#!/bin/bash
# Load Configs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#source "$SCRIPT_DIR/config/colours.sh"
# Load Functions
for file in utils/*.sh checks/*.sh prompts/*.sh config/*.sh; do
    source "$SCRIPT_DIR/$file"
done

# Log file
LOG_FILE="/var/log/nginx_proxy_generator.log"

log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Dry-run mode
#DRY_RUN=false

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





# Function to check if the script is run as a sudoer
Prerequisites_checks() {
    echo -e "${GREY}Checking prerequisites...${NC}"
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED} This script must be run as root. Please run with sudo permissions.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Running as root user.${NC}"
    echo -e "${GREY}Checking if Nginx is installed...${NC}"
    check_nginx_installed
    echo -e "${GREY}Checking if Certbot is installed...${NC}"
    check_and_install_certbot
    echo -e "${GREY}Checking if Netcat (nc) is installed...${NC}"
    check_and_install_nc
    echo -e "${GREEN}Prerequisites checks completed successfully.${NC}"
}

detect_nginx_paths() {
    # Default for Debian/Ubuntu
    nginx_sites_available="/etc/nginx/sites-available"
    nginx_sites_enabled="/etc/nginx/sites-enabled"
    # Alpine
    if [ -f /etc/alpine-release ]; then
        nginx_sites_available="/etc/nginx/conf.d"
        nginx_sites_enabled="/etc/nginx/conf.d"

    # RHEL/CentOS/Fedora
    elif grep -qi 'centos\|rhel\|fedora' /etc/os-release 2>/dev/null; then
        nginx_sites_available="/etc/nginx/conf.d"
        nginx_sites_enabled="/etc/nginx/conf.d"

    # Arch Linux
    elif grep -qi 'arch' /etc/os-release 2>/dev/null; then
        nginx_sites_available="/etc/nginx/conf.d"
        nginx_sites_enabled="/etc/nginx/conf.d"
    fi

    echo -e "${GREEN}Using Nginx sites-available: $nginx_sites_available${NC}"
    echo -e "${GREEN}Using Nginx sites-enabled:   $nginx_sites_enabled${NC}"
}

show_usage() {
    echo -e "${YELLOW}Usage:${NC}"
    echo -e "  ./Nginx_Proxy_Generator.sh [options]"
    echo -e "Options:"
    echo -e "${GREEN}  -a, --add               Add a new website"
    echo -e "  -r, --remove            Remove an existing website"
    echo -e "  -h, --help              Display this help message"
    echo -e "  -i, --info              Display script info"
    echo -e "  -v, --version           Show current NGINX version"
    echo -e "  -s, --sites-available   Show NGINX sites-available path"
    echo -e "  -e, --sites-enabled     Show NGINX sites-enabled path"
    echo -e "  --dry-run               Simulate changes without applying them ${NC}"
}

#menu_options options
menu_options() {
    echo -e "${YELLOW}Menu:"
    echo -e "1. Add a new website"
    echo -e "2. Remove an existing website"
    echo -e "3. Display usage information"
    echo -e "4. Display script information"
    echo -e "5. Display current Nginx version"
    echo -e "6. Display current Nginx sites-available directory"
    echo -e "7. Display current Nginx sites-enabled directory"
    echo -e "8. Exit${NC}"
}

# Function to display the menu and handle user input
diplay_menu()
{
while true; do
        menu_options
        read -rp "$(echo -e "${GREEN}Enter your choice (1-8): ${NC}")" choice

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
                show_usage
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
                echo -e "${GREY}Exiting...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please enter 1-8.${NC}"
                ;;
        esac
    done
}

# Function to prompt user to add or remove a website
manage_nginx_websites()  {
    if [[ $# -eq 0 ]]; then
        echo -e "${GREY}Displaying Menu...${NC}"
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
                show_usage
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
                show_usage
                exit
                ;;
        esac
        #shift
    done
fi

}

# Function to display current Nginx sites-available directory
display_nginx_sites_available() {

    if [ -d "$NGINX_SITES_AVAILABLE" ]; then
        ls "$NGINX_SITES_AVAILABLE"
    else
        echo -e "${RED}Nginx sites-available directory does not exist. Please create it first.${NC}"
        exit 1
    fi
}

# Function to display current Nginx version
display_nginx_version() {
    if command -v nginx > /dev/null 2>&1; then
        nginx_version=$(nginx -v 2>&1)
        echo -e "${GREEN}Current Nginx version: $nginx_version${NC}"
    else
        echo -e "${RED}Nginx is not installed. Please install Nginx to use this script.${NC}"
        exit 1
    fi
}

#Display enabled Nginx Sites
display_nginx_sites_enabled() {
    echo -e "${YELLOW}Current Nginx sites-enabled directory: ${nginx_sites_enabled}${NC}"
    echo -e "${GREEN}List of enabled sites:${NC}"
    ls "$nginx_sites_enabled"
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
check_nginx_installed() {
        # Check if Nginx is installed
    if command -v nginx > /dev/null 2>&1; then
        nginx_version=$(nginx -v 2>&1)
        echo -e "${GREEN}$nginx_version${NC}"
    else
        echo -e "${RED}Nginx is not installed.${NC}"
        read -rp "Would you like to install it now? [Y/n]: " install_nginx
        if [ "$install_nginx" == "y" ]; then
            sudo apt update && sudo apt install -y nginx
        else
            echo -e "${RED}Nginx is required to continue.${NC}"
            exit 1
        fi
    fi

    # Check if Nginx sites-available directory exists
    echo -e "${GREY}Detecting Nginx paths...${NC}"

    detect_nginx_paths

    if [ ! -d "$nginx_sites_available" ]; then
        echo -e "${YELLOW}Nginx sites-available directory does not exist.${NC} Do you want to create it? (y/n)"

        read -rp "$(echo -e "${GREEN}Create Nginx sites-available directory? (y/n): ${NC}")" create_sites_available
        if [ "$create_sites_available" == "y" ]; then
            mkdir -p "$nginx_sites_available"
        else
            echo -e "${RED}Nginx sites-available directory is required for this script to work.${NC} Exiting..."
            exit 1
        fi
    fi
}

prompt_domain_name() {
    echo -e "${GREY}If domain DNS has not been configured, please do so before continuing.${NC}"

    local retry_count=0
    local max_retries=5

    while (( retry_count < max_retries )); do
        read -rp "$(echo -e "${GREEN}Enter (FQDN) domain name to be used for website (e.g. example.com, www.example.com): ${NC}")" domain_name
        domain_name="${domain_name,,}"  # lowercase
        echo -e "${GREY}Using domain name: $domain_name${NC}"
        if [[ -z "$domain_name" ]]; then
            echo -e "${RED}Domain name cannot be empty.${NC}"
        elif [[ ! "$domain_name" =~ ^([a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$ ]]; then
            echo -e "${RED}Invalid domain format. Must be like example.com or sub.domain.org.${NC}"
            ((retry_count++))
            continue
        else

            # Check Nginx config existence
            if [[ -z "$nginx_sites_available" || ! -d "$nginx_sites_available" ]]; then
                echo -e "${RED}Nginx sites-available directory is not set or does not exist. Exiting...${NC}"
                exit 1
            fi

            local config_path="$nginx_sites_available/${domain_name}.conf"
            if [[ -f "$config_path" ]]; then
                echo -e "${YELLOW}Domain config already exists: $config_path${NC}"
                read -rp "$(echo -e "${GREEN}Do you want to overwrite it? (y/n): ${NC}")" overwrite
                if [[ "$overwrite" != "y" ]]; then
                    echo -e "${YELLOW}You chose not to overwrite. Try again with a different domain.${NC}"
                    ((retry_count++))
                    continue
                else
                    echo -e "${YELLOW}Overwriting existing configuration...${NC}"
                    rm -f "$config_path"
                fi
            fi

            # Domain accepted
            return 0
        fi

        ((retry_count++))
    done

    echo -e "${RED}Too many invalid attempts. Exiting...${NC}"
    exit 1
}



prompt_proxy_scheme() {
    # Set proxy pass scheme based on user input (1 for http, 2 for https)
    read -rp "$(echo -e "${GREEN}Is origin/host server setup for http or https? (1 for http, 2 for https): ${NC}")" proxy_pass_scheme
    if [ -z "$proxy_pass_scheme" ]; then
        echo -e "${RED}Scheme cannot be empty. Exiting...${NC}"
        exit 1
    fi 
    if [ "$proxy_pass_scheme" == "1" ]; then
        if [ "$LISTEN_PORT" -ne 80 ] && [ "$LISTEN_PORT" -ne 443 ]; then
            echo -e "${GREY}Using custom port $LISTEN_PORT for HTTP.${NC}"
            PROXY_PASS_IP="http://$PROXY_PASS_IP:$LISTEN_PORT"
        else
            echo -e "${GREY}Using default port 80 for HTTP.${NC}"
            PROXY_PASS_IP="http://$PROXY_PASS_IP"
        fi
    elif [ "$proxy_pass_scheme" == "2" ]; then
        if [ "$LISTEN_PORT" -ne 80 ] && [ "$LISTEN_PORT" -ne 443 ]; then
            echo -e "${GREY}Using custom port $LISTEN_PORT for HTTPS.${NC}"
            PROXY_PASS_IP="https://$PROXY_PASS_IP:$LISTEN_PORT"
        else
            echo -e "${GREY}Using default port 443 for HTTPS.${NC}"
            PROXY_PASS_IP="https://$PROXY_PASS_IP"

        fi
    else
        echo -e "${RED}Invalid scheme. Exiting...${NC}"
        exit 1
    fi
}

prompt_server_port() {
    # Prompt for user input
while true; do
    read -rp "$(echo -e "${GREEN}Enter origin/host web server listen port (press enter for default HTTP (80)):${NC}")" LISTEN_PORT
    if [[ -z "$LISTEN_PORT" ]]; then
        LISTEN_PORT=80
        break
    elif [[ "$LISTEN_PORT" =~ ^[0-9]+$ ]]; then
        break
    else
        echo -e "${RED}Invalid input. Please enter a numeric value only.${NC}"
    fi
done
    # Check if the port is valid
    if [[ "$LISTEN_PORT" -lt 1 || "$LISTEN_PORT" -gt 65535 ]]; then
        echo -e "${RED}Invalid port number. Please enter a value between 1 and 65535.${NC}"
        prompt_server_port
    else
        echo -e "${GREY}Origin/Host server listen port: $LISTEN_PORT${NC}"
    fi
}

# Function to prompt for user input
prompt_user_input() {

    prompt_server_port
    prompt_domain_name
    prompt_ip_address
    prompt_proxy_scheme

}

# Create Nginx configuration file
create_nginx_config() {
    # Create Nginx configuration file
    cat > $nginx_sites_available/"${domain_name}".conf <<EOF
    server {
        listen 80;
        server_name $domain_name;

        location / {
            proxy_pass $PROXY_PASS_IP;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
EOF
# Check if configuration file is created successfully
    if [ -d /$nginx_sites_available ]; then
        echo -e "${GREEN} Configuration file generated as '${domain_name}.conf' and saved in ${nginx_sites_available}.${NC}"
    else
        echo -e "${RED}Error generating configuration file. Exiting...${NC}"
        exit 1
    fi
    # Check for Nginx syntax errors

    if nginx -t -c "$nginx_sites_available"; then

        link_nginx_config
        echo -e "${GREY}Nginx configuration is valid. Restarting Nginx...${NC}"
        if systemctl restart nginx; then
            echo -e "${GREEN}Nginx restarted successfully.${NC}"
        else
            echo -e "${RED}Failed to restart Nginx. Please check the Nginx logs for more details.${NC}"
            exit 1
        fi
    else
        nginx -t 2>&1 | grep "nginx: \[emerg\]"
        echo -e "${RED}Nginx configuration is invalid. Please check the configuration file for errors.${NC}"
        exit 1
    fi
}

# Create symbolic link for Nginx configuration file
link_nginx_config() {
    if [ ! -L "${nginx_sites_enabled}/${domain_name}.conf" ]; then
        echo -e "${GREY}Creating symbolic link for ${nginx_sites_enabled}/${domain_name}.conf${NC}"
        if ln -s "$nginx_sites_available/${domain_name}.conf" "${nginx_sites_enabled}/${domain_name}.conf"; then
            echo -e "${GREEN}Configuration file symbolic link created.${NC}"
        else
            echo -e "${RED}Failed to create symbolic link for configuration file. Exiting...${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Symbolic link already exists for ${nginx_sites_enabled}/${domain_name}.conf${NC}"
    fi
}

detect_certbot_live_path() {
    
    default_path="/etc/letsencrypt/live"

    if [ -d "$default_path" ]; then
        CERTBOT_LIVE_PATH="$default_path"
    else
        CERTBOT_LIVE_PATH=$(find /etc -type d -path "*/letsencrypt/live" 2>/dev/null | head -n 1)
    fi
    echo -e "${GREY}Detected Certbot live path: $CERTBOT_LIVE_PATH${NC}"
    if [ -z "$CERTBOT_LIVE_PATH" ]; then
        echo -e "${RED}Certbot live path not found. Please verify Certbot is installed and certificates are issued.${NC}"
        return 1
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
    read -rp "$(echo -e "${YELLOW}Do you want to generate SSL certificate for this domain? (y/n): ${NC}")" ssl_cert

    if [ "$ssl_cert" == "y" ]; then
        echo -e "${GREY}Generating SSL certificate for $DOMAIN_NAME${NC}"

        read -rp "$(echo -e "${YELLOW}Do you want to wait to verify DNS configuration before generating the certificate? (y/n): ${NC}")" wait_dns
        echo -e "$(echo -e "${YELLOW}Waiting for 1 minute before requesting SSL certificate...${NC}")"
        if [ "$wait_dns" == "y" ]; then
            read -rp "$(echo -e "${GREEN}Enter the number of seconds to wait: ${NC}")" wait_seconds
            if [[ "$wait_seconds" =~ ^[0-9]+$ ]]; then
                echo -e "$(echo -e "${GREY}Waiting for $wait_seconds seconds to verify DNS configuration...${NC}")"
                while [ "$wait_seconds" -gt 0 ]; do
                    echo -ne "$(echo -e "${GREY} $wait_seconds\033[0K\r ${NC}")"
                    sleep 1
                    : $((wait_seconds--))
                done
            else
                echo -e "${RED}Invalid input. Exiting...${NC}"
                exit 1
            fi
        fi
        # Detect Certbot live path
        detect_certbot_live_path
        if [ -d "$CERTBOT_LIVE_PATH/$DOMAIN_NAME" ]; then
            echo -e "${YELLOW}SSL certificate already exists for $DOMAIN_NAME.${NC}"
            echo -e "${GREY}Reinstalling SSL certificate for $DOMAIN_NAME...${NC}"

            if certbot --nginx --reinstall -d "$DOMAIN_NAME"; then
                echo -e "${GREEN}SSL certificate reinstalled successfully.${NC}"
            else
                echo -e "${RED}Failed to reinstall SSL certificate. Please check the Certbot logs for more details.${NC}"
                exit 1
            fi
            exit 0
        else
            echo -e "${YELLOW}No existing SSL certificate found for $DOMAIN_NAME. Proceeding to generate a new one...${NC}"
        fi

        if certbot --nginx -d "$DOMAIN_NAME"; then
            echo -e "${GREEN}SSL certificate generated successfully.${NC}"
        else
            echo -e "${RED}Failed to generate SSL certificate. Please check the Certbot logs for more details.${NC}"
            exit 1
        fi
    fi
}

# Check if Certbot is installed and install Certbot if not installed and user agrees to install it
check_and_install_certbot() {
    if command -v certbot > /dev/null 2>&1; then
        echo -e "${GREEN}Certbot is already installed.${NC}"
        return
    fi

    echo -e "${RED}Certbot is not installed.${NC}"
    read -rp "$(echo -e "${GREEN}Do you want to install Certbot? (y/n): ${NC}")" install_certbot
    if [[ "$install_certbot" =~ ^[Yy]$ ]]; then
        echo -e "${GREY}Attempting to install Certbot...${NC}"

        INSTALL_CMD=""
        if command -v apt > /dev/null; then
            INSTALL_CMD="sudo apt update && sudo apt install -y certbot python3-certbot-nginx"
        elif command -v dnf > /dev/null; then
            INSTALL_CMD="sudo dnf install -y certbot python3-certbot-nginx"
        elif command -v yum > /dev/null; then
            INSTALL_CMD="sudo yum install -y certbot python3-certbot-nginx"
        elif command -v pacman > /dev/null; then
            INSTALL_CMD="sudo pacman -Sy --noconfirm certbot certbot-nginx"
        elif command -v apk > /dev/null; then
            INSTALL_CMD="sudo apk add certbot certbot-nginx"
        else
            echo -e "${RED}Unsupported package manager. Please install Certbot manually.${NC}"
            exit 1
        fi

        if ! eval "$INSTALL_CMD"; then
            echo -e "${RED}Certbot installation failed. Please check your system or install manually.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Certbot is required. Exiting...${NC}"
        exit 1
    fi
}

check_and_install_nc() {
    if ! command -v nc &> /dev/null; then
        echo -e "${YELLOW}Netcat (nc) is not installed.${NC}"
        read -rp "Do you want to install netcat? (y/n): " yn
        case "$yn" in
            [Yy]*)
                echo -e "${GREY}Attempting to install netcat...${NC}"
                if command -v apt &> /dev/null; then
                    sudo apt update && sudo apt install -y netcat
                elif command -v yum &> /dev/null; then
                    sudo yum install -y nc
                elif command -v dnf &> /dev/null; then
                    sudo dnf install -y nc
                elif command -v pacman &> /dev/null; then
                    sudo pacman -Sy --noconfirm openbsd-netcat
                else
                    echo -e "${RED}Unsupported package manager. Please install netcat manually.${NC}"
                    exit 1
                fi
                ;;
            *)
                echo -e "${RED}Netcat is required. Exiting...${NC}"
                exit 1
                ;;
        esac
    else
        echo -e "${GREEN}Netcat (nc) is already installed.${NC}"
    fi
}


# This function removes an existing Nginx website configuration.
# It takes the website's domain name as an argument, disables the site,
# removes the configuration file, and reloads the Nginx service to apply changes.
remove_nginx_website() {
    # List current websites
    echo -e "${YELLOW}Current websites:${NC}"
    mapfile -t websites < <(find "$nginx_sites_available" -maxdepth 1 -type f -name '*.conf' -exec basename {} .conf \;)
    if [ ${#websites[@]} -eq 0 ]; then
        echo -e "${RED}No websites found in Nginx sites-available directory.${NC}"
        diplay_menu
    fi
    for i in "${!websites[@]}"; do
        echo -e "${YELLOW}$((i+1)). ${websites[$i]}${NC}"
    done

    # Prompt user to enter the number of the website to delete
    read -rp "$(echo -e "${GREEN}Enter the number for the website you want to remove: ${NC}")" website_number
    if ! [[ "$website_number" =~ ^[0-9]+$ ]] || [ "$website_number" -le 0 ] || [ "$website_number" -gt "${#websites[@]}" ]; then
        echo -e "${RED}Invalid option. Exiting...${NC}"
        diplay_menu
    fi

    remove_domain_name=${websites[$((website_number-1))]}

    # Confirm with user
    read -rp "$(echo -e "${GREEN}Are you sure you want to remove the website '$remove_domain_name'? (Y/N): ${NC}")" confirm
    if [[ "$confirm" != "Y" && "$confirm" != "y" ]]; then
        echo -e "${RED}Operation cancelled. Exiting...${NC}"
        exit 1
    fi

    # Remove configuration file
    if [ -f "$nginx_sites_available/${remove_domain_name}.conf" ]; then
        rm "$nginx_sites_available/${remove_domain_name}.conf"
        echo -e "${YELLOW}Removed configuration file for $remove_domain_name${NC}"
    else
        echo -e "${RED}Configuration file for $remove_domain_name does not exist.${NC}"
    fi

    # Remove symbolic link
    echo -e "${GREY}Removing symbolic link for $remove_domain_name...${NC}"
    if [ -L "$nginx_sites_enabled/${remove_domain_name}.conf" ]; then
        rm "$nginx_sites_enabled/${remove_domain_name}.conf"
        echo -e "${YELLOW}Removed symbolic link for $remove_domain_name${NC}"
    else
        echo -e "${RED}Symbolic link for $remove_domain_name does not exist.${NC}"
    fi
    restart_nginx
}

restart_nginx() {
    echo -e "${GREY}Restarting Nginx...${NC}"

    # Check if systemctl exists
    if ! command -v systemctl > /dev/null 2>&1; then
        echo -e "${RED}Systemctl not found. Trying 'service' command as fallback...${NC}"
        if command -v service > /dev/null 2>&1; then
            if service nginx restart; then
                echo -e "${GREEN}Nginx restarted successfully using service command.${NC}"
            else
                echo -e "${RED}Failed to restart Nginx using service command.${NC}"
                echo -e "${YELLOW}Check logs: /var/log/nginx/error.log or run 'service nginx status'${NC}"
                exit 1
            fi
        else
            echo -e "${RED}Neither systemctl nor service found. Cannot manage Nginx.${NC}"
            exit 1
        fi
        return
    fi

    # Try to restart with systemctl
    if systemctl restart nginx; then
        echo -e "${GREEN}Nginx restarted successfully.${NC}"
    else
        echo -e "${RED}Failed to restart Nginx using systemctl.${NC}"
        echo -e "${YELLOW}Check logs: journalctl -u nginx or /var/log/nginx/error.log${NC}"
        exit 1
    fi
}


# Main script execution starts here
echo -e "${GREEN}Welcome to the Nginx Proxy Generator Script!${NC}"
# check prerequisites and dependencies
Prerequisites_checks

# Run the manage websites flow
manage_nginx_websites "$@"
