FROM alpine:3.24

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
# -D: Don't assign a password
# passwd -u: Unlock the account (allows SSH key authentication)
RUN adduser -D -s /bin/bash tunnel \
    && passwd -u tunnel \
    && mkdir -p /home/tunnel/.ssh \
    && chmod 700 /home/tunnel/.ssh \
    && chown -R tunnel:tunnel /home/tunnel/.ssh

# Copy SSH daemon configuration
COPY sshd_config /etc/ssh/sshd_config

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose SSH port
EXPOSE 2222

# Expose forwarded port for Home Assistant tunnel
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
