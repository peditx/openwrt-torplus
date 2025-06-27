[**English**](README.md) | [**فارسی**](README_fa.md) | [**简体中文**](README-ch.md) | [**Русский**](README_ru.md)

# 🧱 OpenWrt 的 Tor plus，支持 Passwall 和 Passwall2

> ⚡️ **一行命令安装**：

```bash
rm -f *.sh && wget https://raw.githubusercontent.com/peditx/opnwrt-torplus/refs/heads/main/.Files/install.sh && chmod +x install.sh && sh install.sh
```

---

该脚本在 OpenWrt 上安装、配置并管理 Tor 网络，专为伊朗、中国和俄罗斯等受审查国家优化。它设置本地 SOCKS 代理，并通过基于 whiptail 的图形界面安装器和控制器与 Passwall 或 Passwall2 集成。


---

🛠️ 功能特点

使用 whiptail 界面轻松安装

自动安装所需软件包

支持三种桥接类型：snowflake、obfs4、meek，或自动检测

在端口 9050 上配置 Tor SOCKS

通过创建可用的 SOCKS5 节点与 Passwall 或 Passwall2 集成

提供命令行控制面板 tor-control：

启动 / 停止 / 重启 Tor

检查 Tor 状态

使用 check.torproject.org 测试连接

交互式更改桥接类型




---

📡 Tor 控制使用方法

安装完成后，使用控制脚本：

tor-control

你可以：

启动或停止 Tor

重启 Tor

查看连接状态

通过 Tor 代理进行 Ping 测试

重新选择桥接类型并重新配置



---

📂 文件说明

路径	用途

/etc/tor/torrc	Tor 主配置文件，含桥接配置
/usr/bin/tor-control	基于 whiptail 的 Tor 控制面板
/etc/init.d/tor	Tor 服务的启动脚本



---

🔁 与 Passwall 集成

如果检测到 Passwall 或 Passwall2，会创建一个名为 "Tor" 的 SOCKS 节点，地址为 127.0.0.1:9050。

你可以在 Passwall 中将该节点用作出口代理。


---

🧪 测试 Tor 连接

你可以确认你的连接是否通过 Tor：

tor-control → Ping (check.torproject.org)

或手动：

curl --socks5-hostname 127.0.0.1:9050 https://check.torproject.org


---

🧾 许可证

遵循 PeDitX License 授权
📢 Telegram 频道：https://t.me/peditx
