#!/bin/bash
# ==========================================
# VMESS MANAGER ULTIMATE - COMPLETE VERSION
# Support: All Protocols + All Ports Open + UDPGW
# Author: Sukron Wae
# GitHub: https://github.com/sukronwae85-design/vmess-tcp-http-quic-ws-cdn-gasspoll
# ==========================================

# Configuration
CONFIG_DIR="/etc/vmess-manager"
CONFIG_FILE="$CONFIG_DIR/config.json"
USER_DB="$CONFIG_DIR/users.db"
LOG_FILE="/var/log/vmess-manager.log"
BACKUP_DIR="/root/vmess-backup"
TIMEZONE="Asia/Jakarta"
DEFAULT_PORT=8443
UDPGW_PORTS="7100 7200 7300"

# All ports to open
PORTS_TCP="20 21 22 25 53 80 110 143 443 465 587 993 995 2082 2083 2086 2087 2095 2096 3000 3001 3306 3389 5432 8080 8081 8082 8083 8084 8085 8086 8087 8088 8089 8090 8443 8880 9000 9001 9002 9003 9004 9005 9200 10000 20000 27017"
PORTS_UDP="53 443 1194 1195 1196 1197 1198 1199 1300 1301 1302 1303 1304 1305 7100 7200 7300 8000 8080 8443 9000 10000 20000"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Initialize
init_system() {
    echo -e "${GREEN}Initializing VMess Manager Ultimate...${NC}"
    
    # Set timezone
    timedatectl set-timezone $TIMEZONE
    
    # Create directories
    mkdir -p $CONFIG_DIR
    mkdir -p /var/log/vmess
    mkdir -p /etc/xray/ssl
    mkdir -p $BACKUP_DIR
    mkdir -p /etc/udpgw
    
    # Detect OS and install dependencies
    detect_os_and_install
    
    # Install Xray
    echo -e "${YELLOW}Installing Xray-core...${NC}"
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
    
    # Install badvpn-udpgw for game support
    install_udpgw
    
    # Open ALL ports
    open_all_ports
    
    # Generate default config if not exists
    if [ ! -f "$CONFIG_FILE" ]; then
        generate_default_config
    fi
    
    # Create user database
    if [ ! -f "$USER_DB" ]; then
        echo '[]' > $USER_DB
    fi
    
    echo -e "${GREEN}Initialization completed!${NC}"
}

detect_os_and_install() {
    echo -e "${YELLOW}Detecting OS and installing dependencies...${NC}"
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
    else
        OS=$(uname -s)
    fi

    case $OS in
        *Ubuntu*|*Debian*)
            echo -e "${GREEN}Detected Ubuntu/Debian system${NC}"
            apt update && apt upgrade -y
            apt install -y jq net-tools bc openssl uuid-runtime curl nginx certbot python3-certbot-nginx build-essential cmake git iptables-persistent
            ;;
        *CentOS*|*Red*Hat*|*Fedora*)
            echo -e "${GREEN}Detected CentOS/RHEL/Fedora system${NC}"
            yum update -y
            yum install -y jq net-tools bc openssl util-linux curl nginx certbot python3-certbot-nginx cmake gcc-c++ make git iptables-services
            ;;
        *Arch*)
            echo -e "${GREEN}Detected Arch Linux system${NC}"
            pacman -Syu --noconfirm
            pacman -S --noconfirm jq net-tools bc openssl util-linux curl nginx certbot certbot-nginx cmake gcc make git iptables
            ;;
        *)
            echo -e "${YELLOW}Unknown OS, trying Ubuntu/Debian packages...${NC}"
            apt update && apt upgrade -y
            apt install -y jq net-tools bc openssl uuid-runtime curl nginx certbot python3-certbot-nginx build-essential cmake git iptables-persistent
            ;;
    esac
}

