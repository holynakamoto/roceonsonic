#!/bin/bash
# Configure soft-RoCE on Ubuntu host
# Usage: ./configure_host_roce.sh [interface]
# Default interface: eth1

set -e

INTERFACE=${1:-eth1}

echo "=== Host RoCE Configuration ==="
echo "Configuring soft-RoCE on interface: $INTERFACE"
echo ""

# Verify running on Ubuntu
if ! command -v apt &> /dev/null; then
    echo "ERROR: This script requires Ubuntu/Debian"
    exit 1
fi

# Verify interface exists
if ! ip link show $INTERFACE &> /dev/null; then
    echo "ERROR: Interface $INTERFACE not found"
    echo "Available interfaces:"
    ip link show
    exit 1
fi

# Install RDMA packages
echo "Installing RDMA packages..."
sudo apt update
sudo apt install -y rdma-core perftest ibverbs-utils libibverbs-dev

# Install kernel modules (critical for soft-RoCE)
echo "Installing kernel modules..."
sudo apt install -y linux-modules-extra-$(uname -r)

# Load rdma_rxe module
echo "Loading rdma_rxe kernel module..."
sudo modprobe rdma_rxe

# Verify module loaded
if ! lsmod | grep -q rdma_rxe; then
    echo "ERROR: Failed to load rdma_rxe module"
    exit 1
fi

# Create rxe device
echo "Creating rxe0 device on $INTERFACE..."
sudo rdma link add rxe0 type rxe netdev $INTERFACE

# Verify device
echo ""
echo "=== Verification ==="
echo "RDMA Devices:"
ibv_devices

echo ""
echo "RDMA Links:"
rdma link show

echo ""
echo "Interface $INTERFACE status:"
ip addr show $INTERFACE | grep "inet "

echo ""
echo "=== Configuration Complete ==="
echo "✅ Soft-RoCE device rxe0 created on $INTERFACE"
echo ""
echo "Next steps:"
echo "  1. Test connectivity: ping <remote_host>"
echo "  2. Run receiver: ib_send_bw -d rxe0 -F"
echo "  3. Run sender: ib_send_bw -d rxe0 -F <remote_ip>"