#!/bin/sh

# PeDitXOS Tools - TORPlus Uninstaller
# This script will completely remove TORPlus and its related configurations.
set -e

# --- Colors for output ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Helper Functions ---
log_info() {
    printf "${BLUE}[i] %s${NC}\n" "$1"
}

log_success() {
    printf "${GREEN}[✓] %s${NC}\n" "$1"
}

# --- Main Uninstall Logic ---
log_info "Starting the TORPlus uninstaller..."
echo "-----------------------------------------"

# 1. Stop and disable the TOR service
log_info "Stopping and disabling the Tor service..."
/etc/init.d/tor stop >/dev/null 2>&1 || true
/etc/init.d/tor disable >/dev/null 2>&1 || true
log_success "Tor service stopped and disabled."

# 2. Remove Passwall/Passwall2 Tor node configuration
log_info "Removing Tor node from Passwall/Passwall2..."
if uci show passwall2 >/dev/null 2>&1; then
    uci delete passwall2.TorNode >/dev/null 2>&1 || true
    uci commit passwall2
fi
if uci show passwall >/dev/null 2>&1; then
    uci delete passwall.TorNode >/dev/null 2>&1 || true
    uci commit passwall
fi
log_success "Passwall configurations removed."

# 3. Remove UCI configuration file
log_info "Removing TORPlus UCI config file..."
rm -f /etc/config/torplus
log_success "UCI config file removed."

# 4. Remove Tor configuration file
log_info "Removing main torrc file..."
rm -f /etc/tor/torrc
log_success "torrc file removed."

# 5. Remove all LuCI files
log_info "Removing LuCI UI files..."
rm -f /usr/lib/lua/luci/controller/torplus.lua
rm -rf /usr/lib/lua/luci/view/torplus
# Also remove old files just in case
rm -f /usr/lib/lua/luci/model/cbi/torplus_manager.lua
rm -f /usr/lib/lua/luci/view/torplus_status_section.htm
log_success "LuCI files removed."

# 6. Remove log files
log_info "Removing log files..."
rm -f /tmp/peditxos_torplus_log.txt
rm -f /tmp/torplus_debug.log
log_success "Log files cleaned up."

# 7. Uninstall packages
log_info "Uninstalling packages (tor, snowflake-client, obfs4proxy, etc.)..."
opkg remove tor ca-certificates snowflake-client obfs4proxy >/dev/null 2>&1 || true
log_success "Dependent packages removed."

# 8. Clear LuCI cache and restart web server
log_info "Clearing LuCI cache and restarting web server..."
rm -f /tmp/luci-indexcache
/etc/init.d/uhttpd restart
log_success "UI reloaded."

echo "-----------------------------------------"
log_success "TORPlus has been completely uninstalled."
log_info "Please hard-refresh your browser (Ctrl+Shift+R)."

exit 0