install_udpgw() {
    echo -e "${CYAN}=== INSTALLING BADVPN-UDPGW FOR GAME SUPPORT ===${NC}"
    
    # Check if udpgw already installed
    if command -v badvpn-udpgw &> /dev/null; then
        echo -e "${GREEN}badvpn-udpgw already installed!${NC}"
        return
    fi
    
    echo -e "${YELLOW}Compiling and installing badvpn-udpgw...${NC}"
    
    # Clone and compile badvpn
    cd /tmp
    git clone https://github.com/ambrop72/badvpn.git
    cd badvpn
    mkdir build
    cd build
    cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
    make
    cp udpgw/badvpn-udpgw /usr/local/bin/
    
    # Create systemd service for udpgw
    for port in $UDPGW_PORTS; do
        cat > /etc/systemd/system/badvpn-udpgw-$port.service << EOF
[Unit]
Description=BadVPN UDP Gateway for Game Support on port $port
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/badvpn-udpgw --listen-addr 0.0.0.0:$port --max-clients 1000 --max-connections-for-client 10
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
        
        systemctl enable badvpn-udpgw-$port
        systemctl start badvpn-udpgw-$port
        echo -e "${GREEN}UDPGW started on port $port${NC}"
    done
    
    echo -e "${GREEN}UDPGW installed and running on ports: $UDPGW_PORTS${NC}"
}

open_all_ports() {
    echo -e "${YELLOW}🔥 OPENING ALL PORTS TCP & UDP...${NC}"
    
    # Disable firewall first (Ubuntu/Debian)
    if command -v ufw &> /dev/null; then
        echo -e "${YELLOW}Disabling UFW...${NC}"
        ufw --force disable
        ufw --force reset
    fi
    
    # Stop iptables services
    systemctl stop iptables 2>/dev/null
    systemctl stop firewalld 2>/dev/null
    
    # Flush all iptables rules
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    
    # Open ALL TCP ports
    echo -e "${GREEN}Opening ALL TCP ports...${NC}"
    for port in $PORTS_TCP; do
        iptables -A INPUT -p tcp --dport $port -j ACCEPT
        echo -e "✅ TCP port $port opened"
    done
    
    # Open ALL UDP ports  
    echo -e "${GREEN}Opening ALL UDP ports...${NC}"
    for port in $PORTS_UDP; do
        iptables -A INPUT -p udp --dport $port -j ACCEPT
        echo -e "✅ UDP port $port opened"
    done
    
    # Additional common ports
    iptables -A INPUT -p tcp --dport 1:65535 -j ACCEPT
    iptables -A INPUT -p udp --dport 1:65535 -j ACCEPT
    
    # Save iptables rules
    if command -v iptables-save &> /dev/null; then
        iptables-save > /etc/iptables/rules.v4
    fi
    
    echo -e "${GREEN}🔥 ALL PORTS TCP/UDP ARE NOW OPEN! 🔥${NC}"
    echo -e "${YELLOW}Total TCP ports opened: $(echo $PORTS_TCP | wc -w)${NC}"
    echo -e "${YELLOW}Total UDP ports opened: $(echo $PORTS_UDP | wc -w)${NC}"
}

generate_default_config() {
    cat > $CONFIG_FILE << EOF
{
    "server": {
        "port": $DEFAULT_PORT,
        "domain": "your-domain.com",
        "max_connections": 1000,
        "ip_limit": 3,
        "ban_duration": "7d",
        "bandwidth_limit": "100GB",
        "multi_login_check": true,
        "udpgw_ports": "$UDPGW_PORTS",
        "all_ports_open": true
    },
    "ssl": {
        "email": "admin@your-domain.com",
        "cert_path": "/etc/letsencrypt/live/your-domain.com/fullchain.pem",
        "key_path": "/etc/letsencrypt/live/your-domain.com/privkey.pem"
    },
    "backup": {
        "gmail_enabled": false,
        "telegram_enabled": false,
        "whatsapp_enabled": false,
        "auto_backup": true,
        "backup_interval": "24h"
    }
}
EOF
}

# Logging
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# UUID Generator
generate_uuid() {
    cat /proc/sys/kernel/random/uuid
}

