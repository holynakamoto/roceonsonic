# SONiC PFC and QoS Configuration Examples

This document provides configuration examples for enabling Priority Flow Control (PFC) and QoS for RoCE traffic on SONiC switches.

## Configuration Methods

SONiC supports multiple configuration methods:
1. **NVUE** (SONiC 202211 and later) - Recommended for newer versions
2. **config_db.json** - Traditional method, works on all versions (used in this lab)
3. **SONiC CLI** - Interactive configuration

**Note**: The SONiC Numbered BGP EVPN VXLAN Demo lab uses SONiC 202305 with config_db.json method (not NVUE).

## config_db.json Configuration (This Lab's Method)

This lab uses SONiC 202305 which requires config_db.json configuration. See below for the primary method.

## NVUE Configuration (For Reference - Not Used in This Lab)

### Enable PFC on Interface

```bash
# Connect to switch via SSH
# Enable PFC on an interface
nvue set interface <interface_name> link pause type pfc
nvue config apply
```

Example:
```bash
nvue set interface Ethernet0 link pause type pfc
nvue config apply
```

### Configure QoS for RoCE Traffic

```bash
# Map DSCP 46 (EF - Expedited Forwarding) to Priority 3 for RoCE
nvue set qos map dscp-to-tc dscp 46 traffic-class 3
nvue set qos map tc-to-pg traffic-class 3 priority-group 3
nvue set qos map pfc-priority-to-pg pfc-priority 3 priority-group 3
nvue config apply
```

## config_db.json Configuration (Actual Working Method)

### Complete PFC Configuration

**Note**: SONiC 202305 requires complete buffer/QoS configuration, not just PORT entries.

The working configuration includes these sections:
- BUFFER_POOL (ingress/egress lossless pools)
- BUFFER_PROFILE (lossless profiles)
- BUFFER_PG (priority group mappings)
- BUFFER_QUEUE (queue mappings)
- PORT_QOS_MAP (PFC enable configuration)

See `configs/sonic/qos_config_template.json` for the complete template.

### Using the Configuration Script

The recommended approach is to use the provided script:

```bash
sudo scripts/setup/configure_sonic_pfc.sh
```

This script:
1. Backs up config_db.json
2. Creates complete QoS configuration
3. Merges it into config_db.json using Python
4. Validates JSON syntax
5. Applies configuration with `config reload -y`
6. Verifies PFC is enabled

### Manual Configuration (Advanced)

If you need to configure manually, use the Python merge approach:

```python
import json

# Load existing config
with open('/etc/sonic/config_db.json', 'r') as f:
    config = json.load(f)

# Load QoS config (from qos_config_template.json)
with open('qos_config_template.json', 'r') as f:
    qos_config = json.load(f)

# Merge QoS config into main config
for section, data in qos_config.items():
    if section not in config:
        config[section] = {}
    config[section].update(data)

# Write back
with open('/etc/sonic/config_db.json', 'w') as f:
    json.dump(config, f, indent=4)
```

### Apply Configuration

```bash
# Validate JSON syntax first
sudo python3 -m json.tool /etc/sonic/config_db.json > /dev/null

# Apply configuration (recommended - non-disruptive if possible)
sudo config reload -y

# Or restart switch if needed (will cause brief downtime)
# sudo reboot
```

## Verification Commands

### Check PFC Status
```bash
show priority-flow-control status
```

### Check QoS Configuration
```bash
show qos table
show qos table pfc_wd
```

### Check Interface Statistics
```bash
show interface counters
show interface counters Ethernet0
```

### Monitor PFC Counters
```bash
# Watch PFC counters in real-time
watch -n 1 'show priority-flow-control status'
```

## DSCP to Priority Mapping for RoCE

**Recommended Mapping**:
- **DSCP 46 (EF)**: Expedited Forwarding - Use for RoCE traffic
- **Priority 3**: Map to priority group 3 with PFC enabled
- **Priority 4**: Alternative for lossless RoCE traffic

### Complete QoS Map Example

```bash
# DSCP to Traffic Class mapping
DSCP 46 → Traffic Class 3

# Traffic Class to Priority Group
Traffic Class 3 → Priority Group 3

# PFC Priority to Priority Group
PFC Priority 3 → Priority Group 3

# Enable PFC on Priority 3
```

## ECN Configuration (Optional)

For Explicit Congestion Notification:

```bash
# Enable ECN on interfaces (if supported)
nvue set interface <interface> link ecn enable
nvue config apply
```

## Troubleshooting

### PFC Not Working
1. Verify PFC is enabled on both ends (switch and host)
2. Check link status: `show interface status`
3. Verify auto-negotiation: `show interface transceiver`

### Packet Drops
1. Check interface counters: `show interface counters`
2. Verify QoS configuration: `show qos table`
3. Check PFC counters: `show priority-flow-control status`

## References

- SONiC QoS Configuration: https://github.com/sonic-net/SONiC/wiki/QoS
- NVIDIA Spectrum QoS Guide
- RFC 3168 (ECN)

---

**Note**: Configuration examples may vary based on SONiC version. Always verify with `show` commands after applying configuration.
