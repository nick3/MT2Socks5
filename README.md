# MT2Socks5

## Docker Image Usage

### Pulling the Docker Image

To pull the Docker image from GitHub Packages, use the following command:

```sh
docker pull ghcr.io/nick3/mtproto-proxy:latest
```

### Running the Docker Container

To run the Docker container, use the following command:

```sh
docker run -d \
  --name mtproto-proxy \
  -p 8443:443 \
  -v $(pwd)/redsocks.conf:/etc/redsocks.conf \
  ghcr.io/nick3/mtproto-proxy:latest
```

### Configuring redsocks.conf

Make sure to configure the `redsocks.conf` file according to your needs. The `redsocks.conf` file should be mapped to `/etc/redsocks.conf` inside the container.

### redsocks.conf Example

Here is an example of a `redsocks.conf` file:

```conf
base {
    log_debug = off;
    log_info = on;
    daemon = on;
    redirector = iptables;
}

redsocks {
    local_ip = 127.0.0.1;
    local_port = 12345;

    ip = [SOCKS5代理IP];  # 您的 SOCKS5 代理的 IP
    port = [SOCKS5代理端口];  # 您的 SOCKS5 代理的端口
    type = socks5;
    login = "";  # 如需认证，请填写用户名
    password = "";  # 如需认证，请填写密码
}
```
