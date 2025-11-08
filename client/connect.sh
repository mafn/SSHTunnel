#!/bin/bash
set -e

echo "Starting SSH Tunnel Client..."

# Validate required environment variables
if [ -z "$SERVER_HOST" ]; then
    echo "ERROR: SERVER_HOST environment variable is not set!"
    exit 1
fi

if [ -z "$SERVER_PORT" ]; then
    echo "WARNING: SERVER_PORT not set, using default 2222"
    SERVER_PORT=2222
fi

if [ -z "$LOCAL_HOMEASSISTANT_PORT" ]; then
    echo "WARNING: LOCAL_HOMEASSISTANT_PORT not set, using default 8123"
    LOCAL_HOMEASSISTANT_PORT=8123
fi

if [ -z "$REMOTE_PORT" ]; then
    echo "WARNING: REMOTE_PORT not set, using default 8080"
    REMOTE_PORT=8080
fi

# Setup SSH keys
if [ ! -f /root/.ssh/id_ed25519 ] && [ ! -f /root/.ssh/id_rsa ]; then
    if [ -f /ssh-keys/id_ed25519 ]; then
        echo "Copying ED25519 SSH key from volume..."
        cp /ssh-keys/id_ed25519 /root/.ssh/id_ed25519
        cp /ssh-keys/id_ed25519.pub /root/.ssh/id_ed25519.pub 2>/dev/null || true
        chmod 600 /root/.ssh/id_ed25519
        chmod 644 /root/.ssh/id_ed25519.pub 2>/dev/null || true
    elif [ -f /ssh-keys/id_rsa ]; then
        echo "Copying RSA SSH key from volume..."
        cp /ssh-keys/id_rsa /root/.ssh/id_rsa
        cp /ssh-keys/id_rsa.pub /root/.ssh/id_rsa.pub 2>/dev/null || true
        chmod 600 /root/.ssh/id_rsa
        chmod 644 /root/.ssh/id_rsa.pub 2>/dev/null || true
    else
        echo "ERROR: No SSH private key found!"
        echo "Generate keys using generate-keys.sh and mount them as a volume"
        exit 1
    fi
else
    chmod 600 /root/.ssh/id_ed25519 2>/dev/null || true
    chmod 600 /root/.ssh/id_rsa 2>/dev/null || true
fi

# Create known_hosts file
touch /root/.ssh/known_hosts
chmod 644 /root/.ssh/known_hosts

# Display configuration
echo "==========================================="
echo "SSH Tunnel Configuration:"
echo "==========================================="
echo "Server: $SERVER_HOST:$SERVER_PORT"
echo "Local Home Assistant: ${LOCAL_HOMEASSISTANT_HOST:-host.containers.internal}:$LOCAL_HOMEASSISTANT_PORT"
echo "Remote Port: $REMOTE_PORT"
echo "==========================================="

# Build reverse tunnel command
# -R binds remote port to local port
# Format: -R [remote_port]:localhost:[local_port]
TUNNEL_ARGS="-R ${REMOTE_PORT}:${LOCAL_HOMEASSISTANT_HOST:-host.containers.internal}:${LOCAL_HOMEASSISTANT_PORT}"

# Additional SSH options
SSH_OPTS="-N -T"
SSH_OPTS="$SSH_OPTS -o StrictHostKeyChecking=accept-new"
SSH_OPTS="$SSH_OPTS -o ServerAliveInterval=30"
SSH_OPTS="$SSH_OPTS -o ServerAliveCountMax=3"
SSH_OPTS="$SSH_OPTS -o ExitOnForwardFailure=yes"

# Use autossh for automatic reconnection
export AUTOSSH_GATETIME=0
export AUTOSSH_PORT=0
# Log to stderr for Docker/Podman
export AUTOSSH_DEBUG=1

echo "Establishing reverse SSH tunnel..."
echo "Command: autossh $SSH_OPTS $TUNNEL_ARGS ${SERVER_USER:-tunnel}@$SERVER_HOST -p $SERVER_PORT"

# SSH with verbose logging to stderr
SSH_OPTS="$SSH_OPTS -v"

# Connect with autossh for automatic reconnection
exec autossh $SSH_OPTS $TUNNEL_ARGS ${SERVER_USER:-tunnel}@$SERVER_HOST -p $SERVER_PORT
