# SONiC Configuration Files

This directory contains SONiC switch configuration files from the working PoC.

## Files

### `qos_config_template.json`
QoS configuration template for enabling PFC on SONiC switches. This includes:
- BUFFER_POOL: Ingress and egress lossless buffer pools
- BUFFER_PROFILE: Lossless buffer profiles with dynamic thresholds
- BUFFER_PG: Priority group mappings for ingress traffic
- BUFFER_QUEUE: Queue mappings for egress traffic
- PORT_QOS_MAP: PFC enable configuration for interfaces

**Usage**: This template can be merged into the main config_db.json using the Python script in `scripts/setup/configure_sonic_pfc.sh`

## Configuration Details

### Buffer Pools
- **ingress_lossless_pool**: 12.7 MB dynamic pool for ingress lossless traffic
- **egress_lossless_pool**: 12.7 MB dynamic pool for egress lossless traffic

### Buffer Profiles
- **ingress_lossless_profile**: Uses ingress_lossless_pool with dynamic threshold of 1
- **egress_lossless_profile**: Uses egress_lossless_pool with dynamic threshold of 1

### Interface Mappings
- **Ethernet0|3**: Priority 3 mapping for Ethernet0 (server-facing port)
- **Ethernet4|3**: Priority 3 mapping for Ethernet4 (server-facing port)

### PFC Configuration
- **Priority 3**: Enabled on Ethernet0 and Ethernet4 for RoCE traffic

## Integration into config_db.json

This QoS configuration is merged into the existing config_db.json using Python:

```python
import json

# Load existing config
with open('/etc/sonic/config_db.json', 'r') as f:
    config = json.load(f)

# Load QoS config
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

## Notes

- These configurations were tested on SONiC 202305
- Buffer pool sizes (12766208 = ~12.7 MB) are appropriate for the virtual environment
- Priority 3 is the standard priority for RoCE traffic
- The configuration enables symmetric PFC (both ingress and egress)

---

**Last Updated**: December 30, 2025
