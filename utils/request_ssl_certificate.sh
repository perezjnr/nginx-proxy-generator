
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