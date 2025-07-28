detect_certbot_live_path() {
    
    default_path="/etc/letsencrypt/live"

    if [ -d "$default_path" ]; then
        CERTBOT_LIVE_PATH="$default_path"
    else
        CERTBOT_LIVE_PATH=$(find /etc -type d -path "*/letsencrypt/live" 2>/dev/null | head -n 1)
    fi
    echo -e "${GREY}Detected Certbot live path: $CERTBOT_LIVE_PATH${NC}"
    if [ -z "$CERTBOT_LIVE_PATH" ]; then
        echo -e "${RED}Certbot live path not found. Please verify Certbot is installed and certificates are issued.${NC}"
        return 1
    fi
}