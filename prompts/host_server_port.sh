prompt_server_port() {
    # Prompt for user input
while true; do
    read -rp "$(echo -e "${GREEN}Enter origin/host web server listen port (press enter for default HTTP (80)):${NC}")" LISTEN_PORT
    if [[ -z "$LISTEN_PORT" ]]; then
        LISTEN_PORT=80
        break
    elif [[ "$LISTEN_PORT" =~ ^[0-9]+$ ]]; then
        break
    else
        echo -e "${RED}Invalid input. Please enter a numeric value only.${NC}"
    fi
done
    # Check if the port is valid
    if [[ "$LISTEN_PORT" -lt 1 || "$LISTEN_PORT" -gt 65535 ]]; then
        echo -e "${RED}Invalid port number. Please enter a value between 1 and 65535.${NC}"
        prompt_server_port
    else
        echo -e "${GREY}Origin/Host server listen port: $LISTEN_PORT${NC}"
    fi
}