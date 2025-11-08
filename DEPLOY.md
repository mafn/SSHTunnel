# Deployment

## Server

```bash
# Setup directories
sudo mkdir -p /etc/ssh-tunnel/keys
sudo mkdir -p /srv/containers/ssh-tunnel

# Clone repository
cd /srv/containers
git clone https://github.com/mafn/SSHTunnel.git ssh-tunnel

# Generate SSH host keys
sudo ssh-keygen -t ed25519 -f /etc/ssh-tunnel/keys/ssh_host_ed25519_key -N ""
sudo ssh-keygen -t rsa -b 4096 -f /etc/ssh-tunnel/keys/ssh_host_rsa_key -N ""
sudo chmod 600 /etc/ssh-tunnel/keys/*
sudo chmod 700 /etc/ssh-tunnel/keys

# Create environment file
sudo tee /etc/ssh-tunnel/server.env > /dev/null <<EOF
SSH_PORT=2222
FORWARDED_PORT=8080
TZ=UTC
EOF

# Install systemd service
sudo cp /srv/containers/ssh-tunnel/server/ssh-tunnel-server.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now ssh-tunnel-server

# Firewall
sudo firewall-cmd --permanent --add-port=2222/tcp
sudo firewall-cmd --reload
```

## Client

```bash
# Setup directories
sudo mkdir -p /etc/ssh-tunnel/client-keys
sudo mkdir -p /srv/containers/ssh-tunnel

# Clone repository (if not already done)
cd /srv/containers
git clone https://github.com/mafn/SSHTunnel.git ssh-tunnel

# Generate client SSH keys
sudo ssh-keygen -t ed25519 -f /etc/ssh-tunnel/client-keys/id_ed25519 -N ""
sudo chmod 600 /etc/ssh-tunnel/client-keys/*
sudo chmod 700 /etc/ssh-tunnel/client-keys

# Copy public key to server's /etc/ssh-tunnel/keys/authorized_keys
cat /etc/ssh-tunnel/client-keys/id_ed25519.pub

# Get server's host key and add to known_hosts
ssh-keyscan -p 2222 your-server.example.com | sudo tee /etc/ssh-tunnel/client-keys/known_hosts
sudo chmod 644 /etc/ssh-tunnel/client-keys/known_hosts

# Create environment file
sudo tee /etc/ssh-tunnel/client.env > /dev/null <<EOF
SERVER_HOST=your-server.example.com
SERVER_PORT=2222
SERVER_USER=tunnel
LOCAL_HOMEASSISTANT_HOST=host.containers.internal
LOCAL_HOMEASSISTANT_PORT=8123
REMOTE_PORT=8080
TZ=UTC
EOF

# Install Quadlet service
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
