# Setup Guide: RoCE PoC on SONiC with NVIDIA Air

This guide provides step-by-step instructions to set up and configure the RoCE-enabled lossless Ethernet fabric in NVIDIA Air.

## Table of Contents
1. [NVIDIA Air Setup](#nvidia-air-setup)
2. [Lab Selection](#lab-selection)
3. [Topology Overview](#topology-overview)
4. [SONiC Switch Configuration](#sonic-switch-configuration)
5. [Host Configuration](#host-configuration)
6. [Validation](#validation)
7. [RDMA Testing](#rdma-testing)

## 1. NVIDIA Air Setup

### 1.1 Account Creation
1. Navigate to https://air.nvidia.com/
2. Register for a free account (if not already registered)
3. Log into the NVIDIA Air dashboard

### 1.2 Accessing Labs
- Navigate to the "Labs" section
- Search for "SONiC BGP EVPN VXLAN" or similar SONiC-based lab
- Ensure the lab includes:
  - Minimum 2 leaf switches
  - 1-2 spine switches
  - 2+ Ubuntu host servers
  - Virtual Spectrum switches

## 2. Lab Selection

**Recommended Lab**: SONiC Numbered BGP EVPN VXLAN Demo

**Lab Components**:
- **Spine Switches**: `spine01`, `spine02`
- **Leaf Switches**: `leaf01`, `leaf02`, `leaf03`
- **Servers**: `server01` through `server06` (Ubuntu 18.04)

**Topology Details**: See `docs/lab-topology.md` for complete topology information.

**Network Interfaces**:
- Server interfaces: `eth0` (mgmt), `eth1` (data/VLAN)
- Switch interfaces: `Ethernet0`, `Ethernet4` (server-facing), `Ethernet8`, `Ethernet12` (spine-facing)
- IP addressing: See `docs/lab-topology.md` for complete IPAM table

## 3. Topology Overview

```
                    [spine01]        [spine02]
                       |                |
        [leaf01] --------|--------       |-------- [leaf02]
           |            |                |            |
        [server01]  [server02]    [server03]    [server04]
        
        [leaf03]
           |
        [server05]    [server06]
```

**VLANs**:
- **VLAN 10**: server01 (172.16.10.101), server03 (172.16.10.103), server05 (172.16.10.105)
- **VLAN 20**: server02 (172.16.20.102), server04 (172.16.20.104), server06 (172.16.20.106)

**Traffic Path Example**: server01 (VLAN10) → leaf01 → spine01 → leaf02 → server03 (VLAN10)

**Note**: This lab uses SONiC 202305 with config_db.json (not NVUE). See `docs/lab-topology.md` for detailed topology information.

## 4. SONiC Switch Configuration

### 4.1 Enable Priority Flow Control (PFC)

**Note**: This lab uses SONiC 202305 with config_db.json method (not NVUE).

#### Using config_db.json (This Lab's Method)
```bash
# Connect to switch via SSH from oob-mgmt-server
ssh admin@leaf01
# Password: YourPaSsWoRd

# Edit config_db.json to enable PFC
sudo vi /etc/sonic/config_db.json
# Or use config commands via SONiC CLI

# After editing, apply configuration
sudo config reload -y
```

**Configuration Method**: This lab uses split-unified mode where:
- Switch configuration (PFC, QoS, VLANs) is managed via ConfigDB
- Routing configuration (BGP, FRR) is managed separately

See `configs/qos/pfc_config_example.md` for detailed configuration examples.

**Practical Step-by-Step Guide**: See `docs/pfc-configuration-guide.md` for a detailed walkthrough with actual lab examples.

### 4.2 Configure QoS Maps for RoCE

**DSCP to Priority Mapping**:
```bash
# Map DSCP 46 (EF) to priority 3 for RoCE traffic
# See configs/qos/ for complete examples
```

### 4.3 Verification Commands
```bash
# Show PFC status
show priority-flow-control status

# Show QoS configuration
show qos table pfc_wd

# Show interface statistics
show interface counters
```

**Note**: Use scripts in `scripts/setup/` for automated configuration.

## 5. Host Configuration

### 5.1 Install RDMA Tools

```bash
# On each host, update package lists
sudo apt-get update

# Install RDMA tools (if available)
sudo apt-get install -y rdma-core rdma-core-dev libibverbs-dev

# Install perftest (RDMA performance tests)
sudo apt-get install -y perftest

# Alternatively, attempt MLNX_OFED installation
# (may not be fully available in simulation)
```

### 5.2 Enable RoCEv2

```bash
# Check for RDMA-capable devices
ibv_devices

# Show device details
ibstat

# Enable RoCE on interface (if needed)
# Configure interface MTU (recommended: 9000 for jumbo frames)
sudo ip link set dev <interface> mtu 9000

# Set interface up
sudo ip link set dev <interface> up
```

### 5.3 Configure IP Addressing

**Note**: In this lab, servers already have IP addresses configured on `eth1`:
- VLAN 10 servers: server01 (172.16.10.101), server03 (172.16.10.103), server05 (172.16.10.105)
- VLAN 20 servers: server02 (172.16.20.102), server04 (172.16.20.104), server06 (172.16.20.106)

Verify existing configuration:
```bash
# Check interface configuration
ip addr show eth1

# Verify connectivity to same-VLAN peers
# From server01 (VLAN 10):
ping 172.16.10.103 -c 3  # server03
ping 172.16.10.105 -c 3  # server05

# From server02 (VLAN 20):
ping 172.16.20.104 -c 3  # server04
ping 172.16.20.106 -c 3  # server06
```

If reconfiguration is needed:
```bash
# Configure IP address on RoCE interface
sudo ip addr add <IP_ADDRESS>/<CIDR> dev <interface>

# Set MTU for RoCE (recommended: 9000)
sudo ip link set dev <interface> mtu 9000
```

**Note**: Use scripts in `scripts/setup/` for automated host configuration. Scripts will detect existing IPs and configure MTU.

## 6. Validation

### 6.1 Switch Validation

```bash
# Verify PFC configuration
show priority-flow-control status

# Check QoS maps
show qos table

# Monitor interface counters for packet drops
show interface counters detailed
```

### 6.2 Host Validation

```bash
# List RDMA devices
ibv_devices

# Show device status
ibstat

# Query device capabilities
ibv_devinfo

# Test connectivity (if supported)
ibping <peer_guid>
```

## 7. RDMA Testing

### 7.1 Bandwidth Test (ib_write_bw)

**Server Side** (host1):
```bash
ib_write_bw -d <device> -x <gid_index>
```

**Client Side** (host2):
```bash
ib_write_bw -d <device> -x <gid_index> <server_ip>
```

### 7.2 Latency Test (ib_send_lat)

**Server Side** (host1):
```bash
ib_send_lat -d <device> -x <gid_index>
```

**Client Side** (host2):
```bash
ib_send_lat -d <device> -x <gid_index> <server_ip>
```

### 7.3 Additional Tests

```bash
# Read bandwidth
ib_read_bw -d <device> -x <gid_index>

# Send bandwidth
ib_send_bw -d <device> -x <gid_index>

# Atomic operations (if supported)
ib_atomic_bw -d <device> -x <gid_index>
```

**Note**: Use scripts in `scripts/perftest/` for automated testing.

## Troubleshooting

### Common Issues

#### 1. Missing QoS Configuration in SONiC

**Problem**: SONiC 202305 lab has no default QoS/buffer configuration in config_db.json

**Symptoms**:
- PFC configuration doesn't take effect
- `show pfc priority` shows no PFC enabled
- Buffer configuration commands fail or show empty

**Solution**:
1. Use the provided `scripts/setup/configure_sonic_pfc.sh` script which creates complete QoS configuration
2. The script merges BUFFER_POOL, BUFFER_PROFILE, BUFFER_PG, BUFFER_QUEUE, and PORT_QOS_MAP into config_db.json
3. Verify with `show pfc priority` and `show buffer configuration`

**Reference**: See `configs/sonic/qos_config_template.json` for the QoS configuration template

#### 2. Config CLI Command Limitations

**Problem**: `config interface pfc priority` command doesn't work or can't find interfaces

**Symptoms**:
- CLI commands for PFC configuration fail
- Error messages about interfaces not found
- Configuration doesn't apply

**Solution**:
1. Bypass CLI limitations by directly editing config_db.json
2. Use the Python script approach in `scripts/setup/configure_sonic_pfc.sh`
3. The script safely merges QoS JSON into config_db.json
4. Apply using `config reload -y` instead of individual CLI commands

**Reference**: See `docs/pfc-configuration-guide.md` for detailed steps

#### 3. Missing Kernel Modules for Soft-RoCE

**Problem**: rdma_rxe module not found when trying to load

**Symptoms**:
- `modprobe rdma_rxe` fails with "module not found"
- Cannot create rxe0 device
- `ibv_devices` shows no devices

**Solution**:
1. Install kernel modules: `sudo apt install linux-modules-extra-$(uname -r)`
2. If specific version not found, try: `sudo apt install linux-modules-extra`
3. Verify module is available: `modinfo rdma_rxe`
4. Load module: `sudo modprobe rdma_rxe`
5. Verify: `lsmod | grep rdma_rxe`

**Reference**: The `scripts/setup/configure_host_roce.sh` script handles this automatically

#### 4. No RDMA Devices Found

**Problem**: After configuring RoCE, `ibv_devices` shows no devices

**Symptoms**:
- `ibv_devices` returns empty or error
- `rdma link show` shows no links
- Cannot run RDMA tests

**Solution**:
1. Verify rdma_rxe module is loaded: `lsmod | grep rdma_rxe`
2. Check if rxe0 device exists: `rdma link show`
3. If not, create it: `sudo rdma link add rxe0 type rxe netdev eth1`
4. Verify: `ibv_devices` should show rxe0
5. Check interface is up: `ip link show eth1`

#### 5. PFC Not Showing After Configuration

**Problem**: After configuring PFC, `show pfc priority` doesn't show PFC enabled

**Symptoms**:
- PFC configuration applied but not visible in show commands
- Interface status shows "N/A" for PFC

**Solution**:
1. Verify config_db.json was edited correctly
2. Check JSON syntax: `sudo python3 -m json.tool /etc/sonic/config_db.json`
3. Ensure config was reloaded: `sudo config reload -y`
4. Wait for services to stabilize (10-30 seconds)
5. Check if PORT_QOS_MAP section exists with pfc_enable: "3"
6. Verify buffer configuration is present

#### 6. RDMA Tests Fail to Connect

**Problem**: RDMA tests fail to establish connection between hosts

**Symptoms**:
- `ib_send_bw` or `ib_write_bw` fails to connect
- Connection timeout errors
- "Address already in use" errors

**Solution**:
1. Verify IP connectivity: `ping <remote_ip>`
2. Check firewall rules (usually not an issue in labs)
3. Ensure rxe0 device exists on both hosts: `ibv_devices`
4. Verify both server and client are running (not both as server)
5. Check if port is already in use (stop other RDMA tests)
6. Use correct device name (rxe0 for soft-RoCE, not mlx5_0)

#### 7. PFC Counters Show All Zeros

**Problem**: PFC counters show zeros even during tests

**Symptoms**:
- `show pfc counters` shows all zeros
- Cannot verify PFC is working

**Analysis**:
- This is actually expected and indicates PFC is working correctly!
- Zero counters mean no congestion occurred, so no pause frames were sent
- PFC is enabled and ready, but not triggered because there's no congestion
- This is the ideal scenario for lossless operation

**Solution**:
- No action needed - zeros indicate successful configuration
- To see PFC in action, would need to generate congestion (beyond PoC scope)

## Next Steps

After successful setup:
1. Run comprehensive RDMA tests using `scripts/perftest/run_rdma_tests.sh`
2. Capture screenshots of configurations and results
3. Document findings in `docs/results.md`
4. Verify PFC configuration with `scripts/validation/verify_sonic_config.sh`
5. Verify host configuration with `scripts/validation/verify_host_roce.sh`

---

**Last Updated**: December 30, 2025
