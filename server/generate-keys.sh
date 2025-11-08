#!/bin/bash

# Script to generate SSH keys for the server

KEYS_DIR="./ssh-keys"

echo "Generating SSH keys for tunnel server..."

# Create keys directory if it doesn't exist
mkdir -p "$KEYS_DIR"
chmod 700 "$KEYS_DIR"

# Generate host keys
echo "Generating host keys..."
# ED25519 (recommended - modern, fast, secure, 256-bit)
ssh-keygen -t ed25519 -f "$KEYS_DIR/ssh_host_ed25519_key" -N "" -C "SSH Tunnel Server ED25519"

# RSA 4096-bit (for compatibility with older clients)
ssh-keygen -t rsa -b 4096 -f "$KEYS_DIR/ssh_host_rsa_key" -N "" -C "SSH Tunnel Server RSA"

# Create authorized_keys file (empty - will be populated with client's public key)
touch "$KEYS_DIR/authorized_keys"
chmod 600 "$KEYS_DIR/authorized_keys"

echo ""
echo "==========================================="
echo "SSH host keys generated successfully!"
echo "==========================================="
echo ""
echo "Next steps:"
echo "1. Generate client keys on your Raspberry Pi (run client/generate-keys.sh)"
echo "2. Copy the client's public key (client/ssh-keys/id_rsa.pub) to this file:"
echo "   $KEYS_DIR/authorized_keys"
echo ""
echo "Example:"
echo "  cat ../client/ssh-keys/id_rsa.pub >> $KEYS_DIR/authorized_keys"
echo ""
