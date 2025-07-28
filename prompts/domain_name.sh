prompt_domain_name() {
    echo -e "${GREY}If domain DNS has not been configured, please do so before continuing.${NC}"

    local retry_count=0
    local max_retries=5

    while (( retry_count < max_retries )); do
        read -rp "$(echo -e "${GREEN}Enter (FQDN) domain name to be used for website (e.g. example.com, www.example.com): ${NC}")" domain_name
        DOMAIN_NAME="${domain_name,,}"  # lowercase
        echo -e "${GREY}Using domain name: $DOMAIN_NAME${NC}"
        if [[ -z "$DOMAIN_NAME" ]]; then
            echo -e "${RED}Domain name cannot be empty.${NC}"
        elif [[ ! "$DOMAIN_NAME" =~ ^([a-zA-Z0-9]([-a-zA-Z0-9]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$ ]]; then
            echo -e "${RED}Invalid domain format. Must be like example.com or sub.domain.org.${NC}"
            ((retry_count++))
            continue
        else
            # Check Nginx config existence
            if [[ -z "$NGINX_SITES_AVAILABLE" || ! -d "$NGINX_SITES_AVAILABLE" ]]; then
                echo -e "${RED}Nginx sites-available directory is not set or does not exist. Exiting...${NC}"
                exit 1
            fi

            local domain_config_file="$NGINX_SITES_AVAILABLE/${DOMAIN_NAME}.conf"
            if [[ -f "$domain_config_file" ]]; then
                echo -e "${YELLOW}Domain config already exists: $domain_config_file${NC}"
                read -rp "$(echo -e "${GREEN}Do you want to overwrite it? (y/n): ${NC}")" overwrite
                if [[ "$overwrite" != "y" ]]; then
                    echo -e "${YELLOW}You chose not to overwrite. Try again with a different domain.${NC}"
                    ((retry_count++))
                    continue
                else
                    echo -e "${YELLOW}Overwriting existing configuration...${NC}"
                    # Backup existing config
                    cp "$domain_config_file" "${domain_config_file}.bak"
                    rm -f "$domain_config_file"
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