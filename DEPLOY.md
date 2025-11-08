# Deployment

## Server

```bash
# Pull image
podman pull ghcr.io/mafn/sshtunnel/server:latest

# Setup
sudo mkdir -p /etc/ssh-tunnel/keys
sudo mkdir -p /srv/containers/ssh-tunnel
sudo ssh-keygen -t ed25519 -f /etc/ssh-tunnel/keys/ssh_host_ed25519_key -N ""
sudo chmod 600 /etc/ssh-tunnel/keys/*
cat > /etc/ssh-tunnel/server.env <<EOF
SSH_PORT=2222
FORWARDED_PORT=8080
TZ=UTC
EOF

# Install service (copy from /srv/containers/ssh-tunnel repo)
sudo cp /srv/containers/ssh-tunnel/server/ssh-tunnel-server.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now ssh-tunnel-server

# Firewall
sudo firewall-cmd --permanent --add-port=2222/tcp
sudo firewall-cmd --reload
```

## Client

```bash
# Pull image
podman pull ghcr.io/mafn/sshtunnel/client:latest

# Setup
sudo mkdir -p /etc/ssh-tunnel/client-keys
sudo ssh-keygen -t ed25519 -f /etc/ssh-tunnel/client-keys/id_ed25519 -N ""
sudo chmod 600 /etc/ssh-tunnel/client-keys/*

# Copy public key to server's /etc/ssh-tunnel/keys/authorized_keys
cat /etc/ssh-tunnel/client-keys/id_ed25519.pub

# Get server's host key and add to known_hosts
ssh-keyscan -p 2222 your-server.example.com | sudo tee /etc/ssh-tunnel/client-keys/known_hosts

# Create /etc/ssh-tunnel/client.env
cat > /etc/ssh-tunnel/client.env <<EOF
SERVER_HOST=your-server.example.com
SERVER_PORT=2222
SERVER_USER=tunnel
LOCAL_HOMEASSISTANT_HOST=host.containers.internal
LOCAL_HOMEASSISTANT_PORT=8123
REMOTE_PORT=8080
TZ=UTC
EOF

# Install Quadlet service (copy from /srv/containers/ssh-tunnel repo)
sudo mkdir -p /etc/containers/systemd
sudo cp /srv/containers/ssh-tunnel/client/ssh-tunnel-client.container /etc/containers/systemd/
sudo systemctl daemon-reload
sudo systemctl enable --now ssh-tunnel-client.service
```

## NGINX (Server)

See `examples/nginx/` for full configuration.

```bash
# Copy configs
sudo cp examples/nginx/cloud-ips.map /etc/nginx/
sudo cp examples/nginx/homeassistant.conf /etc/nginx/conf.d/

# Add to /etc/nginx/nginx.conf in http{} block:
#   include /etc/nginx/cloud-ips.map;

# Update YOUR_DOMAIN.com in homeassistant.conf
sudo systemctl reload nginx
```

## Updates

Auto-updates enabled via `podman-auto-update.timer`:

## Logs

```bash
sudo journalctl -u ssh-tunnel-server -f
sudo journalctl -u ssh-tunnel-client -f
```
