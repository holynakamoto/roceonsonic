# Scripts Directory

This directory contains automation scripts for configuring and testing the RoCE PoC environment.

## Directory Structure

```
scripts/
├── setup/              # Initial setup and configuration scripts
├── validation/         # Configuration verification scripts
└── perftest/          # RDMA performance testing scripts
```

## Setup Scripts

### `setup/configure_sonic_pfc.sh`
Configures Priority Flow Control (PFC) on SONiC switches for RoCE traffic (generic helper).

**Usage**:
```bash
./configure_sonic_pfc.sh <switch_name> <interface>
```

**Example**:
```bash
./configure_sonic_pfc.sh leaf1 Ethernet0
```

### `setup/enable_pfc_configdb.sh`
Helper script for enabling PFC via config_db.json on SONiC 202305 (this lab's method).

**Usage**:
```bash
sudo ./enable_pfc_configdb.sh <interface>
```

**Example**:
```bash
sudo ./enable_pfc_configdb.sh Ethernet0
```

**Note**: This script helps prepare the configuration but requires manual JSON editing. See `docs/pfc-configuration-guide.md` for detailed instructions.

### `setup/configure_host_roce.sh`
Configures RoCEv2 on Linux hosts for RDMA operations.

**Usage**:
```bash
sudo ./configure_host_roce.sh <interface> <ip_address> [mtu]
```

**Example**:
```bash
sudo ./configure_host_roce.sh eth0 192.168.1.10/24 9000
```

## Validation Scripts

### `validation/verify_sonic_config.sh`
Validates SONiC switch configuration for lossless Ethernet and RoCE support.

**Usage**:
```bash
./verify_sonic_config.sh <switch_name>
```

**Example**:
```bash
./verify_sonic_config.sh leaf1
```

### `validation/verify_host_roce.sh`
Validates RoCE configuration on Linux hosts.

**Usage**:
```bash
./verify_host_roce.sh [interface]
```

**Example**:
```bash
./verify_host_roce.sh eth0
```

## Performance Testing Scripts

### `perftest/run_rdma_tests.sh`
Runs RDMA performance tests between two hosts using the `perftest` suite.

**Usage**:
```bash
# Server side
./run_rdma_tests.sh server <device> <gid_index>

# Client side
./run_rdma_tests.sh client <device> <gid_index> <server_ip>
```

**Example**:
```bash
# On host1 (server)
./run_rdma_tests.sh server mlx5_0 0

# On host2 (client)
./run_rdma_tests.sh client mlx5_0 0 192.168.1.10
```

## Making Scripts Executable

Before running scripts, make them executable:

```bash
chmod +x scripts/setup/*.sh
chmod +x scripts/validation/*.sh
chmod +x scripts/perftest/*.sh
```

## Notes

- Some scripts require root/sudo privileges (e.g., network configuration)
- Scripts are designed for Ubuntu/Debian-based systems
- Scripts include error handling and verification steps
- Modify scripts as needed for your specific NVIDIA Air lab environment

## Customization

Scripts may need customization based on:
- SONiC version (NVUE vs. config_db.json)
- Interface names in your lab
- IP addressing scheme
- Available RDMA devices

---

**Last Updated**: December 30, 2025
