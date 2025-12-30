#!/bin/bash
# Run RDMA performance tests
# Usage: ./run_rdma_tests.sh <remote_ip> [device]
# Example: ./run_rdma_tests.sh 172.16.10.103 rxe0

REMOTE_IP=$1
DEVICE=${2:-rxe0}

if [ -z "$REMOTE_IP" ]; then
    echo "Usage: $0 <remote_ip> [device]"
    echo "Example: $0 172.16.10.103 rxe0"
    exit 1
fi

echo "=== RDMA Performance Tests ==="
echo "Remote IP: $REMOTE_IP"
echo "Device: $DEVICE"
echo ""

# Verify device exists
if ! ibv_devices | grep -q "$DEVICE"; then
    echo "ERROR: Device $DEVICE not found"
    echo "Available devices:"
    ibv_devices
    exit 1
fi

# Test 1: Send Bandwidth
echo "======================================"
echo "Test 1: RDMA Send Bandwidth"
echo "======================================"
echo "NOTE: Run this on the REMOTE host first:"
echo "  ib_send_bw -d $DEVICE -F"
echo ""
echo "Press Enter when ready to start sender..."
read

echo "Running: ib_send_bw -d $DEVICE -F $REMOTE_IP"
ib_send_bw -d $DEVICE -F $REMOTE_IP

echo ""
echo "======================================"
echo "Test 2: RDMA Write Bandwidth"
echo "======================================"
echo "NOTE: Run this on the REMOTE host first:"
echo "  ib_write_bw -d $DEVICE -F"
echo ""
echo "Press Enter when ready to start sender..."
read

echo "Running: ib_write_bw -d $DEVICE -F $REMOTE_IP"
ib_write_bw -d $DEVICE -F $REMOTE_IP

echo ""
echo "======================================"
echo "Test 3: RDMA Write (Large Messages)"
echo "======================================"
echo "NOTE: Run this on the REMOTE host first:"
echo "  ib_write_bw -d $DEVICE -F -s 65536 -n 10000"
echo ""
echo "Press Enter when ready to start sender..."
read

echo "Running: ib_write_bw -d $DEVICE -F -s 65536 -n 10000 $REMOTE_IP"
ib_write_bw -d $DEVICE -F -s 65536 -n 10000 $REMOTE_IP

echo ""
echo "=== Tests Complete ==="