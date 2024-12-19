FROM linuxserver/wireguard:1.0.20210914-legacy

# Install required tools and Docker
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    sudo \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu focal stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update && apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    && rm -rf /var/lib/apt/lists/*

# Apply WireGuard sysctl settings
RUN echo '\n\
echo "Writing sysctl settings" \n\
sysctl -w net.ipv4.conf.all.src_valid_mark=1 \n\
sysctl -w net.ipv4.ip_forward=1' >> /etc/s6-overlay/s6-rc.d/init-wireguard-confs/run

# Fix issue with s6-overlay running as pid 1
ENTRYPOINT [ \
    "unshare", "--pid", "--fork", "--kill-child=SIGTERM", "--mount-proc", \
    "perl", "-e", "$SIG{INT}=''; $SIG{TERM}=''; exec @ARGV;", "--", \
    "/init" ]
