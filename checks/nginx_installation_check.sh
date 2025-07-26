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

    if [ ! -d "$NGINX_SITES_AVAILABLE" ]; then
        echo -e "${YELLOW}Nginx sites-available directory does not exist.${NC} Do you want to create it? (y/n)"

        read -rp "$(echo -e "${GREEN}Create Nginx sites-available directory? (y/n): ${NC}")" create_sites_available
        if [ "$create_sites_available" == "y" ]; then
            mkdir -p "$NGINX_SITES_AVAILABLE"
        else
            echo -e "${RED}Nginx sites-available directory is required for this script to work.${NC} Exiting..."
            exit 1
        fi
    fi
}