#!/bin/bash

# Script to generate SSH keys for the client

KEYS_DIR="./ssh-keys"

echo "Generating SSH keys for tunnel client..."

# Create keys directory if it doesn't exist
mkdir -p "$KEYS_DIR"
chmod 700 "$KEYS_DIR"

# Generate client key pair
echo "Generating ED25519 key pair (recommended)..."
ssh-keygen -t ed25519 -f "$KEYS_DIR/id_ed25519" -N "" -C "SSH Tunnel Client ED25519"

echo "Generating RSA key pair (4096-bit, for compatibility)..."
ssh-keygen -t rsa -b 4096 -f "$KEYS_DIR/id_rsa" -N "" -C "SSH Tunnel Client RSA"

chmod 600 "$KEYS_DIR/id_ed25519" "$KEYS_DIR/id_rsa"
chmod 644 "$KEYS_DIR/id_ed25519.pub" "$KEYS_DIR/id_rsa.pub"

echo ""
echo "==========================================="
echo "SSH keys generated successfully!"
echo "==========================================="
echo ""
echo "Public key (ED25519 - RECOMMENDED):"
cat "$KEYS_DIR/id_ed25519.pub"
echo ""
echo "Public key (RSA 4096-bit - for compatibility):"
cat "$KEYS_DIR/id_rsa.pub"
echo ""
echo "==========================================="
echo "Next steps:"
echo "1. Copy the ED25519 public key (recommended) to your server:"
echo "   cat $KEYS_DIR/id_ed25519.pub | ssh user@server 'cat >> ~/ssh-tunnel/server/ssh-keys/authorized_keys'"
echo ""
echo "   Or manually add it to: server/ssh-keys/authorized_keys"
echo ""
echo "2. If using ED25519, update client Dockerfile to use id_ed25519 instead of id_rsa"
echo "3. Configure your server connection in .env file"
echo "4. Start the client with: docker-compose up -d"
echo ""
