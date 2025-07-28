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