1 # Function to display the menu and handle user input
 2 diplay_menu()
 3 {
 4 while true; do
 5         menu_options
 6         read -rp "$(echo -e "${GREEN}Enter your choice (1-9): ${NC}")" choice
 7
 8         case $choice in
 9             1)
10                 add_nginx_website
11                 break
12                 ;;
13             2)
14                 remove_nginx_website
15                 break
16                 ;;
17             3)
18                 show_usage
19                 continue
20                 ;;
21             4)
22                 display_info
23                 continue
24                 ;;
25             5)
26                 display_nginx_version
27                 continue
28                 ;;
29             6)
30                 display_nginx_sites_available
31                 continue
32                 ;;
33             7)
34                 display_nginx_sites_enabled
35                 continue
36                 ;;
37             8)
38                 sudo certbot --nginx
39                 continue
40                 ;;
41             9)
42                 echo -e "${GREY}Exiting...${NC}"
43                 exit 0
44                 ;;
45             *)
46                 echo -e "${RED}Invalid option. Please enter 1-9.${NC}"
47                 ;;
48         esac
49     done
50 }
