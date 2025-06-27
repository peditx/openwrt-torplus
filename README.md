[**English**](README.md) | [**فارسی**](README_fa.md) | [**简体中文**](README-ch.md) | [**Русский**](README_ru.md)

# 🧱 Tor plus for OpenWrt with Passwal and Passwall2 

> ⚡️ **One-line installation command**:

```bash
rm -f *.sh && wget https://raw.githubusercontent.com/peditx/openwrt-torplus/refs/heads/main/.Files/install.sh && chmod +x install.sh && sh install.sh
```

---

This script installs, configures, and manages the Tor network on OpenWrt, optimized for censored regions like Iran, China, and Russia. It sets up a local SOCKS proxy and integrates directly with Passwall or Passwall2 using a whiptail-based GUI installer and controller.


---

🛠️ Features

Easy installation using whiptail interface.

Automatically installs required packages.

Supports three bridge types: snowflake, obfs4, meek — or automatic detection.

Configures Tor SOCKS port on 9050.

Integrates with Passwall or Passwall2 by creating a working SOCKS5 node.

Adds a command-line control panel via tor-control:

Start / Stop / Restart Tor

Check Tor status

Test connection with check.torproject.org

Change Bridge type interactively




---

📡 Tor Control Usage

After installation, use the control script:

tor-control

You can:

Start/Stop Tor

Restart it

View connection status

Ping through the Tor proxy

Reselect a different bridge type and reconfigure



---

📂 File Summary

Path	Purpose

/etc/tor/torrc	Tor main configuration with bridges
/usr/bin/tor-control	Whiptail-based Tor control panel
/etc/init.d/tor	Init script for Tor service



---

🔁 Passwall Integration

If Passwall or Passwall2 is detected, a new SOCKS node named "Tor" will be created at 127.0.0.1:9050.

Use this node as an outbound proxy within your Passwall setup.


---

🧪 Test Your Tor Connection

You can verify that your connection is routed through Tor:

tor-control → Ping (check.torproject.org)

Or manually:

curl --socks5-hostname 127.0.0.1:9050 https://check.torproject.org


---

🧾 License

Licensed under PeDitX License
📢 Telegram Channel: https://t.me/peditx
