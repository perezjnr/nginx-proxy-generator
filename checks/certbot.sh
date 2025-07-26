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