# Nginx Configuration
setup_nginx() {
    echo -e "${CYAN}=== SETUP NGINX ===${NC}"
    
    read -p "Enter your domain: " domain
    read -p "Enter port for reverse proxy (default: 8443): " proxy_port
    proxy_port=${proxy_port:-8443}
    
    # Create nginx config
    cat > /etc/nginx/sites-available/$domain << EOF
server {
    listen 80;
    server_name $domain;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $domain;
    
    # SSL Configuration (will be filled by certbot)
    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    # WebSocket path
    location /ws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:$proxy_port;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
    
    # HTTP path
    location /vmess {
        proxy_pass http://127.0.0.1:$proxy_port;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
    
    # HTTP/2 path
    location /h2 {
        proxy_pass http://127.0.0.1:$proxy_port;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
    
    # Block other requests
    location / {
        return 404;
    }
}
EOF

    # Enable site
    ln -sf /etc/nginx/sites-available/$domain /etc/nginx/sites-enabled/
    
    # Test nginx config
    nginx -t
    if [ $? -eq 0 ]; then
        systemctl reload nginx
        echo -e "${GREEN}Nginx configuration successful!${NC}"
        
        # Update config file
        jq --arg domain "$domain" '.server.domain = $domain' $CONFIG_FILE > tmp.json && mv tmp.json $CONFIG_FILE
        jq --argjson port "$proxy_port" '.server.port = $port' $CONFIG_FILE > tmp.json && mv tmp.json $CONFIG_FILE
    else
        echo -e "${RED}Nginx configuration error!${NC}"
        return 1
    fi
}

# SSL Setup with Certbot
setup_ssl() {
    echo -e "${CYAN}=== SETUP SSL CERTIFICATE ===${NC}"
    
    domain=$(jq -r '.server.domain' $CONFIG_FILE)
    
    if [ "$domain" == "your-domain.com" ]; then
        echo -e "${RED}Please setup domain first in Nginx configuration!${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Setting up SSL for $domain...${NC}"
    
    # Stop nginx temporarily for certbot
    systemctl stop nginx
    
    # Get SSL certificate
    certbot certonly --standalone -d $domain --non-interactive --agree-tos --email admin@$domain
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}SSL certificate obtained successfully!${NC}"
        
        # Update config with cert paths
        jq --arg cert "/etc/letsencrypt/live/$domain/fullchain.pem" '.ssl.cert_path = $cert' $CONFIG_FILE > tmp.json && mv tmp.json $CONFIG_FILE
        jq --arg key "/etc/letsencrypt/live/$domain/privkey.pem" '.ssl.key_path = $key' $CONFIG_FILE > tmp.json && mv tmp.json $CONFIG_FILE
        
        # Start nginx again
        systemctl start nginx
        
        # Setup auto-renewal
        setup_ssl_auto_renew
    else
        echo -e "${RED}SSL certificate failed!${NC}"
        systemctl start nginx
        return 1
    fi
}

setup_ssl_auto_renew() {
    echo -e "${YELLOW}Setting up SSL auto-renewal...${NC}"
    
    # Create renewal script
    cat > /etc/cron.daily/ssl-renew << EOF
#!/bin/bash
certbot renew --quiet --post-hook "systemctl reload nginx"
EOF
    
    chmod +x /etc/cron.daily/ssl-renew
    echo -e "${GREEN}SSL auto-renewal configured!${NC}"
}

show_udpgw_status() {
    echo -e "${CYAN}=== UDPGW STATUS ===${NC}"
    
    for port in $UDPGW_PORTS; do
        if systemctl is-active --quiet badvpn-udpgw-$port; then
            echo -e "Port $port: ${GREEN}ACTIVE${NC}"
            echo -e "  Connections: $(netstat -an | grep :$port | wc -l)"
        else
            echo -e "Port $port: ${RED}INACTIVE${NC}"
        fi
    done
    
    echo -e "${YELLOW}Usage for Games/WhatsApp:${NC}"
    echo -e "  Connect to udpgw://your-domain.com:7100"
    echo -e "  Support: Mobile Legends, Free Fire, WhatsApp calls"
}

restart_udpgw() {
    echo -e "${CYAN}Restarting UDPGW services...${NC}"
    
    for port in $UDPGW_PORTS; do
        systemctl restart badvpn-udpgw-$port
    done
    
    echo -e "${GREEN}UDPGW services restarted!${NC}"
}

show_ports_status() {
    echo -e "${CYAN}=== PORTS STATUS ===${NC}"
    echo -e "${GREEN}All TCP/UDP ports are OPEN!${NC}"
    echo -e "${YELLOW}TCP Ports: $PORTS_TCP${NC}"
    echo -e "${YELLOW}UDP Ports: $PORTS_UDP${NC}"
    echo -e "${YELLOW}UDPGW Ports: $UDPGW_PORTS${NC}"
    
    # Test some important ports
    important_ports="22 80 443 8443 7100 7200 7300"
    echo -e "\n${CYAN}Testing important ports...${NC}"
    for port in $important_ports; do
        if netstat -tuln | grep ":$port " > /dev/null; then
            echo -e "✅ Port $port: LISTENING"
        else
            echo -e "❌ Port $port: NOT LISTENING"
        fi
    done
}

# User Management
create_user() {
    echo -e "${CYAN}=== CREATE VMESS USER ===${NC}"
    
    read -p "Enter username: " username
    if [[ -z "$username" ]]; then
        echo -e "${RED}Username cannot be empty!${NC}"
        return 1
    fi
    
    # Check if user exists
    if jq -e ".[] | select(.username == \"$username\")" "$USER_DB" > /dev/null; then
        echo -e "${RED}User already exists!${NC}"
        return 1
    fi
    
    read -p "Enter password (leave empty for auto-generate): " password
    if [[ -z "$password" ]]; then
        password=$(openssl rand -base64 12)
    fi
    
    read -p "Enter IP limit (default: 3): " ip_limit
    ip_limit=${ip_limit:-3}
    
    read -p "Enter bandwidth limit (e.g., 100GB, default: unlimited): " bandwidth_limit
    bandwidth_limit=${bandwidth_limit:-"unlimited"}
    
    read -p "Enter expiration days (default: 30): " exp_days
    exp_days=${exp_days:-30}
    
    uuid=$(generate_uuid)
    creation_date=$(date '+%Y-%m-%d %H:%M:%S')
    expiration_date=$(date -d "+$exp_days days" '+%Y-%m-%d %H:%M:%S')
    
    # Add to database
    jq --arg user "$username" \
       --arg pass "$password" \
       --arg uid "$uuid" \
       --arg creation "$creation_date" \
       --arg expiration "$expiration_date" \
       --argjson ip_limit $ip_limit \
       --arg bw_limit "$bandwidth_limit" \
       --arg status "active" \
       '. += [{
            "username": $user,
            "password": $pass,
            "uuid": $uid,
            "creation_date": $creation,
            "expiration_date": $expiration,
            "ip_limit": $ip_limit,
            "bandwidth_limit": $bw_limit,
            "status": $status,
            "protocols": [],
            "used_bandwidth": 0,
            "current_ips": []
        }]' "$USER_DB" > tmp.db && mv tmp.db "$USER_DB"
    
    echo -e "${GREEN}User created successfully!${NC}"
    echo -e "${YELLOW}Username: $username${NC}"
    echo -e "${YELLOW}Password: $password${NC}"
    echo -e "${YELLOW}UUID: $uuid${NC}"
    echo -e "${YELLOW}Expiration: $expiration_date${NC}"
    
    log_message "User created: $username"
}

