#!/bin/bash

# Check if SSH process is running
if pgrep -x "ssh" > /dev/null; then
    exit 0
else
    exit 1
fi
