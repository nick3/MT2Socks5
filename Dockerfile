FROM ubuntu:20.04

# 安装必要的依赖
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git build-essential libssl-dev zlib1g-dev curl \
    iptables redsocks

# 获取 MTProxy 源代码并编译
RUN git clone https://github.com/TelegramMessenger/MTProxy.git /opt/MTProxy && \
    cd /opt/MTProxy && \
    make && \
    mv objs/bin/mtproto-proxy /usr/local/bin/

# 获取 proxy-secret 和 proxy-multi.conf
RUN curl -s https://core.telegram.org/getProxySecret -o /opt/MTProxy/proxy-secret && \
    curl -s https://core.telegram.org/getProxyConfig -o /opt/MTProxy/proxy-multi.conf

# 复制入口脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 暴露默认端口
EXPOSE 443 8888

ENTRYPOINT ["/entrypoint.sh"]