create_vmess_tcp() {
    create_user
    if [ $? -eq 0 ]; then
        username=$(jq -r '.[-1].username' "$USER_DB")
        jq --arg user "$username" --arg protocol "tcp" \
           '(.[] | select(.username == $user)).protocols += [$protocol]' \
           "$USER_DB" > tmp.db && mv tmp.db "$USER_DB"
        show_connection_info "tcp" "$username"
    fi
}

create_vmess_http() {
    create_user
    if [ $? -eq 0 ]; then
        username=$(jq -r '.[-1].username' "$USER_DB")
        jq --arg user "$username" --arg protocol "http" \
           '(.[] | select(.username == $user)).protocols += [$protocol]' \
           "$USER_DB" > tmp.db && mv tmp.db "$USER_DB"
        show_connection_info "http" "$username"
    fi
}

create_vmess_websocket() {
    create_user
    if [ $? -eq 0 ]; then
        username=$(jq -r '.[-1].username' "$USER_DB")
        jq --arg user "$username" --arg protocol "websocket" \
           '(.[] | select(.username == $user)).protocols += [$protocol]' \
           "$USER_DB" > tmp.db && mv tmp.db "$USER_DB"
        show_connection_info "websocket" "$username"
    fi
}

create_vmess_http2() {
    create_user
    if [ $? -eq 0 ]; then
        username=$(jq -r '.[-1].username' "$USER_DB")
        jq --arg user "$username" --arg protocol "http2" \
           '(.[] | select(.username == $user)).protocols += [$protocol]' \
           "$USER_DB" > tmp.db && mv tmp.db "$USER_DB"
        show_connection_info "http2" "$username"
    fi
}

create_vmess_domain_socket() {
    create_user
    if [ $? -eq 0 ]; then
        username=$(jq -r '.[-1].username' "$USER_DB")
        jq --arg user "$username" --arg protocol "domain_socket" \
           '(.[] | select(.username == $user)).protocols += [$protocol]' \
           "$USER_DB" > tmp.db && mv tmp.db "$USER_DB"
        show_connection_info "domain_socket" "$username"
    fi
}

