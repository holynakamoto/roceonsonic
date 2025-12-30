#!/bin/bash
# Verify host RoCE configuration
# Usage: ./verify_host_roce.sh

echo "=== Host RoCE Configuration Verification ==="
echo ""

PASS=true

echo "1. RDMA Devices:"
echo "----------------"
ibv_devices

if ibv_devices | grep -q "rxe0"; then
    echo "✅ rxe0 device found"
else
    echo "❌ rxe0 device NOT found"
    PASS=false
fi

echo ""
echo "2. RDMA Links:"
echo "--------------"
rdma link show

if rdma link show | grep -q "rxe0.*ACTIVE"; then
    echo "✅ rxe0 link is ACTIVE"
else
    echo "❌ rxe0 link is NOT active"
    PASS=false
fi

echo ""
echo "3. Kernel Modules:"
echo "------------------"
lsmod | grep -E "rdma_rxe|ib_core|ib_uverbs"

if lsmod | grep -q "rdma_rxe"; then
    echo "✅ rdma_rxe module loaded"
else
    echo "❌ rdma_rxe module NOT loaded"
    PASS=false
fi

echo ""
echo "4. Network Interface (eth1):"
echo "----------------------------"
if ip addr show eth1 &> /dev/null; then
    ip addr show eth1 | grep -E "inet |state"
    echo "✅ eth1 interface exists"
else
    echo "❌ eth1 interface NOT found"
    PASS=false
fi

echo ""
if [ "$PASS" = true ]; then
    echo "=== All Checks Passed ✅ ==="
    exit 0
else
    echo "=== Some Checks Failed ❌ ==="
    exit 1
fi