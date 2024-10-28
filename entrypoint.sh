#!/bin/bash

set -e

# 如果映射了 redsocks.conf，则启动 redsocks
if [ -f /etc/redsocks.conf ]; then
	echo "检测到 /etc/redsocks.conf，启动 redsocks..."

	# 启动 redsocks
	redsocks -c /etc/redsocks.conf

	# 配置 iptables 规则
	iptables -t nat -N REDSOCKS

	# 排除本地和保留地址
	iptables -t nat -A REDSOCKS -d 0.0.0.0/8 -j RETURN
	iptables -t nat -A REDSOCKS -d 10.0.0.0/8 -j RETURN
	iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN
	iptables -t nat -A REDSOCKS -d 169.254.0.0/16 -j RETURN
	iptables -t nat -A REDSOCKS -d 172.16.0.0/12 -j RETURN
	iptables -t nat -A REDSOCKS -d 192.168.0.0/16 -j RETURN
	iptables -t nat -A REDSOCKS -d 224.0.0.0/4 -j RETURN
	iptables -t nat -A REDSOCKS -d 240.0.0.0/4 -j RETURN

	# 将所有 TCP 流量重定向到 redsocks
	iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 12345

	# 应用 REDSOCKS 规则到 OUTPUT 链
	iptables -t nat -A OUTPUT -p tcp -j REDSOCKS
else
	echo "未检测到 /etc/redsocks.conf，跳过 redsocks 配置。"
fi

# 启动 MTProto 代理
exec mtproto-proxy "$@"