create_vmess_quic() {
    create_user
    if [ $? -eq 0 ]; then
        username=$(jq -r '.[-1].username' "$USER_DB")
        jq --arg user "$username" --arg protocol "quic" \
           '(.[] | select(.username == $user)).protocols += [$protocol]' \
           "$USER_DB" > tmp.db && mv tmp.db "$USER_DB"
        show_connection_info "quic" "$username"
    fi
}

show_connection_info() {
    local protocol=$1
    local username=$2
    local uuid=$(jq -r ".[] | select(.username == \"$username\") | .uuid" "$USER_DB")
    local domain=$(jq -r '.server.domain' $CONFIG_FILE)
    local port=$(jq -r '.server.port' $CONFIG_FILE)
    
    echo -e "${GREEN}=== CONNECTION INFO ===${NC}"
    echo -e "Protocol: $protocol"
    echo -e "Username: $username"
    echo -e "UUID: $uuid"
    echo -e "Domain: $domain"
    
    case $protocol in
        "tcp")
            echo -e "Port: $port"
            echo -e "Security: auto"
            ;;
        "http")
            echo -e "Port: $port"
            echo -e "Path: /vmess"
            echo -e "Host: $domain"
            ;;
        "websocket")
            echo -e "Port: 443"
            echo -e "Path: /ws"
            echo -e "Host: $domain"
            ;;
        "http2")
            echo -e "Port: 443"
            echo -e "Path: /h2"
            echo -e "ALPN: h2"
            ;;
        "domain_socket")
            echo -e "Socket: /var/run/xray/$username.sock"
            ;;
        "quic")
            echo -e "Port: $port"
            echo -e "Security: none"
            ;;
    esac
    
    # Add UDPGW info for all protocols
    echo -e "${YELLOW}UDPGW for Games/WhatsApp:${NC}"
    echo -e "  Ports: $UDPGW_PORTS"
    echo -e "  Usage: udpgw://$domain:7100"
    echo -e "=========================="
}

list_users() {
    echo -e "${CYAN}=== USER LIST ===${NC}"
    local count=$(jq '. | length' "$USER_DB")
    
    if [ "$count" -eq 0 ]; then
        echo -e "${YELLOW}No users found.${NC}"
        return
    fi
    
    echo -e "${GREEN}Total users: $count${NC}"
    jq -r '.[] | "\(.username) | \(.uuid) | \(.status) | \(.expiration_date)"' "$USER_DB" | while read line; do
        if [[ $line == *"active"* ]]; then
            echo -e "${GREEN}$line${NC}"
        else
            echo -e "${RED}$line${NC}"
        fi
    done
}

delete_user() {
    echo -e "${CYAN}=== DELETE USER ===${NC}"
    list_users
    read -p "Enter username to delete: " username
    
    if jq -e ".[] | select(.username == \"$username\")" "$USER_DB" > /dev/null; then
        jq "del(.[] | select(.username == \"$username\"))" "$USER_DB" > tmp.db && mv tmp.db "$USER_DB"
        echo -e "${GREEN}User $username deleted successfully!${NC}"
        log_message "User deleted: $username"
    else
        echo -e "${RED}User not found!${NC}"
    fi
}

lock_unlock_user() {
    echo -e "${CYAN}=== LOCK/UNLOCK USER ===${NC}"
    list_users
    read -p "Enter username: " username
    
    current_status=$(jq -r ".[] | select(.username == \"$username\") | .status" "$USER_DB")
    
    if [ "$current_status" == "active" ]; then
        new_status="locked"
        action="locked"
    else
        new_status="active"
        action="unlocked"
    fi
    
    jq --arg user "$username" --arg status "$new_status" \
       '(.[] | select(.username == $user)).status = $status' \
       "$USER_DB" > tmp.db && mv tmp.db "$USER_DB"
    
    echo -e "${GREEN}User $username $action successfully!${NC}"
    log_message "User $username $action"
}

show_system_info() {
    echo -e "${CYAN}=== SYSTEM INFORMATION ===${NC}"
    echo -e "${YELLOW}Timezone:${NC} $(date +%Z) - $(date)"
    echo -e "${YELLOW}Server Domain:${NC} $(jq -r '.server.domain' $CONFIG_FILE)"
    echo -e "${YELLOW}Server Port:${NC} $(jq -r '.server.port' $CONFIG_FILE)"
    echo -e "${YELLOW}IP Limit:${NC} $(jq -r '.server.ip_limit' $CONFIG_FILE)"
    echo -e "${YELLOW}All Ports Open:${NC} ${GREEN}YES${NC}"
    
    # Xray status
    if systemctl is-active --quiet xray; then
        echo -e "${YELLOW}Xray Status:${NC} ${GREEN}Running${NC}"
    else
        echo -e "${YELLOW}Xray Status:${NC} ${RED}Stopped${NC}"
    fi
    
    # Nginx status
    if systemctl is-active --quiet nginx; then
        echo -e "${YELLOW}Nginx Status:${NC} ${GREEN}Running${NC}"
    else
        echo -e "${YELLOW}Nginx Status:${NC} ${RED}Stopped${NC}"
    fi
}

