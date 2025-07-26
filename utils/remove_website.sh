# This function removes an existing Nginx website configuration.
# It takes the website's domain name as an argument, disables the site,
# removes the configuration file, and reloads the Nginx service to apply changes.
remove_nginx_website() {
    # List current websites
    echo -e "${YELLOW}Current websites:${NC}"
    mapfile -t websites < <(find "$NGINX_SITES_AVAILABLE" -maxdepth 1 -type f -name '*.conf' -exec basename {} .conf \;)
    if [ ${#websites[@]} -eq 0 ]; then
        echo -e "${RED}No websites found in Nginx sites-available directory.${NC}"
        diplay_menu
    fi
    for i in "${!websites[@]}"; do
        echo -e "${YELLOW}$((i+1)). ${websites[$i]}${NC}"
    done

    # Prompt user to enter the number of the website to delete
    read -rp "$(echo -e "${GREEN}Enter the number for the website you want to remove: ${NC}")" website_number
    if ! [[ "$website_number" =~ ^[0-9]+$ ]] || [ "$website_number" -le 0 ] || [ "$website_number" -gt "${#websites[@]}" ]; then
        echo -e "${RED}Invalid option. Exiting...${NC}"
        diplay_menu
    fi

    remove_domain_name=${websites[$((website_number-1))]}

    # Confirm with user
    read -rp "$(echo -e "${GREEN}Are you sure you want to remove the website '$remove_domain_name'? (Y/N): ${NC}")" confirm
    if [[ "$confirm" != "Y" && "$confirm" != "y" ]]; then
        echo -e "${RED}Operation cancelled. Exiting...${NC}"
        exit 1
    fi

    # Remove configuration file
    if [ -f "$NGINX_SITES_AVAILABLE/${remove_domain_name}.conf" ]; then
        rm "$NGINX_SITES_AVAILABLE/${remove_domain_name}.conf"
        echo -e "${YELLOW}Removed configuration file for $remove_domain_name${NC}"
    else
        echo -e "${RED}Configuration file for $remove_domain_name does not exist.${NC}"
    fi

    # Remove symbolic link
    echo -e "${GREY}Removing symbolic link for $remove_domain_name...${NC}"
    if [ -L "$NGINX_SITES_ENABLED/${remove_domain_name}.conf" ]; then
        rm "$NGINX_SITES_ENABLED/${remove_domain_name}.conf"
        echo -e "${YELLOW}Removed symbolic link for $remove_domain_name${NC}"
    else
        echo -e "${RED}Symbolic link for $remove_domain_name does not exist.${NC}"
    fi
    # Reload Nginx to apply changes
    restart_nginx
}