#!/bin/bash

TORRC_PATH="/etc/tor/torrc"
LOG_PATH="/var/log/tor/notices.log"
TOR_SOCKS_PORT=9050
TOR_CONTROL_PORT=9051

install_dependencies() {
  echo "Installing dependencies..."
  opkg update >/dev/null 2>&1
  opkg install tor curl obfs4proxy snowflake-client >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    whiptail --title "Error" --msgbox "Failed to install one or more dependencies (tor, curl, obfs4proxy, snowflake-client)." 8 70
    exit 1
  fi
}

generate_torrc() {
  local bridge="$1"
  mkdir -p /etc/tor
  mkdir -p /var/log/tor

  cat > "$TORRC_PATH" <<EOF
Log notice file $LOG_PATH
RunAsDaemon 1
SOCKSPort $TOR_SOCKS_PORT
ControlPort $TOR_CONTROL_PORT
CookieAuthentication 1
UseBridges 1
ClientTransportPlugin snowflake exec /usr/bin/snowflake-client
EOF

  case "$bridge" in
    snowflake)
      echo "Bridge snowflake 192.0.2.3:1" >> "$TORRC_PATH"
      ;;
    obfs4)
      echo "Bridge obfs4 1.2.3.4:1234" >> "$TORRC_PATH"
      ;;
    meek)
      echo "Bridge meek 2.3.4.5:443" >> "$TORRC_PATH"
      ;;
    auto)
      echo "Bridge snowflake 192.0.2.3:1" >> "$TORRC_PATH"
      echo "Bridge obfs4 1.2.3.4:1234" >> "$TORRC_PATH"
      echo "Bridge meek 2.3.4.5:443" >> "$TORRC_PATH"
      ;;
  esac
}

install_tor() {
  whiptail --title "Installation" --infobox "Installing Tor package..." 7 50
  opkg install tor >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    whiptail --title "Error" --msgbox "Failed to install Tor package." 8 50
    return 1
  fi

  /etc/init.d/tor enable
  /etc/init.d/tor start

  if service passwall2 status >/dev/null 2>&1; then
    uci set passwall2.TorNode=nodes
    uci set passwall2.TorNode.remarks='Tor-SOCKS'
    uci set passwall2.TorNode.type='Socks'
    uci set passwall2.TorNode.protocol='socks'
    uci set passwall2.TorNode.server='127.0.0.1'
    uci set passwall2.TorNode.port="$TOR_SOCKS_PORT"
    uci set passwall2.TorNode.address='127.0.0.1'
    uci set passwall2.TorNode.tls='0'
    uci set passwall2.TorNode.transport='tcp'
    uci set passwall2.TorNode.tcp_guise='none'
    uci set passwall2.TorNode.tcpMptcp='0'
    uci set passwall2.TorNode.tcpNoDelay='0'
    uci commit passwall2
    whiptail --title "Success" --msgbox "Passwall2 Tor node configured." 8 50
  elif service passwall status >/dev/null 2>&1; then
    uci set passwall.TorNode=nodes
    uci set passwall.TorNode.remarks='Tor-SOCKS'
    uci set passwall.TorNode.type='Socks'
    uci set passwall.TorNode.protocol='socks'
    uci set passwall.TorNode.server='127.0.0.1'
    uci set passwall.TorNode.port="$TOR_SOCKS_PORT"
    uci set passwall.TorNode.address='127.0.0.1'
    uci set passwall.TorNode.tls='0'
    uci set passwall.TorNode.transport='tcp'
    uci set passwall.TorNode.tcp_guise='none'
    uci set passwall.TorNode.tcpMptcp='0'
    uci set passwall.TorNode.tcpNoDelay='0'
    uci commit passwall
    whiptail --title "Success" --msgbox "Passwall Tor node configured." 8 50
  else
    whiptail --title "Warning" --msgbox "Neither Passwall nor Passwall2 found. Skipping configuration." 8 60
  fi
}

show_status() {
  if pgrep tor >/dev/null 2>&1; then
    whiptail --title "Tor Status" --msgbox "Tor service is running." 7 40
  else
    whiptail --title "Tor Status" --msgbox "Tor service is stopped." 7 40
  fi
}

test_tor() {
  if ! pgrep tor >/dev/null 2>&1; then
    whiptail --title "Test" --msgbox "Tor service is not running." 7 40
    return
  fi
  whiptail --title "Test" --infobox "Testing Tor connectivity, please wait..." 7 50
  sleep 3
  local result=$(curl --socks5-hostname 127.0.0.1:$TOR_SOCKS_PORT -s https://check.torproject.org | grep -q "Congratulations" && echo "✅ Tor is working" || echo "❌ Tor is NOT working")
  whiptail --title "Test Result" --msgbox "$result" 8 40
}

change_bridge() {
  local bridge=$(whiptail --title "Select Tor Bridge" --menu "Choose a bridge:" 15 50 4 \
    snowflake "Snowflake (default)" \
    obfs4 "Obfs4 Bridge" \
    meek "Meek Bridge" \
    auto "Auto (all bridges)" 3>&1 1>&2 2>&3)

  if [ -z "$bridge" ]; then
    return
  fi

  generate_torrc "$bridge"
  /etc/init.d/tor restart
  whiptail --title "Bridge Changed" --msgbox "Bridge changed to '$bridge' and Tor restarted." 8 50
}

start_tor() {
  /etc/init.d/tor start
  whiptail --title "Start" --msgbox "Tor service started." 7 40
}

stop_tor() {
  /etc/init.d/tor stop
  whiptail --title "Stop" --msgbox "Tor service stopped." 7 40
}

restart_tor() {
  /etc/init.d/tor restart
  whiptail --title "Restart" --msgbox "Tor service restarted." 7 40
}

main_menu() {
  while true; do
    local choice=$(whiptail --title "Tor Installer & Manager" --menu "Choose an option:" 20 60 10 \
      1 "Install dependencies and Tor & Configure Bridge" \
      2 "Start Tor Service" \
      3 "Stop Tor Service" \
      4 "Restart Tor Service" \
      5 "Show Tor Status" \
      6 "Test Tor Connectivity" \
      7 "Change Bridge" \
      8 "Exit" 3>&1 1>&2 2>&3)

    case "$choice" in
      1)
        install_dependencies
        local bridge=$(whiptail --title "Select Tor Bridge" --menu "Choose a bridge (default snowflake):" 15 50 4 \
          snowflake "Snowflake (default)" \
          obfs4 "Obfs4 Bridge" \
          meek "Meek Bridge" \
          auto "Auto (all bridges)" 3>&1 1>&2 2>&3)
        if [ -z "$bridge" ]; then
          bridge="snowflake"
        fi
        generate_torrc "$bridge"
        install_tor
        ;;
      2)
        start_tor
        ;;
      3)
        stop_tor
        ;;
      4)
        restart_tor
        ;;
      5)
        show_status
        ;;
      6)
        test_tor
        ;;
      7)
        change_bridge
        ;;
      8)
        clear
        exit 0
        ;;
      *)
        whiptail --title "Error" --msgbox "Invalid option." 7 40
        ;;
    esac
  done
}

main_menu