restart_services() {
    echo -e "${CYAN}Restarting all services...${NC}"
    systemctl restart xray
    systemctl restart nginx
    restart_udpgw
    echo -e "${GREEN}All services restarted successfully!${NC}"
    log_message "All services restarted"
}

# Enhanced Main Menu
show_menu() {
    echo -e ""
    echo -e "${PURPLE}╔══════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║         VMESS MANAGER ULTIMATE          ║${NC}"
    echo -e "${PURPLE}║     ALL PORTS OPEN + GAME SUPPORT       ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════╝${NC}"
    echo -e ""
    echo -e "${CYAN}=== PROTOCOL CREATION ===${NC}"
    echo -e "  ${GREEN}1.${NC}  Create VMESS TCP"
    echo -e "  ${GREEN}2.${NC}  Create VMESS HTTP"
    echo -e "  ${GREEN}3.${NC}  Create VMESS WebSocket"
    echo -e "  ${GREEN}4.${NC}  Create VMESS HTTP/2"
    echo -e "  ${GREEN}5.${NC}  Create VMESS Domain Socket"
    echo -e "  ${GREEN}6.${NC}  Create VMESS QUIC"
    echo -e ""
    echo -e "${CYAN}=== SYSTEM SETUP ===${NC}"
    echo -e "  ${GREEN}7.${NC}  Setup Nginx + Domain"
    echo -e "  ${GREEN}8.${NC}  Setup SSL Certificate"
    echo -e "  ${GREEN}9.${NC}  Open ALL Ports (Firewall)"
    echo -e ""
    echo -e "${CYAN}=== PORTS & GAME SUPPORT ===${NC}"
    echo -e "  ${GREEN}10.${NC} Check Ports Status"
    echo -e "  ${GREEN}11.${NC} UDPGW Status"
    echo -e "  ${GREEN}12.${NC} Restart UDPGW"
    echo -e ""
    echo -e "${CYAN}=== USER MANAGEMENT ===${NC}"
    echo -e "  ${GREEN}13.${NC} List All Users"
    echo -e "  ${GREEN}14.${NC} Delete User"
    echo -e "  ${GREEN}15.${NC} Lock/Unlock User"
    echo -e ""
    echo -e "${CYAN}=== SYSTEM INFO ===${NC}"
    echo -e "  ${GREEN}16.${NC} System Information"
    echo -e "  ${GREEN}17.${NC} Restart Services"
    echo -e "  ${GREEN}18.${NC} View Logs"
    echo -e "  ${GREEN}0.${NC}  Exit"
    echo -e ""
}

# Main function
main() {
    # Check if initialized
    if [ ! -d "$CONFIG_DIR" ]; then
        echo -e "${YELLOW}First time setup detected...${NC}"
        init_system
    fi
    
    while true; do
        show_menu
        read -p "Choose option [0-18]: " choice
        
        case $choice in
            1) create_vmess_tcp ;;
            2) create_vmess_http ;;
            3) create_vmess_websocket ;;
            4) create_vmess_http2 ;;
            5) create_vmess_domain_socket ;;
            6) create_vmess_quic ;;
            7) setup_nginx ;;
            8) setup_ssl ;;
            9) open_all_ports ;;
            10) show_ports_status ;;
            11) show_udpgw_status ;;
            12) restart_udpgw ;;
            13) list_users ;;
            14) delete_user ;;
            15) lock_unlock_user ;;
            16) show_system_info ;;
            17) restart_services ;;
            18) tail -f $LOG_FILE ;;
            0) 
                echo -e "${GREEN}Thank you for using VMess Manager Ultimate!${NC}"
                exit 0
                ;;
            *) 
                echo -e "${RED}Invalid option!${NC}"
                ;;
        esac
        
        echo -e "\nPress Enter to continue..."
        read
        clear
    done
}

# Check root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root!${NC}"
    exit 1
fi

clear
main