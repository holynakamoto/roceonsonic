#!/bin/bash
#
# enable_pfc_configdb.sh
#
# Helper script to enable PFC on SONiC switches using config_db.json
# This script helps prepare the PFC configuration but requires manual JSON editing
#
# Usage: ./enable_pfc_configdb.sh <interface>
#
# Example: ./enable_pfc_configdb.sh Ethernet0

set -euo pipefail

INTERFACE="${1:-}"

if [ -z "$INTERFACE" ]; then
    echo "Usage: $0 <interface>"
    echo "Example: $0 Ethernet0"
    echo ""
    echo "This script helps prepare PFC configuration for config_db.json"
    echo "You will need to manually edit /etc/sonic/config_db.json to add:"
    echo "  \"pfc_asym\": \"off\","
    echo "  \"pfc\": {"
    echo "    \"3\": \"on\""
    echo "  }"
    exit 1
fi

echo "=========================================="
echo "PFC Configuration Helper for $INTERFACE"
echo "=========================================="
echo ""

# Check if running as root/sudo
if [ "$EUID" -ne 0 ]; then 
    echo "This script requires sudo privileges"
    echo "Please run: sudo $0 $INTERFACE"
    exit 1
fi

# Backup config_db.json
BACKUP_FILE="/etc/sonic/config_db.json.backup.$(date +%Y%m%d_%H%M%S)"
echo "1. Creating backup: $BACKUP_FILE"
cp /etc/sonic/config_db.json "$BACKUP_FILE" || {
    echo "Error: Failed to backup config_db.json"
    exit 1
}
echo "   Backup created successfully"
echo ""

# Validate current JSON
echo "2. Validating current config_db.json syntax..."
python3 -m json.tool /etc/sonic/config_db.json > /dev/null 2>&1 || {
    echo "Error: Current config_db.json has syntax errors!"
    echo "Restoring backup..."
    cp "$BACKUP_FILE" /etc/sonic/config_db.json
    exit 1
}
echo "   JSON syntax is valid"
echo ""

# Show current PORT entry for the interface
echo "3. Current PORT entry for $INTERFACE:"
echo "-----------------------------------"
python3 << EOF
import json
import sys

try:
    with open('/etc/sonic/config_db.json', 'r') as f:
        config = json.load(f)
    
    if 'PORT' in config and '$INTERFACE' in config['PORT']:
        port_config = config['PORT']['$INTERFACE']
        print(json.dumps(port_config, indent=2))
    else:
        print(f"Error: $INTERFACE not found in PORT section")
        sys.exit(1)
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
EOF

echo ""
echo "=========================================="
echo "Manual Configuration Required"
echo "=========================================="
echo ""
echo "To enable PFC on $INTERFACE, you need to:"
echo ""
echo "1. Edit /etc/sonic/config_db.json:"
echo "   sudo vi /etc/sonic/config_db.json"
echo ""
echo "2. Find the '$INTERFACE' entry in the PORT section"
echo ""
echo "3. Add these lines to the '$INTERFACE' entry:"
echo "   \"pfc_asym\": \"off\","
echo "   \"pfc\": {"
echo "       \"3\": \"on\""
echo "   },"
echo ""
echo "4. Validate JSON syntax:"
echo "   sudo python3 -m json.tool /etc/sonic/config_db.json > /dev/null"
echo ""
echo "5. Apply configuration:"
echo "   sudo config reload -y"
echo ""
echo "6. Verify:"
echo "   show interface status | grep $INTERFACE"
echo "   show priority-flow-control status"
echo ""
echo "Backup location: $BACKUP_FILE"
echo ""

# Offer to show example JSON snippet
read -p "Show example JSON snippet for $INTERFACE? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Example PORT entry with PFC enabled:"
    echo "-----------------------------------"
    echo "{"
    echo "    \"$INTERFACE\": {"
    echo "        \"admin_status\": \"up\","
    echo "        \"alias\": \"$INTERFACE\","
    echo "        \"lanes\": \"...\","
    echo "        \"speed\": \"40000\","
    echo "        \"mtu\": \"9216\","
    echo "        \"pfc_asym\": \"off\","
    echo "        \"pfc\": {"
    echo "            \"3\": \"on\""
    echo "        }"
    echo "    }"
    echo "}"
    echo ""
fi
