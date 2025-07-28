# Function to prompt for the origin/host web server IP address or FQDN
prompt_ip_address() {
    local retry_count=0
    local max_retries=5

    while true; do
        read -rp "$(echo -e "${GREEN}Enter origin/host web server IP address or FQDN: ${NC}")" PROXY_PASS_IP

        # Check for empty input
        if [[ -z "$PROXY_PASS_IP" ]]; then
            echo -e "${YELLOW}Input cannot be empty. Please try again.${NC}"
        # Check valid IP or FQDN format
        echo -e "${GREY}Using IP:${NC} ${GREEN}$PROXY_PASS_IP${NC} ${GREY}as proxy pass IP${NC}"
        elif [[ "$PROXY_PASS_IP" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ || "$PROXY_PASS_IP" =~ ^[a-zA-Z0-9.-]+$ ]]; then
            # Check if reachable

            if nc -z -w2 "$PROXY_PASS_IP" "$LISTEN_PORT"; then
                echo -e "${GREEN}Host $PROXY_PASS_IP is reachable.${NC}"
                break
            else
                echo -e "${RED}Host $PROXY_PASS_IP is unreachable.${NC}"
                read -rp "Do you want to continue anyway? (y/n): " yn
                case "$yn" in
                    [Yy]*) echo -e "${GREEN}Continuing...${NC}";;
                    *) echo -e "${RED}Exiting.${NC}"; exit 1;;
                esac
            fi
            # Optional DNS check
            if ! host "$domain_name" > /dev/null 2>&1; then
                echo -e "${YELLOW}Warning: $domain_name is not resolving. Check DNS settings.${NC}"
            fi
        else
            echo -e "${YELLOW}Invalid IP address or FQDN format. Please try again.${NC}"
        fi

        ((retry_count++))
        if (( retry_count >= max_retries )); then
            echo -e "${RED}Too many invalid attempts. Exiting.${NC}"
            exit 1
        fi
    done
}
