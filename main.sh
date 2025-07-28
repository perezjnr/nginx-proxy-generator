#!/bin/bash
# Load Configs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#source "$SCRIPT_DIR/config/colours.sh"
# Load Functions
source "$SCRIPT_DIR/checks/certbot.sh"
source "$SCRIPT_DIR/checks/dependencies.sh"
source "$SCRIPT_DIR/checks/netcat.sh"
source "$SCRIPT_DIR/checks/nginx.sh"

source "$SCRIPT_DIR/config/user_config.sh"
source "$SCRIPT_DIR/config/colours.sh"
source "$SCRIPT_DIR/config/constants.sh"

source "$SCRIPT_DIR/prompts/host_ip.sh"
source "$SCRIPT_DIR/prompts/host_server_port.sh"
source "$SCRIPT_DIR/prompts/http_https_scheme.sh"
source "$SCRIPT_DIR/prompts/domain_name.sh"

source "$SCRIPT_DIR/utils/certbot_path.sh"
source "$SCRIPT_DIR/utils/create_nginx_config_file.sh"
source "$SCRIPT_DIR/utils/menu.sh"
source "$SCRIPT_DIR/utils/menu_options.sh"
source "$SCRIPT_DIR/utils/nginx_path.sh"
source "$SCRIPT_DIR/utils/project_info.sh"
source "$SCRIPT_DIR/utils/remove_website.sh"
source "$SCRIPT_DIR/utils/request_ssl_certificate.sh"
source "$SCRIPT_DIR/utils/restart_nginx.sh"

# Log file
LOG_FILE="/var/log/nginx_proxy_generator.log"

log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

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

    echo -e "${YELLOW}Current Nginx sites-available directory: ${NGINX_SITES_AVAILABLE}${NC}"
    
    if [ -d "$NGINX_SITES_AVAILABLE" ]; then
        echo -e "${GREY}List of available sites:${NC}"
        for f in "$NGINX_SITES_AVAILABLE"/*; do
            if [[ -f "$f"  && "$f" != *.bak ]]; then
                echo -e "${GREEN} $(basename "$f")${NC}"
            fi
        done
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
    echo -e "${YELLOW}Current Nginx sites-enabled directory: ${NGINX_SITES_ENABLED}${NC}"
    if [ -d "$NGINX_SITES_ENABLED" ]; then
        echo -e "${GREY}List of enabled sites:${NC}"
        for f in "$NGINX_SITES_ENABLED"/*; do
            if [[ -f "$f"  && "$f" != *.bak ]]; then
                echo -e "${GREEN} $(basename "$f")${NC}"
            fi
        done
    else
        echo -e "${RED}Nginx sites-enabled directory does not exist. Please create it first.${NC}"
        exit 1
    fi
}

# Function to add a new website
add_nginx_website() {
    prompt_user_input
    create_nginx_config
    generate_ssl_certificate
    restart_nginx
}


# Function to prompt for user input
prompt_user_input() {

    prompt_server_port
    prompt_domain_name
    prompt_ip_address
    prompt_proxy_scheme

}

# Main script execution starts here
echo -e "${GREEN}Welcome to the Nginx Proxy Generator Script!${NC}"
# check prerequisites and dependencies
Prerequisites_checks

# Run the manage websites flow
manage_nginx_websites "$@"
