#!/bin/bash

set -e

# 检查并设置默认值
PORT=${PORT:-443}
STATS_PORT=${STATS_PORT:-8888}
WORKERS=${WORKERS:-1}
SECRET=${SECRET}
TAG=${TAG}
USER=${USER:-nobody}

# 如果未提供 SECRET，则生成一个
if [ -z "$SECRET" ]; then
	echo "未提供 SECRET，生成一个随机的..."
	SECRET=$(head -c 16 /dev/urandom | xxd -ps)
fi

# 显示配置信息
echo "MTProxy 配置信息："
echo "----------------------------------------"
echo "端口 (PORT)           : $PORT"
echo "统计端口 (STATS_PORT) : $STATS_PORT"
echo "工作进程数 (WORKERS)  : $WORKERS"
echo "用户 (USER)           : $USER"
echo "SECRET                : $SECRET"
if [ ! -z "$TAG" ]; then
	echo "TAG                   : $TAG"
fi
echo "----------------------------------------"

# 获取最新的 proxy-secret 和 proxy-multi.conf
echo "获取最新的 proxy-secret 和 proxy-multi.conf..."
curl -s https://core.telegram.org/getProxySecret -o /opt/MTProxy/proxy-secret
curl -s https://core.telegram.org/getProxyConfig -o /opt/MTProxy/proxy-multi.conf

# 构建 mtproto-proxy 命令参数
CMD_ARGS="-u $USER -p $STATS_PORT -H $PORT -S $SECRET --aes-pwd /opt/MTProxy/proxy-secret /opt/MTProxy/proxy-multi.conf -M $WORKERS"

# 如果提供了 TAG，则添加参数
if [ ! -z "$TAG" ]; then
	CMD_ARGS="$CMD_ARGS -P $TAG"
fi

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

# 启动 mtproto-proxy
echo "启动 mtproto-proxy..."
exec mtproto-proxy $CMD_ARGS
