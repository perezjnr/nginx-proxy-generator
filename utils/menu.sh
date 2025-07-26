# Function to display the menu and handle user input
diplay_menu()
{
while true; do
        menu_options
        read -rp "$(echo -e "${GREEN}Enter your choice (1-8): ${NC}")" choice

        case $choice in
            1)
                add_nginx_website
                break
                ;;
            2)
                remove_nginx_website
                break
                ;;
            3)
                show_usage
                continue
                ;;
            4)
                display_info 
                continue           
                ;;
            5)
                display_nginx_version  
                continue              
                ;;
            6)
                display_nginx_sites_available 
                continue               
                ;;
            7)
                display_nginx_sites_enabled 
                continue               
                ;;
            8)
                echo -e "${GREY}Exiting...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please enter 1-8.${NC}"
                ;;
        esac
    done
}