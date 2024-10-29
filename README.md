# MTProto Proxy with SOCKS5 Support Docker Image

This Docker image allows you to run a Telegram MTProto proxy server with all network traffic routed through a specified SOCKS5 proxy. It includes support for Random Padding to help evade detection by ISPs and is easy to configure via environment variables and optional configuration files.

**Image Repository:** [`ghcr.io/nick3/mt2socks5`](https://github.com/nick3/mt2socks5/pkgs/container/mt2socks5)

## Features

- **MTProto Proxy Server**: Secure and efficient proxy server for Telegram clients.
- **SOCKS5 Proxy Support**: Routes all MTProto traffic through a specified SOCKS5 proxy using `redsocks`.
- **Random Padding**: Supports the Random Padding feature to help bypass ISP detection.
- **Easy Configuration**: Configure proxy settings using environment variables and optional configuration files.
- **Automatic Updates**: Automatically fetches the latest `proxy-secret` and `proxy-multi.conf` files on startup.

## Getting Started

### Prerequisites

- **Docker** installed on your server.
- **(Optional)** A SOCKS5 proxy server accessible from your Docker host.
- **(Optional)** A proxy tag obtained from [@MTProxybot](https://t.me/MTProxybot) on Telegram for proxy promotion.

### Pulling the Image

To pull the image from GitHub Container Registry:

```bash
docker pull ghcr.io/nick3/mt2socks5
```

### Running the Container

#### Basic Usage (Without SOCKS5 Proxy)

```bash
docker run -d \
    --name mtproxy \
    -p 443:443 \
    -e SECRET=your_secret_key \
    -e TAG=your_proxy_tag \
    -e ENABLE_PADDING=1 \
    ghcr.io/nick3/mt2socks5
```

- `-p 443:443`: Maps port 443 of the container to port 443 of the host.
- `-e SECRET=your_secret_key`: **(Optional)** Sets the secret key clients use to connect. If not provided, a random secret will be generated.
- `-e TAG=your_proxy_tag`: **(Optional)** Sets the proxy tag obtained from [@MTProxybot](https://t.me/MTProxybot).
- `-e ENABLE_PADDING=1`: **(Optional)** Enables Random Padding to help bypass ISP detection.

#### Advanced Usage (With SOCKS5 Proxy)

```bash
docker run -d \
    --name mtproxy \
    -p 443:443 \
    --cap-add=NET_ADMIN \
    -v /path/to/redsocks.conf:/etc/redsocks.conf \
    -e SECRET=your_secret_key \
    -e TAG=your_proxy_tag \
    -e ENABLE_PADDING=1 \
    ghcr.io/nick3/mt2socks5
```

- `--cap-add=NET_ADMIN`: Grants the container permissions to modify network settings, necessary for `redsocks`.
- `-v /path/to/redsocks.conf:/etc/redsocks.conf`: Mounts your custom `redsocks.conf` into the container to configure the SOCKS5 proxy.

### Environment Variables

- `SECRET`: **(Optional)** The secret key clients use to connect. If not set, a random secret will be generated.
- `TAG`: **(Optional)** The proxy tag obtained from [@MTProxybot](https://t.me/MTProxybot).
- `ENABLE_PADDING`: **(Optional)** Set to `1` to enable Random Padding. Default is `0` (disabled).
- `PORT`: **(Optional)** The port the proxy listens on. Default is `443`.
- `STATS_PORT`: **(Optional)** The port for accessing statistics. Default is `8888`.
- `WORKERS`: **(Optional)** The number of worker processes. Default is `1`.
- `USER`: **(Optional)** The user to run the process as. Default is `nobody`.

### Configuring `redsocks.conf`

If you wish to route the MTProto proxy traffic through a SOCKS5 proxy, you need to provide a `redsocks.conf` file.

Example `redsocks.conf`:

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

    ip = 192.168.88.83;    # IP address of your SOCKS5 proxy
    port = 1080;           # Port of your SOCKS5 proxy
    type = socks5;
    login = "";            # Username if authentication is required
    password = "";         # Password if authentication is required
}
```

- Replace `192.168.88.83` and `1080` with the IP address and port of your SOCKS5 proxy.
- If your SOCKS5 proxy requires authentication, provide the `login` and `password`.

### Generating a Secret Key

If you don't provide a `SECRET` environment variable, the container will generate a random secret key.

You can generate a secret key manually using:

```bash
head -c 16 /dev/urandom | xxd -ps
```

### Generating the Connection Link

Once the container is running, you can generate the Telegram connection link for your users:

```text
tg://proxy?server=YOUR_SERVER_IP&port=PORT&secret=SECRET
```

- `YOUR_SERVER_IP`: The public IP address or domain name of your server.
- `PORT`: The port the proxy is listening on (default `443`).
- `SECRET`: The secret key used by the proxy (with `dd` prefix if Random Padding is enabled).

**Example:**

If your server IP is `203.0.113.1`, the port is `443`, and your secret is `dd1234567890abcdef1234567890abcdef`, then the link would be:

```text
tg://proxy?server=203.0.113.1&port=443&secret=dd1234567890abcdef1234567890abcdef
```

### Accessing Statistics

You can access proxy statistics via the stats port:

```bash
curl http://localhost:8888/stats
```

Replace `8888` with the value of `STATS_PORT` if you have changed it.

### Updating `proxy-secret` and `proxy-multi.conf`

The container automatically fetches the latest `proxy-secret` and `proxy-multi.conf` files upon startup, ensuring your proxy stays up-to-date.

## Docker Compose

You can use Docker Compose to manage your container.

Create a `docker-compose.yml` file:

```yaml
version: "3"

services:
  mtproxy:
    image: ghcr.io/nick3/mt2socks5
    container_name: mtproxy
    ports:
      - "443:443"
    environment:
      SECRET: your_secret_key
      TAG: your_proxy_tag
      ENABLE_PADDING: 1
    cap_add:
      - NET_ADMIN
    volumes:
      - /path/to/redsocks.conf:/etc/redsocks.conf
```

Start the container:

```bash
docker-compose up -d
```

## Notes

- **Port Mapping**: If you cannot use port `443`, you can map the container's port `443` to any available port on the host (e.g., `-p 8443:443`). Remember to update the connection link accordingly.
- **Permissions**: The `--cap-add=NET_ADMIN` flag is required when using `redsocks` to route traffic through a SOCKS5 proxy. It grants the necessary permissions to modify network settings within the container.
- **Security**: Running services on port `443` can help evade some ISP restrictions but may attract more attention. Ensure you are compliant with all applicable laws and regulations.
- **Performance**: Routing traffic through a SOCKS5 proxy may impact performance. Monitor the proxy server's load and adjust as necessary.
- **Random Padding**: Enabling Random Padding helps to obfuscate traffic patterns, making it harder for ISPs to detect and block MTProto proxy traffic.

## Troubleshooting

- **Cannot Connect to Proxy**: Ensure that your firewall allows incoming connections on the specified port and that the container is running.
- **SOCKS5 Proxy Not Working**: Check that `redsocks.conf` is correctly configured and that the SOCKS5 proxy is reachable from the Docker host.
- **Random Padding Not Working**: Ensure that `ENABLE_PADDING` is set to `1` and that your secret key in the connection link includes the `dd` prefix.
- **Proxy Tag Not Working**: Ensure that you have correctly registered your proxy with [@MTProxybot](https://t.me/MTProxybot) and that the `TAG` environment variable is set.

## License

This project is provided under the MIT License.

---

**Disclaimer**: This Docker image is intended for educational and legitimate purposes. Ensure that you comply with all applicable laws and regulations when using this software. The author is not responsible for any misuse of this image.

---

Feel free to contribute to the project or report any issues on the [GitHub repository](https://github.com/nick3/mt2socks5).
