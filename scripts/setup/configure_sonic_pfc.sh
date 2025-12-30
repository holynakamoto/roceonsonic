#!/bin/bash
# Configure PFC on SONiC switch for RoCE
# Usage: sudo ./configure_sonic_pfc.sh
# Must be run on SONiC switch as admin user

set -e

echo "=== SONiC PFC Configuration Script ==="
echo "Configuring PFC on priority 3 for Ethernet0 and Ethernet4"
echo ""

# Check if running on SONiC
if ! command -v show &> /dev/null; then
    echo "ERROR: This script must be run on a SONiC switch"
    exit 1
fi

# Backup current config
echo "Backing up configuration..."
sudo cp /etc/sonic/config_db.json /etc/sonic/config_db.json.backup.$(date +%Y%m%d_%H%M%S)

# Create QoS configuration template
echo "Creating QoS configuration..."
cat > /tmp/qos_config.json << 'QOSEOF'
{
    "BUFFER_POOL": {
        "ingress_lossless_pool": {
            "mode": "dynamic",
            "size": "12766208",
            "type": "ingress"
        },
        "egress_lossless_pool": {
            "mode": "dynamic",
            "size": "12766208",
            "type": "egress"
        }
    },
    "BUFFER_PROFILE": {
        "ingress_lossless_profile": {
            "pool": "ingress_lossless_pool",
            "size": "0",
            "dynamic_th": "1"
        },
        "egress_lossless_profile": {
            "pool": "egress_lossless_pool",
            "size": "0",
            "dynamic_th": "1"
        }
    },
    "BUFFER_PG": {
        "Ethernet0|3": {
            "profile": "ingress_lossless_profile"
        },
        "Ethernet4|3": {
            "profile": "ingress_lossless_profile"
        }
    },
    "BUFFER_QUEUE": {
        "Ethernet0|3": {
            "profile": "egress_lossless_profile"
        },
        "Ethernet4|3": {
            "profile": "egress_lossless_profile"
        }
    },
    "PORT_QOS_MAP": {
        "Ethernet0": {
            "pfc_enable": "3"
        },
        "Ethernet4": {
            "pfc_enable": "3"
        }
    }
}
QOSEOF

# Merge QoS configuration
echo "Merging QoS configuration into config_db.json..."
sudo python3 << 'PYTHONEOF'
import json

# Load existing config
with open('/etc/sonic/config_db.json', 'r') as f:
    config = json.load(f)

# Load QoS config
with open('/tmp/qos_config.json', 'r') as f:
    qos_config = json.load(f)

# Merge QoS sections
for section, data in qos_config.items():
    if section not in config:
        config[section] = {}
    config[section].update(data)

# Write back
with open('/etc/sonic/config_db.json', 'w') as f:
    json.dump(config, f, indent=4)

print("Configuration merged successfully")
PYTHONEOF

# Validate JSON
echo "Validating JSON syntax..."
sudo python3 -m json.tool /etc/sonic/config_db.json > /dev/null
if [ $? -eq 0 ]; then
    echo "JSON validation: PASS"
else
    echo "JSON validation: FAIL - restoring backup"
    sudo cp /etc/sonic/config_db.json.backup.* /etc/sonic/config_db.json
    exit 1
fi

# Apply configuration
echo ""
echo "Applying configuration (reloading SONiC services)..."
sudo config reload -y

# Wait for stabilization
echo "Waiting 10 seconds for services to stabilize..."
sleep 10

# Verify
echo ""
echo "=== Verification ==="
show pfc priority | grep -E "Interface|Ethernet0|Ethernet4"

echo ""
echo "Buffer pools:"
show buffer configuration | head -15

# Save configuration
echo ""
echo "Saving configuration..."
sudo config save -y

echo ""
echo "=== Configuration Complete ==="
echo "✅ PFC enabled on priority 3 for Ethernet0 and Ethernet4"