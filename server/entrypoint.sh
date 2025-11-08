#!/bin/bash
set -e

echo "Starting SSH Tunnel Server..."

# Generate host keys if they don't exist
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
    echo "Generating SSH host keys..."
    # Generate ED25519 key (modern, fast, secure)
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
    # Generate RSA key (4096-bit for compatibility)
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""
    
    # Copy host keys to persistent volume if it exists
    if [ -d /ssh-keys ]; then
        cp -f /etc/ssh/ssh_host_* /ssh-keys/ 2>/dev/null || true
    fi
else
    echo "Using existing SSH host keys"
fi

# Copy host keys from persistent volume if available
if [ -d /ssh-keys ]; then
    if [ -f /ssh-keys/ssh_host_ed25519_key ]; then
        echo "Copying host keys from persistent volume (read-only)..."
        cp -f /ssh-keys/ssh_host_ed25519_key /etc/ssh/ 2>/dev/null || true
        cp -f /ssh-keys/ssh_host_ed25519_key.pub /etc/ssh/ 2>/dev/null || true
        cp -f /ssh-keys/ssh_host_rsa_key /etc/ssh/ 2>/dev/null || true
        cp -f /ssh-keys/ssh_host_rsa_key.pub /etc/ssh/ 2>/dev/null || true
        chmod 600 /etc/ssh/ssh_host_*_key
        chmod 644 /etc/ssh/ssh_host_*_key.pub
    fi
    
    # Setup authorized_keys for tunnel user
    if [ -f /ssh-keys/authorized_keys ]; then
        echo "Setting up authorized_keys for tunnel user..."
        cp /ssh-keys/authorized_keys /home/tunnel/.ssh/authorized_keys
        chmod 600 /home/tunnel/.ssh/authorized_keys
        chown tunnel:tunnel /home/tunnel/.ssh/authorized_keys
    else
        echo "WARNING: No authorized_keys file found!"
        echo "Create /ssh-keys/authorized_keys with the client's public key"
    fi
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
