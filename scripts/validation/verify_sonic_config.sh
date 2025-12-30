#!/bin/bash
# Verify SONiC PFC configuration
# Usage: ./verify_sonic_config.sh

echo "=== SONiC PFC Configuration Verification ==="
echo ""

# Check if running on SONiC
if ! command -v show &> /dev/null; then
    echo "ERROR: Must be run on SONiC switch"
    exit 1
fi

PASS=true

echo "1. PFC Priority Configuration:"
echo "------------------------------"
show pfc priority | grep -E "Interface|Ethernet0|Ethernet4"

if show pfc priority | grep -E "Ethernet0.*3"; then
    echo "✅ Ethernet0: PFC priority 3 enabled"
else
    echo "❌ Ethernet0: PFC priority 3 NOT enabled"
    PASS=false
fi

if show pfc priority | grep -E "Ethernet4.*3"; then
    echo "✅ Ethernet4: PFC priority 3 enabled"
else
    echo "❌ Ethernet4: PFC priority 3 NOT enabled"
    PASS=false
fi

echo ""
echo "2. Buffer Configuration:"
echo "------------------------"
if show buffer configuration | grep -q "ingress_lossless_pool"; then
    echo "✅ Lossless buffer pools configured"
    show buffer configuration | grep -E "Pool:|mode|size|type" | head -8
else
    echo "❌ Lossless buffer pools NOT configured"
    PASS=false
fi

echo ""
echo "3. PFC Counters:"
echo "----------------"
show pfc counters | head -8

echo ""
echo "4. Interface Status:"
echo "--------------------"
show interface status | grep -E "Interface|Ethernet0|Ethernet4"

echo ""
if [ "$PASS" = true ]; then
    echo "=== All Checks Passed ✅ ==="
    exit 0
else
    echo "=== Some Checks Failed ❌ ==="
    exit 1
fi