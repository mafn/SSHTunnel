FROM alpine:3.22

# Install OpenSSH client and autossh for persistent connections
RUN apk add --no-cache \
    openssh-client \
    autossh \
    bash \
    curl \
    && rm -rf /var/cache/apk/*

# Create SSH directory
RUN mkdir -p /root/.ssh \
    && chmod 700 /root/.ssh

# Copy SSH client configuration
COPY ssh_config /root/.ssh/config

# Copy connection script
COPY connect.sh /connect.sh
RUN chmod +x /connect.sh

# Copy healthcheck script
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh

ENTRYPOINT ["/connect.sh"]
