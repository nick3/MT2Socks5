FROM ubuntu:20.04

# 安装必要的依赖
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git build-essential libssl-dev zlib1g-dev curl \
    iptables redsocks

# 克隆 MTProto 代理的源代码
RUN git clone https://github.com/TelegramMessenger/MTProxy.git /opt/MTProxy

# 编译 MTProto 代理
RUN cd /opt/MTProxy && make && mv objs/bin/mtproto-proxy /usr/local/bin/

# 复制入口脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 暴露 MTProto 代理的端口（默认是 443）
EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]