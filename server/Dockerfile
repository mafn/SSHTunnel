FROM alpine:3.21

# Install OpenSSH server
RUN apk add --no-cache \
    openssh-server \
    openssh-keygen \
    bash \
    && rm -rf /var/cache/apk/*

# Create necessary directories
RUN mkdir -p /var/run/sshd \
    && mkdir -p /root/.ssh \
    && chmod 700 /root/.ssh

# Create a dedicated user for the tunnel
RUN adduser -D -s /bin/bash tunnel \
    && mkdir -p /home/tunnel/.ssh \
    && chmod 700 /home/tunnel/.ssh \
    && chown -R tunnel:tunnel /home/tunnel/.ssh

# Copy SSH daemon configuration
COPY sshd_config /etc/ssh/sshd_config

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose SSH port (mapped to non-22 in docker-compose to avoid host conflict)
EXPOSE 22

# Expose forwarded port for Home Assistant tunnel
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
