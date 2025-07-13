#!/bin/sh

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${MAGENTA} 
 ______      _____   _      _    _     _____       
(_____ \    (____ \ (_)_   \ \  / /   / ___ \      
 _____) )___ _   \ \ _| |_  \ \/ /   | |   | | ___ 
|  ____/ _  ) |   | | |  _)  )  (    | |   | |/___)
| |   ( (/ /| |__/ /| | |__ / /\ \   | |___| |___ |
|_|    \____)_____/ |_|\___)_/  \_\   \_____/(___/ 
                                                   
                            E Z P A S S W A L L v3.1.2 ${NC}"
sleep 3
# Install required packages (except whiptail which user must already have)
opkg update
opkg install tor ca-certificates curl coreutils-base64

# Ask user for Bridge type using whiptail
BRIDGE=$(whiptail --title "Tor Bridge Selector" --radiolist \
"Choose a Tor Bridge type for censored countries:" 15 60 4 \
"snowflake" "Default and most reliable" ON \
"obfs4" "Obfuscated transport layer" OFF \
"meek" "Meek (Azure CDN based)" OFF \
"auto" "Try all and pick the first working" OFF 3>&1 1>&2 2>&3)

# Setup bridge based on selection
case "$BRIDGE" in
  snowflake)
    echo "UseBridges 1
ClientTransportPlugin snowflake exec /usr/bin/snowflake-client
Bridge snowflake 192.0.2.1:1" > /etc/tor/torrc
    ;;
  obfs4)
    echo "UseBridges 1
ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy
Bridge obfs4 192.0.2.2:2 cert=ABC iat-mode=0" > /etc/tor/torrc
    ;;
  meek)
    echo "UseBridges 1
ClientTransportPlugin meek exec /usr/bin/meek-client
Bridge meek 192.0.2.3:3 url=https://ajax.aspnetcdn.com/ delay=1000" > /etc/tor/torrc
    ;;
  auto)
    echo "UseBridges 1
ClientTransportPlugin snowflake exec /usr/bin/snowflake-client
Bridge snowflake 192.0.2.1:1
ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy
Bridge obfs4 192.0.2.2:2 cert=ABC iat-mode=0
ClientTransportPlugin meek exec /usr/bin/meek-client
Bridge meek 192.0.2.3:3 url=https://ajax.aspnetcdn.com/ delay=1000" > /etc/tor/torrc
    ;;
esac

# Enable Tor SOCKS on port 9050
echo "SocksPort 9050" >> /etc/tor/torrc

# Enable and start Tor
/etc/init.d/tor enable
/etc/init.d/tor restart

#### Configure Passwall or Passwall2
#if service passwall2 status > /dev/null 2>&1; then
#    uci set passwall2.TorNode=nodes
#    uci set passwall2.TorNode.remarks='Tor'
#    uci set passwall2.TorNode.type='Xray'
#    uci set passwall2.TorNode.protocol='socks'
#    uci set passwall2.TorNode.server='127.0.0.1'
#    uci set passwall2.TorNode.port='9050'
#    uci set passwall2.TorNode.address='127.0.0.1'
#    uci set passwall2.TorNode.transport='tcp'
#    uci commit passwall2
#    echo -e "${GREEN}Passwall2 Tor node configured.${NC}"
#elif service passwall status > /dev/null 2>&1; then
#    uci set passwall.TorNode=nodes
#    uci set passwall.TorNode.remarks='Tor'
#    uci set passwall.TorNode.type='Xray'
#    uci set passwall.TorNode.protocol='socks'
#    uci set passwall.TorNode.server='127.0.0.1'
#    uci set passwall.TorNode.port='9050'
#    uci set passwall.TorNode.address='127.0.0.1'
#    uci set passwall.TorNode.transport='tcp'
#    uci commit passwall
#    echo -e "${GREEN}Passwall Tor node configured.${NC}"
#else
#    echo -e "${RED}Passwall or Passwall2 not found! Skipping node config.${NC}"
#fi
#####

# Configure Passwall or Passwall2 for Tor
if service passwall2 status > /dev/null 2>&1; then
    uci set passwall2.TorNode=nodes
    uci set passwall2.TorNode.remarks='Tor'
    uci set passwall2.TorNode.type='Xray'
    uci set passwall2.TorNode.protocol='socks'
    uci set passwall2.TorNode.server='127.0.0.1'
    uci set passwall2.TorNode.port='9050'
    uci set passwall2.TorNode.address='127.0.0.1'
    uci set passwall2.TorNode.tls='0'
    uci set passwall2.TorNode.transport='tcp'
    uci set passwall2.TorNode.tcp_guise='none'
    uci set passwall2.TorNode.tcpMptcp='0'
    uci set passwall2.TorNode.tcpNoDelay='0'

    uci commit passwall2
    echo -e "${GREEN}Passwall2 Tor node configured successfully.${NC}"

elif service passwall status > /dev/null 2>&1; then
    uci set passwall.TorNode=nodes
    uci set passwall.TorNode.remarks='Tor'
    uci set passwall.TorNode.type='Xray'
    uci set passwall.TorNode.protocol='socks'
    uci set passwall.TorNode.server='127.0.0.1'
    uci set passwall.TorNode.port='9050'
    uci set passwall.TorNode.address='127.0.0.1'
    uci set passwall.TorNode.tls='0'
    uci set passwall.TorNode.transport='tcp'
    uci set passwall.TorNode.tcp_guise='none'
    uci set passwall.TorNode.tcpMptcp='0'
    uci set passwall.TorNode.tcpNoDelay='0'

    uci commit passwall
    echo -e "${GREEN}Passwall Tor node configured successfully.${NC}"

else
    echo -e "${RED}Passwall or Passwall2 not found! Skipping Tor node configuration.${NC}"
fi


# Create tor-control script
cat << 'EOF' > /usr/bin/tor-control
#!/bin/sh

echo -e "${MAGENTA} 
 ______      _____   _      _    _     _____       
(_____ \    (____ \ (_)_   \ \  / /   / ___ \      
 _____) )___ _   \ \ _| |_  \ \/ /   | |   | | ___ 
|  ____/ _  ) |   | | |  _)  )  (    | |   | |/___)
| |   ( (/ /| |__/ /| | |__ / /\ \   | |___| |___ |
|_|    \____)_____/ |_|\___)_/  \_\   \_____/(___/ 
                                                   
                            E Z P A S S W A L L v3.1.2 ${NC}"
sleep 3

ACTION=$(whiptail --title "Tor Control Menu" --menu "Select Action:" 15 50 6 \
"start" "Start Tor" \
"stop" "Stop Tor" \
"restart" "Restart Tor" \
"status" "Show Tor status" \
"ping" "Ping through Tor SOCKS" \
"change-bridge" "Re-run installer to change Bridge" 3>&1 1>&2 2>&3)

case "$ACTION" in
  start)
    /etc/init.d/tor start
    ;;
  stop)
    /etc/init.d/tor stop
    ;;
  restart)
    /etc/init.d/tor restart
    ;;
  status)
    ps | grep tor | grep -v grep && echo "Tor is running" || echo "Tor is NOT running"
    ;;
  ping)
    curl --socks5-hostname 127.0.0.1:9050 https://check.torproject.org
    ;;
  change-bridge)
    rm -f *.sh
    wget https://raw.githubusercontent.com/peditx/openwrt-torplus/refs/heads/main/.Files/install.sh
    sh install.sh
    ;;
esac
EOF

chmod +x /usr/bin/tor-control

echo -e "${GREEN}Installation complete! You can now use ${NC}tor-control${GREEN} to manage Tor.${NC}"
