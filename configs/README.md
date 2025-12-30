# Configuration Files Directory

This directory contains configuration files and examples for SONiC switches and QoS settings.

## Directory Structure

```
configs/
├── sonic/          # SONiC switch configuration files
└── qos/            # QoS and PFC configuration examples
```

## SONiC Configuration

### Switch Configuration Files
Place SONiC switch configuration files in the `sonic/` directory:
- `config_db.json` - Complete SONiC configuration database
- NVUE configuration snippets
- Interface-specific configurations

### Configuration Examples

See `qos/pfc_config_example.md` for detailed PFC and QoS configuration examples.

## QoS Configuration

### Priority Flow Control (PFC)
- Enable PFC on interfaces carrying RoCE traffic
- Configure appropriate priority levels (typically Priority 3 for RoCE)

### DSCP Mapping
- Map DSCP 46 (EF) to appropriate traffic class
- Configure traffic class to priority group mapping

## Usage Notes

1. **Customization Required**: Configuration files are templates/examples. Customize based on:
   - Your NVIDIA Air lab topology
   - Interface names in your lab
   - IP addressing scheme
   - SONiC version (NVUE vs. config_db.json)

2. **Verification**: Always verify configurations using SONiC CLI commands:
   ```bash
   show priority-flow-control status
   show qos table
   show interface counters
   ```

3. **Backup**: Save original configurations before applying changes

---

**Last Updated**: December 30, 2025
