# 🚀 VMess Manager Ultimate

All-in-One VMess Management Solution dengan ALL PORTS OPEN!

## ✨ Features
- ✅ All VMess Protocols (TCP, HTTP, WS, HTTP/2, QUIC, Domain Socket)
- ✅ ALL PORTS TCP/UDP OPEN
- ✅ UDPGW for Games (7100, 7200, 7300)
- ✅ Multi-OS Support (Ubuntu, Debian, CentOS, Arch)
- ✅ Auto SSL with Let's Encrypt
- ✅ Nginx Reverse Proxy
- ✅ Game Support (ML, Free Fire, PUBG, WhatsApp Call)

## 🚀 Quick Install
``bash
# Auto install
curl -O https://raw.githubusercontent.com/sukronwae85-design/v


🚀 VMess Manager Ultimate

https://img.shields.io/badge/Version-2.0.0-blue
https://img.shields.io/badge/License-MIT-green
https://img.shields.io/badge/Platform-Ubuntu%2520%257C%2520Debian%2520%257C%2520CentOS%2520%257C%2520Arch-lightgrey

All-in-One VMess Management Solution - Support semua protokol VMess dengan ALL PORTS OPEN untuk koneksi lancar tanpa hambatan!
✨ Fitur Utama
🔌 Protocol Support

    ✅ VMess TCP - Stabil dan kompatibel

    ✅ VMess HTTP - Penyamaran traffic web

    ✅ VMess WebSocket - Support CDN & reverse proxy

    ✅ VMess HTTP/2 - Performa tinggi dengan TLS

    ✅ VMess Domain Socket - Untuk setup advanced

    ✅ VMess QUIC - Low latency UDP-based

🎮 Game & WhatsApp Support

    🕹️ UDPGW Ports 7100, 7200, 7300

    📱 Support Mobile Legends, Free Fire, PUBG Mobile

    💬 Support WhatsApp Call & Video

    🎯 Optimized untuk gaming low latency

🛡️ Security & Management

    🔒 Auto SSL Certificate dengan Let's Encrypt

    🌐 Nginx Reverse Proxy otomatis

    👥 Multi-Login Detection & auto kick

    📊 Bandwidth Monitoring real-time

    🚫 IP Limit & Auto Ban system

    🔥 ALL PORTS TCP/UDP OPEN

⚙️ System Features

    🖥️ Multi-OS Support (Ubuntu, Debian, CentOS, Arch)

    🔥 Firewall Auto Configuration - ALL PORTS OPEN

    📝 Logging System lengkap

    🕐 Timezone Jakarta otomatis

    🚀 Easy Installation one-click

🚀 Quick Installation - Ubuntu
Method 1: Auto Install (Recommended)
bash

# Login sebagai root ke VPS Ubuntu Anda
ssh root@your-vps-ip

# Download dan install otomatis
curl -O https://raw.githubusercontent.com/sukronwae85-design/vmess-tcp-http-quic-ws-cdn-gasspoll/main/install-vmess.sh
chmod +x install-vmess.sh
./install-vmess.sh

Method 2: Manual Install
bash

# Login sebagai root
sudo -i

# Download script utama
wget https://raw.githubusercontent.com/sukronwae85-design/vmess-tcp-http-quic-ws-cdn-gasspoll/main/vmess-manager.sh
chmod +x vmess-manager.sh

# Jalankan
./vmess-manager.sh

Method 3: One-Line Install
bash

