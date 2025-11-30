#!/bin/bash
echo "=========================================="
echo "   VMESS MANAGER ULTIMATE - AUTO INSTALL"
echo "   GitHub: sukronwae85-design/vmess-tcp-http-quic-ws-cdn-gasspoll"
echo "=========================================="

# Download main script
wget -O /usr/local/bin/vmess-manager https://raw.githubusercontent.com/sukronwae85-design/vmess-tcp-http-quic-ws-cdn-gasspoll/main/vmess-manager.sh
chmod +x /usr/local/bin/vmess-manager

# Create symlink
ln -sf /usr/local/bin/vmess-manager /usr/bin/vmess

echo ""
echo "✅ Installation Complete!"
echo "Usage: vmess"
echo "Quick Start: vmess -> Option 7 -> 8 -> 9"