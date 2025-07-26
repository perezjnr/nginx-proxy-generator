# Create Nginx configuration file
create_nginx_config() {
    # Create Nginx configuration file
    cat > $NGINX_SITES_AVAILABLE/"${DOMAIN_NAME}".conf <<EOF
    server {
        listen 80;
        server_name $DOMAIN_NAME;

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
    if [ -d "$NGINX_SITES_AVAILABLE" ]; then
        echo -e "${GREEN} Configuration file generated as '${DOMAIN_NAME}.conf' and saved in ${NGINX_SITES_AVAILABLE}.${NC}"
    else
        echo -e "${RED}Error generating configuration file. Exiting...${NC}"
        exit 1
    fi
    # Check for Nginx syntax errors
    temp_conf="/etc/nginx/conf.d/temp-${DOMAIN_NAME}.conf"
    cp "$NGINX_SITES_AVAILABLE/${DOMAIN_NAME}.conf" "$temp_conf"

    if nginx -t; then
        rm -f "$temp_conf"
        link_nginx_config
        echo -e "${GREY}Nginx configuration is valid. Restarting Nginx...${NC}"
        restart_nginx
    else
        nginx -t 2>&1 | grep "nginx: \[emerg\]"
        echo -e "${RED}Nginx configuration is invalid. Please check the configuration file for errors.${NC}"
        exit 1
    fi
}

# Create symbolic link for Nginx configuration file
link_nginx_config() {
    if [ ! -L "${NGINX_SITES_ENABLED}/${DOMAIN_NAME}.conf" ]; then
        echo -e "${GREY}Creating symbolic link for ${NGINX_SITES_ENABLED}/${DOMAIN_NAME}.conf${NC}"
        if ln -s "$NGINX_SITES_AVAILABLE/${DOMAIN_NAME}.conf" "${NGINX_SITES_ENABLED}/${DOMAIN_NAME}.conf"; then
            echo -e "${GREEN}Configuration file symbolic link created.${NC}"
        else
            echo -e "${RED}Failed to create symbolic link for configuration file. Exiting...${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Symbolic link already exists for ${NGINX_SITES_ENABLED}/${DOMAIN_NAME}.conf${NC}"
    fi
}