# Single command installation
bash <(curl -s https://raw.githubusercontent.com/sukronwae85-design/vmess-tcp-http-quic-ws-cdn-gasspoll/main/install-vmess.sh)

📋 Setup Guide Lengkap - Ubuntu
Step 1: Login dan Persiapan
bash

# Login ke VPS Ubuntu sebagai root
ssh root@your-server-ip

# Update system
apt update && apt upgrade -y

# Install curl jika belum ada
apt install -y curl

Step 2: Install VMess Manager
bash

# Download install script
wget https://raw.githubusercontent.com/sukronwae85-design/vmess-tcp-http-quic-ws-cdn-gasspoll/main/install-vmess.sh

# Beri permission executable
chmod +x install-vmess.sh

# Jalankan install
./install-vmess.sh

Step 3: Setup Awal System

Setelah install selesai, jalankan:
bash

vmess

Kemudian ikuti urutan berikut di menu:
Step 3.1: Setup Nginx & Domain

   Pilih Option 7

   Masukkan domain Anda (contoh: server.kamu.com)

   Tekan Enter untuk port default (8443)

Step 3.2: Setup SSL Certificate

  Pilih Option 8

   SSL akan otomatis terinstall via Let's Encrypt

Step 3.3: Open ALL Ports

  Pilih Option 9

  Semua port TCP/UDP akan terbuka otomatis

Step 3.4: Check UDPGW Status

  Pilih Option 11

  Pastikan status ACTIVE untuk semua port UDPGW

Step 4: Buat User VMess

Pilih salah satu protocol yang diinginkan:

   Option 1 - VMESS TCP (Stabil)

   Option 2 - VMESS HTTP (Penyamaran)
    Option 3 - VMESS WebSocket (Recommended)

   Option 4 - VMESS HTTP/2 (High Security)

   Option 5 - VMESS Domain Socket (Advanced)

  Option 6 - VMESS QUIC (Gaming)

🎯 Protocol Configuration Examples
🔹 VMESS WebSocket (Recommended)
text

Protocol: WebSocket
Address: your-domain.com
Port: 443
Path: /ws
UUID: (auto-generated)
Security: auto

🔹 VMESS TCP (Standard)
text

Protocol: TCP  
Address: your-domain.com
Port: 8443
UUID: (auto-generated)
Security: auto

🔹 VMESS HTTP/2 (Secure)
text

Protocol: HTTP/2
Address: your-domain.com  
Port: 443
Path: /h2
UUID: (auto-generated)
ALPN: h2

🎮 Game Support Setup
Untuk Game & WhatsApp:

Script sudah include UDPGW pada port:

   7100 - Mobile Legends

  7200 - Free Fire

   7300 - PUBG Mobile & WhatsApp Call

Test UDPGW Status:
bash

# Cek status UDPGW
vmess

# Pilih Option 11 untuk melihat status
# Pastikan semua port menunjukkan ACTIVE

🔧 Advanced Configuration
Auto Backup Setup:
bash

# Backup otomatis ke cloud
vmess -> Option 19

# Pilih metode:
# 1. Gmail (Butuh SMTP)
# 2. Telegram (Butuh Bot Token)
# 3. WhatsApp (Butuh Business API)

Monitoring System:
bash

# Cek bandwidth usage
vmess -> Option 15

# Monitor connections
vmess -> Option 16

# System information
vmess -> Option 22

📊 Ports yang Dibuka
TCP Ports (50+ Ports):
text

20, 21, 22, 25, 53, 80, 110, 143, 443, 465, 587, 993, 995, 
2082, 2083, 2086, 2087, 2095, 2096, 3000, 3001, 3306, 3389, 
5432, 8080, 8081, 8082, 8083, 8084, 8085, 8086, 8087, 8088, 
8089, 8090, 8443, 8880, 9000, 9001, 9002, 9003, 9004, 9005, 
9200, 10000, 20000, 27017

UDP Ports (25+ Ports):
text

53, 443, 1194, 1195, 1196, 1197, 1198, 1199, 1300, 1301, 
1302, 1303, 1304, 1305, 7100, 7200, 7300, 8000, 8080, 8443, 
9000, 10000, 20000

🐛 Troubleshooting - Ubuntu
Issue 1: Port Tidak Terbuka
bash

# Reopen semua ports
vmess -> Option 9

# Atau manual
iptables -F
iptables -P INPUT ACCEPT

Issue 2: SSL Certificate Error
bash

# Re-setup SSL
vmess -> Option 8

# Pastikan domain sudah pointing ke IP VPS

Issue 3: UDPGW Tidak Jalan
bash

# Restart UDPGW
vmess -> Option 12

# Check status
vmess -> Option 11

Issue 4: User Tidak Bisa Connect
bash

# Check multi-login
vmess -> Option 17

# Restart services
vmess -> Option 23

🔄 Update Script
bash

# Auto update ke versi terbaru
wget -O vmess-manager.sh https://raw.githubusercontent.com/sukronwae85-design/vmess-tcp-http-quic-ws-cdn-gasspoll/main/vmess-manager.sh
chmod +x vmess-manager.sh
./vmess-manager.sh

📝 Command Reference
Quick Commands:
bash

# Install
curl -O https://raw.githubusercontent.com/sukronwae85-design/vmess-tcp-http-quic-ws-cdn-gasspoll/main/install-vmess.sh && chmod +x install-vmess.sh && ./install-vmess.sh

# Run manager
vmess

# Check services
systemctl status xray
systemctl status nginx

# Check ports
netstat -tulpn | grep -E ':(80|443|8443|7100)'

Service Management:
bash

# Restart semua services
systemctl restart xray nginx

# Check UDPGW
systemctl status badvpn-udpgw-7100

# View logs
tail -f /var/log/vmess-manager.log

🛡️ Security Notes

   ✅ Semua ports terbuka untuk koneksi lancar

  ✅ Auto SSL dengan Let's Encrypt

  ✅ Firewall configured untuk keamanan optimal
   ✅ Multi-login protection untuk prevent abuse

  ✅ Auto backup system

🤝 Support

  📧 Email: sukronwae85@gmail.com

  💬 Telegram: @sukronwae85
    🐛 Issues: GitHub Issues

📄 License

MIT License - bebas digunakan untuk personal dan komersial.
👨‍💻 Author

Sukron Wae

   GitHub: sukronwae85-design

   Telegram: @sukronwae85

🚀 Quick Start Summary
bash

# 1. Login to VPS
ssh root@your-ip

# 2. Install
curl -O https://raw.githubusercontent.com/sukronwae85-design/vmess-tcp-http-quic-ws-cdn-gasspoll/main/install-vmess.sh && chmod +x install-vmess.sh && ./install-vmess.sh

# 3. Run and Setup
vmess

# Follow: 7 -> 8 -> 9 -> 11 -> Create Users

⭐ Jangan lupa kasih star di GitHub jika script ini membantu!

Happy Secure Browsing & Gaming! 🎮🌐
