# Quick Start Guide

## ✅ Current Status

This PoC has been **successfully completed**! All infrastructure is configured and working:

| Component | Status | Details |
|-----------|--------|---------|
| **Switches** | ✅ Complete | 3x leaf switches with PFC on priority 3 |
| **Hosts** | ✅ Complete | 6x servers with soft-RoCE configured |
| **Tests** | ✅ Passing | 20-23 MB/sec, zero packet loss |
| **Documentation** | ✅ Complete | Full setup guide and results |

**Want to reproduce this?** Follow the steps below.

---

This guide provides a rapid overview to get started with the RoCE PoC project.

## Prerequisites Checklist

- [ ] NVIDIA Air account (https://air.nvidia.com/)
- [ ] Access to SONiC lab in NVIDIA Air
- [ ] Basic familiarity with Linux CLI and networking

## Current Status ✅

### What Works
- ✅ PFC configured on leaf01, leaf02, leaf03 (priority 3, Ethernet0/4)
- ✅ Soft-RoCE configured on server01, server03
- ✅ RDMA tests passing with ~23 MB/sec bandwidth
- ✅ Zero packet loss demonstrated
- ✅ PFC ready to activate on congestion

### PoC Results Summary
- **Switch Configuration**: PFC enabled on all server-facing ports
- **Host Configuration**: Soft-RoCE (rxe0) devices active on test servers
- **RDMA Performance**: ~23 MB/sec bandwidth, zero packet loss
- **Validation**: All functional requirements met

See `docs/results.md` for comprehensive results and analysis.

## Lab Environment

**NVIDIA Air Lab**: SONiC Numbered BGP EVPN VXLAN Demo

**Key Information**:
- **Topology**: 3 leaves (leaf01-03), 2 spines (spine01-02), 6 servers (server01-06)
- **VLANs**: VLAN 10 (server01,03,05) and VLAN 20 (server02,04,06)
- **Access**: Via oob-mgmt-server (ubuntu/nvidia), then SSH to devices
- **SONiC Version**: 202305 (uses config_db.json, not NVUE)

See `docs/lab-topology.md` for complete topology and IP addressing details.

## 5-Minute Overview

### 1. Project Structure
```
roceonsonic/
├── README.md              # Main project documentation
├── PRD.md                 # Product Requirements Document
├── docs/                  # Detailed documentation
│   ├── setup-guide.md    # Step-by-step setup instructions
│   └── results.md        # Test results template
├── scripts/               # Automation scripts
│   ├── setup/            # Configuration scripts
│   ├── validation/       # Verification scripts
│   └── perftest/         # RDMA test scripts
├── configs/               # Configuration examples
│   ├── sonic/            # SONiC configs
│   └── qos/              # QoS/PFC examples
├── screenshots/           # Screenshots directory
└── results/               # Test results directory
```

### 2. Typical Workflow

1. **Access NVIDIA Air Lab**
   - Log into NVIDIA Air (https://air.nvidia.com/)
   - Launch "SONiC Numbered BGP EVPN VXLAN Demo" lab
   - Access via oob-mgmt-server (ubuntu/nvidia)
   - Review topology: See `docs/lab-topology.md` for device names and IPs
   - Recommended test pairs: server01↔server03 (VLAN10) or server02↔server04 (VLAN20)

2. **Configure Switches**
   ```bash
   # SSH to leaf switch from oob-mgmt-server
   ssh admin@leaf01  # Password: YourPaSsWoRd
   
   # Check current configuration
   show vlan brief
   show interface status
   
   # Use configs/qos/pfc_config_example.md for PFC/QoS configuration
   # This lab uses config_db.json (not NVUE) - edit /etc/sonic/config_db.json
   # Apply: sudo config reload -y
   ```

3. **Configure Hosts**
   ```bash
   # SSH to server from oob-mgmt-server
   ssh server01  # Password: nvidia
   
   # Server interfaces already have IPs configured on eth1
   # Just need to configure RoCE and set MTU
   # On server01 (VLAN 10):
   sudo scripts/setup/configure_host_roce.sh eth1 172.16.10.101/24 9000
   
   # On server03 (VLAN 10):
   sudo scripts/setup/configure_host_roce.sh eth1 172.16.10.103/24 9000
   ```

4. **Validate Configuration**
   ```bash
   # On switches:
   scripts/validation/verify_sonic_config.sh <switch_name>
   
   # On hosts:
   scripts/validation/verify_host_roce.sh <interface>
   ```

5. **Run Tests**
   ```bash
   # First, identify RDMA device on each host
   ibv_devices
   ibstat
   
   # On server01 (server, VLAN 10):
   scripts/perftest/run_rdma_tests.sh server mlx5_0 0
   
   # On server03 (client, VLAN 10):
   scripts/perftest/run_rdma_tests.sh client mlx5_0 0 172.16.10.101
   ```

6. **Document Results**
   - Capture screenshots → `screenshots/`
   - Save test outputs → `results/`
   - Update `docs/results.md` with findings

## Key Commands Reference

### Switch Commands
```bash
# Check PFC status
show priority-flow-control status

# Check QoS configuration
show qos table

# Check interface counters
show interface counters
```

### Host Commands
```bash
# List RDMA devices
ibv_devices

# Show device details
ibstat

# Test connectivity
ping <peer_ip>

# Run bandwidth test (server)
ib_write_bw -d <device> -x <gid_index>

# Run bandwidth test (client)
ib_write_bw -d <device> -x <gid_index> <server_ip>
```

## Next Steps

1. **Read the Full Documentation**:
   - Start with `README.md` for project overview
   - Review `PRD.md` for requirements and scope
   - Follow `docs/setup-guide.md` for detailed setup

2. **Review Lab-Specific Information**:
   - See `docs/lab-topology.md` for complete topology and IP addressing
   - Lab already has servers configured with IPs on eth1
   - Focus on PFC configuration on leaf switches and RoCE enablement on servers

3. **Execute the PoC**:
   - Follow the setup guide step-by-step
   - Capture screenshots at each stage
   - Document results and findings

## Getting Help

- Check `docs/setup-guide.md` for detailed instructions
- Review configuration examples in `configs/`
- Scripts include usage instructions (run with no arguments)
- NVIDIA Air documentation: https://air.nvidia.com/

## Common First Steps

1. **Explore the Lab**:
   ```bash
   # From oob-mgmt-server, SSH to devices
   ssh admin@leaf01  # Switches: admin/YourPaSsWoRd
   ssh server01      # Servers: ubuntu/nvidia
   
   # Topology is documented in docs/lab-topology.md
   # Switches: leaf01-03, spine01-02
   # Servers: server01-06 (VLAN10: 01,03,05 | VLAN20: 02,04,06)
   ```

2. **Check Current State**:
   ```bash
   # On leaf01 switch
   show vlan brief
   show ip interfaces
   show interface status
   show runningconfiguration bgp
   
   # On server01
   ip link show
   ip addr show eth1
   ping 172.16.10.103 -c 3  # Test VLAN10 connectivity to server03
   ```

3. **Plan Configuration**:
   - **PFC**: Enable on leaf switch server-facing ports (Ethernet0, Ethernet4)
   - **Hosts**: Configure RoCE on eth1 interfaces (IPs already configured)
   - **Test Pairs**: server01↔server03 (VLAN10) or server02↔server04 (VLAN20)
   - **RDMA Devices**: Check with `ibv_devices` and `ibstat` after RoCE setup

---

**Ready to start?** Follow `docs/setup-guide.md` for detailed step-by-step instructions!
