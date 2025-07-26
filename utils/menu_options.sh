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