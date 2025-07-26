detect_nginx_paths() {
    # Default for Debian/Ubuntu
    NGINX_SITES_AVAILABLE="/etc/nginx/sites-available"
    NGINX_SITES_ENABLED="/etc/nginx/sites-enabled"
    # Alpine
    if [ -f /etc/alpine-release ]; then
        NGINX_SITES_AVAILABLE="/etc/nginx/conf.d"
        NGINX_SITES_ENABLED="/etc/nginx/conf.d"

    # RHEL/CentOS/Fedora
    elif grep -qi 'centos\|rhel\|fedora' /etc/os-release 2>/dev/null; then
        NGINX_SITES_AVAILABLE="/etc/nginx/conf.d"
        NGINX_SITES_ENABLED="/etc/nginx/conf.d"

    # Arch Linux
    elif grep -qi 'arch' /etc/os-release 2>/dev/null; then
        NGINX_SITES_AVAILABLE="/etc/nginx/conf.d"
        NGINX_SITES_ENABLED="/etc/nginx/conf.d"
    fi

    echo -e "${GREEN}Using Nginx sites-available: $NGINX_SITES_AVAILABLE${NC}"
    echo -e "${GREEN}Using Nginx sites-enabled:   $NGINX_SITES_ENABLED${NC}"
}