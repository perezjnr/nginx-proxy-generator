# Check if Netcat (nc) is installed and install it if not installed and user agrees to install it
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
