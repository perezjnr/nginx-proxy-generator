prompt_proxy_scheme() {
    # Set proxy pass scheme based on user input (1 for http, 2 for https)
    read -rp "$(echo -e "${GREEN}Is origin/host server setup for http or https? (1 for http, 2 for https): ${NC}")" proxy_pass_scheme
    if [ -z "$proxy_pass_scheme" ]; then
        echo -e "${RED}Scheme cannot be empty. Exiting...${NC}"
        exit 1
    fi 
    if [ "$proxy_pass_scheme" == "1" ]; then
        if [ "$LISTEN_PORT" -ne 80 ] && [ "$LISTEN_PORT" -ne 443 ]; then
            echo -e "${GREY}Using custom port $LISTEN_PORT for HTTP.${NC}"
            PROXY_PASS_IP="http://$PROXY_PASS_IP:$LISTEN_PORT"
        else
            echo -e "${GREY}Using default port 80 for HTTP.${NC}"
            PROXY_PASS_IP="http://$PROXY_PASS_IP"
        fi
    elif [ "$proxy_pass_scheme" == "2" ]; then
        if [ "$LISTEN_PORT" -ne 80 ] && [ "$LISTEN_PORT" -ne 443 ]; then
            echo -e "${GREY}Using custom port $LISTEN_PORT for HTTPS.${NC}"
            PROXY_PASS_IP="https://$PROXY_PASS_IP:$LISTEN_PORT"
        else
            echo -e "${GREY}Using default port 443 for HTTPS.${NC}"
            PROXY_PASS_IP="https://$PROXY_PASS_IP"

        fi
    else
        echo -e "${RED}Invalid scheme. Exiting...${NC}"
        exit 1
    fi
}