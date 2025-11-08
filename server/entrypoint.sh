#!/bin/bash
set -e

echo "Starting SSH Tunnel Server..."

# First, try to load host keys from persistent volume
if [ -d /ssh-keys ] && [ -f /ssh-keys/ssh_host_ed25519_key ]; then
    echo "Loading host keys from persistent volume..."
    cp -f /ssh-keys/ssh_host_ed25519_key /etc/ssh/
    cp -f /ssh-keys/ssh_host_ed25519_key.pub /etc/ssh/
    cp -f /ssh-keys/ssh_host_rsa_key /etc/ssh/
    cp -f /ssh-keys/ssh_host_rsa_key.pub /etc/ssh/
    chmod 600 /etc/ssh/ssh_host_*_key
    chmod 644 /etc/ssh/ssh_host_*_key.pub
else
    # Only generate if not found in persistent volume
    echo "WARNING: No host keys found in /ssh-keys!"
    echo "Generating temporary SSH host keys (will not persist)..."
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""
    chmod 600 /etc/ssh/ssh_host_*_key
    chmod 644 /etc/ssh/ssh_host_*_key.pub
fi

# Setup authorized_keys for tunnel user
if [ -d /ssh-keys ] && [ -f /ssh-keys/authorized_keys ]; then
    echo "Setting up authorized_keys for tunnel user..."
    cp /ssh-keys/authorized_keys /home/tunnel/.ssh/authorized_keys
    chmod 600 /home/tunnel/.ssh/authorized_keys
    chown tunnel:tunnel /home/tunnel/.ssh/authorized_keys
else
    echo "WARNING: No authorized_keys file found!"
    echo "Create /ssh-keys/authorized_keys with the client's public key"
fi

# Fix permissions
chmod 600 /etc/ssh/ssh_host_*_key
chmod 644 /etc/ssh/ssh_host_*_key.pub
chmod 644 /etc/ssh/sshd_config

# Display server information
echo "==========================================="
echo "SSH Tunnel Server is ready!"
echo "==========================================="
echo "Listening on port 2222"
echo "Forwarded Port: 8080 (for Home Assistant access)"
echo "==========================================="

# Start SSH daemon in foreground with logging to stderr
exec /usr/sbin/sshd -D -e
