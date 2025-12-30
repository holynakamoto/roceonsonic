# Practical PFC Configuration Guide for SONiC 202305

This guide provides step-by-step instructions for configuring Priority Flow Control (PFC) on SONiC switches in the NVIDIA Air lab, based on the actual lab environment.

## Current State

Based on your switch output:
- **VLAN 10**: Configured on Ethernet0 (untagged)
- **VLAN 20**: Configured on Ethernet4 (untagged)
- **PFC Status**: Currently "N/A" (not configured) on all interfaces
- **Interfaces**: Ethernet0 and Ethernet4 are server-facing ports (trunk mode)

## Objective

Enable PFC on Priority 3 for RoCE traffic on server-facing interfaces (Ethernet0 and Ethernet4).

## Step-by-Step Configuration

### Step 1: Backup Current Configuration

```bash
# On leaf01 (or any leaf switch)
admin@leaf01:~$ sudo cp /etc/sonic/config_db.json /etc/sonic/config_db.json.backup
```

### Step 2: View Current ConfigDB Structure

```bash
# View the PORT section to understand current structure
admin@leaf01:~$ sudo cat /etc/sonic/config_db.json | python3 -m json.tool | grep -A 20 '"PORT"'
```

### Step 3: Edit config_db.json

**Option A: Using vi/vim (Recommended for manual editing)**

```bash
admin@leaf01:~$ sudo vi /etc/sonic/config_db.json
```

**Option B: Using config commands (Recommended - safer)**

SONiC provides config commands that are safer than directly editing JSON:

```bash
# First, let's check what PFC configuration options are available
admin@leaf01:~$ config pfc -h
```

However, for SONiC 202305, we may need to edit the JSON directly. Here's what to add:

### Step 4: Add PFC Configuration to config_db.json

Find the `PORT` section in `/etc/sonic/config_db.json` and modify Ethernet0 and Ethernet4 entries:

**Before** (typical structure):
```json
"PORT": {
    "Ethernet0": {
        "alias": "Ethernet0",
        "lanes": "1,2,3,4",
        "speed": "40000",
        ...
    },
    "Ethernet4": {
        "alias": "Ethernet4",
        "lanes": "5,6,7,8",
        "speed": "40000",
        ...
    }
}
```

**After** (add PFC configuration):
```json
"PORT": {
    "Ethernet0": {
        "alias": "Ethernet0",
        "lanes": "1,2,3,4",
        "speed": "40000",
        "pfc_asym": "off",
        "pfc": {
            "3": "on"
        },
        ...
    },
    "Ethernet4": {
        "alias": "Ethernet4",
        "lanes": "5,6,7,8",
        "speed": "40000",
        "pfc_asym": "off",
        "pfc": {
            "3": "on"
        },
        ...
    }
}
```

**Key Points**:
- `"pfc_asym": "off"` - Symmetric PFC (both directions)
- `"pfc": {"3": "on"}` - Enable PFC on Priority 3 (standard for RoCE)

### Step 5: Configure QoS Maps (if not already configured)

Check if QoS maps exist in the config_db.json. You may need to add:

```json
"QOS": {
    "QUEUE": {
        "3": {
            "scheduler": "[SCHEDULER|wrr]"
        }
    },
    "MAP_PFC_PRIORITY_TO_QUEUE": {
        "AZURE": {
            "3": "3"
        }
    }
}
```

**Note**: The QoS structure may already exist. Check first before adding.

### Step 6: Validate JSON Syntax

```bash
# Validate JSON syntax before applying
admin@leaf01:~$ sudo python3 -m json.tool /etc/sonic/config_db.json > /dev/null
```

If this command succeeds without errors, the JSON is valid.

### Step 7: Apply Configuration

```bash
# Reload configuration (recommended - non-disruptive if possible)
admin@leaf01:~$ sudo config reload -y

# OR if config reload doesn't work, reboot (will cause brief downtime)
# admin@leaf01:~$ sudo reboot
```

### Step 8: Verify PFC Configuration

```bash
# Check PFC status on interfaces
admin@leaf01:~$ show priority-flow-control status

# Check interface status (should now show PFC info instead of N/A)
admin@leaf01:~$ show interface status | grep -E "Interface|Ethernet0|Ethernet4"

# Check QoS configuration
admin@leaf01:~$ show qos table
admin@leaf01:~$ show qos table pfc_wd

# Verify interface counters
admin@leaf01:~$ show interface counters Ethernet0
admin@leaf01:~$ show interface counters Ethernet4
```

**Expected Output**: After configuration, `show interface status` should show PFC information instead of "N/A" in the Asym PFC column.

## Alternative: Using SONiC Config Commands

If your SONiC version supports it, you can use config commands instead of editing JSON directly. However, for SONiC 202305, direct JSON editing is often required.

Try these commands first (may not work on all versions):

```bash
# Try to use config command (may not be available)
admin@leaf01:~$ config interface pfc Ethernet0 --help
```

## Complete Example: Ethernet0 Configuration

Here's a complete example showing what the Ethernet0 PORT entry should look like:

```json
"Ethernet0": {
    "admin_status": "up",
    "alias": "Ethernet0",
    "description": "",
    "index": "1",
    "lanes": "1,2,3,4",
    "mtu": "9216",
    "pfc_asym": "off",
    "pfc": {
        "3": "on"
    },
    "speed": "40000"
}
```

## Repeat for Other Leaf Switches

After successfully configuring leaf01, repeat the same steps on:
- leaf02 (Ethernet0 and Ethernet4)
- leaf03 (Ethernet0 and Ethernet4)

## Troubleshooting

### JSON Syntax Errors
If you get errors after editing:
```bash
# Restore backup
admin@leaf01:~$ sudo cp /etc/sonic/config_db.json.backup /etc/sonic/config_db.json
admin@leaf01:~$ sudo config reload -y
```

### PFC Not Showing After Reload
1. Check if the JSON was saved correctly
2. Verify JSON syntax
3. Check SONiC logs: `show logging | grep pfc`
4. Try reboot if config reload didn't apply changes

### Verification Commands Not Working
Some commands may not be available in all SONiC versions. Focus on:
- `show interface status` - should show PFC info
- `show priority-flow-control status` - if available

## Next Steps

After configuring PFC on switches:
1. Verify PFC is enabled on both switch and server interfaces
2. Configure servers for RoCE (see `docs/setup-guide.md`)
3. Run RDMA tests to validate end-to-end functionality
4. Monitor PFC counters during tests

## References

- SONiC ConfigDB Schema: https://github.com/sonic-net/SONiC/wiki/Configuration
- PFC Configuration: See `configs/qos/pfc_config_example.md`

---

**Important**: Always backup config_db.json before making changes. Test on one switch first before applying to all switches.
