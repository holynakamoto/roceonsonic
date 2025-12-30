# Lab Topology: SONiC Numbered BGP EVPN VXLAN Demo

This document provides detailed information about the specific NVIDIA Air lab environment used for this RoCE PoC.

## Lab Information

**Lab Name**: SONiC Numbered BGP EVPN VXLAN Demo  
**Lab Type**: SONiC BGP EVPN VXLAN (spine-leaf topology)  
**SONiC Version**: SONiC.202305_RC.78  
**Configuration Mode**: config_db.json (split-unified mode with FRR)

## Topology

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

## Devices

### SONiC Switches

| Device | Type | Management IP | Loopback IP | ASN |
|--------|------|---------------|-------------|-----|
| leaf01 | Leaf | 192.168.200.4/24 | 10.0.0.1/32 | 65101 |
| leaf02 | Leaf | 192.168.200.5/24 | 10.0.0.2/32 | 65102 |
| leaf03 | Leaf | 192.168.200.6/24 | 10.0.0.3/32 | 65103 |
| spine01 | Spine | 192.168.200.3/24 | 10.0.0.101/32 | 65199 |
| spine02 | Spine | 192.168.200.4/24 | 10.0.0.102/32 | 65199 |

### Ubuntu Servers

| Hostname | Interface | VRF | VLAN | IP Address | Connected To |
|----------|-----------|-----|------|------------|--------------|
| server01 | eth0 | mgmt | - | 192.168.200.7/24 | Management |
| | eth1 | default | 10 | 172.16.10.101/24 | leaf01:Ethernet0 |
| server02 | eth0 | mgmt | - | 192.168.200.8/24 | Management |
| | eth1 | default | 20 | 172.16.20.102/24 | leaf01:Ethernet4 |
| server03 | eth0 | mgmt | - | 192.168.200.9/24 | Management |
| | eth1 | default | 10 | 172.16.10.103/24 | leaf02:Ethernet0 |
| server04 | eth0 | mgmt | - | 192.168.200.10/24 | Management |
| | eth1 | default | 20 | 172.16.20.104/24 | leaf02:Ethernet4 |
| server05 | eth0 | mgmt | - | 192.168.200.11/24 | Management |
| | eth1 | default | 10 | 172.16.10.105/24 | leaf03:Ethernet0 |
| server06 | eth0 | mgmt | - | 192.168.200.12/24 | Management |
| | eth1 | default | 20 | 172.16.20.106/24 | leaf03:Ethernet4 |

### VLANs and VNIs

| VLAN | VNI | Members | Servers |
|------|-----|---------|---------|
| Vlan10 | 10 | leaf01:Ethernet0, leaf02:Ethernet0, leaf03:Ethernet0 | server01, server03, server05 |
| Vlan20 | 20 | leaf01:Ethernet4, leaf02:Ethernet4, leaf03:Ethernet4 | server02, server04, server06 |

## Physical Connectivity

### Leaf Switches

**leaf01**:
- eth1 (AIR Port) → Ethernet0 (SONiC Port) → server01:eth1
- eth2 (AIR Port) → Ethernet4 (SONiC Port) → server02:eth1
- eth3 (AIR Port) → Ethernet8 (SONiC Port) → spine01:Ethernet0
- eth4 (AIR Port) → Ethernet12 (SONiC Port) → spine02:Ethernet0

**leaf02**:
- eth1 (AIR Port) → Ethernet0 (SONiC Port) → server03:eth1
- eth2 (AIR Port) → Ethernet4 (SONiC Port) → server04:eth1
- eth3 (AIR Port) → Ethernet8 (SONiC Port) → spine01:Ethernet4
- eth4 (AIR Port) → Ethernet12 (SONiC Port) → spine02:Ethernet4

**leaf03**:
- eth1 (AIR Port) → Ethernet0 (SONiC Port) → server05:eth1
- eth2 (AIR Port) → Ethernet4 (SONiC Port) → server06:eth1
- eth3 (AIR Port) → Ethernet8 (SONiC Port) → spine01:Ethernet8
- eth4 (AIR Port) → Ethernet12 (SONiC Port) → spine02:Ethernet8

### Spine Switches

**spine01**:
- Ethernet0 → leaf01:Ethernet8
- Ethernet4 → leaf02:Ethernet8
- Ethernet8 → leaf03:Ethernet8

**spine02**:
- Ethernet0 → leaf01:Ethernet12
- Ethernet4 → leaf02:Ethernet12
- Ethernet8 → leaf03:Ethernet12

## Underlay Network

### BGP Numbered Interfaces

Leaf-to-Spine links use /31 addressing:

| Leaf | Interface | IP Address | Remote Device | Remote IP |
|------|-----------|------------|---------------|-----------|
| leaf01 | Ethernet8 | 172.16.1.1/31 | spine01 | 172.16.1.0/31 |
| leaf01 | Ethernet12 | 172.16.2.1/31 | spine02 | 172.16.2.0/31 |
| leaf02 | Ethernet8 | 172.16.1.3/31 | spine01 | 172.16.1.2/31 |
| leaf02 | Ethernet12 | 172.16.2.3/31 | spine02 | 172.16.2.2/31 |
| leaf03 | Ethernet8 | 172.16.1.5/31 | spine01 | 172.16.1.4/31 |
| leaf03 | Ethernet12 | 172.16.2.5/31 | spine02 | 172.16.2.4/31 |

## Access Information

### Management Server
- **Hostname**: oob-mgmt-server
- **Access**: Web console or SSH
- **Default Credentials**:
  - Username: `ubuntu`
  - Password: `nvidia`
  - **Note**: Must change password on first login

### SONiC Switches
- **Username**: `admin`
- **Password**: `YourPaSsWoRd`
- **Access**: From oob-mgmt-server: `ssh admin@leaf01`

### Ubuntu Servers
- **Username**: `ubuntu`
- **Password**: `nvidia`
- **Access**: From oob-mgmt-server: `ssh server01`

## RoCE Configuration Strategy

For this PoC, we'll configure RoCE on the following:

### Recommended Test Pairs
1. **VLAN 10**: server01 ↔ server03 or server01 ↔ server05
2. **VLAN 20**: server02 ↔ server04 or server02 ↔ server06

### Interfaces for RoCE
- **Server Interface**: `eth1` (connected to VLAN interfaces)
- **Switch Interfaces**: `Ethernet0` and `Ethernet4` (server-facing ports on leaves)
- **Spine Interfaces**: All Ethernet interfaces (may need PFC for transit)

### Key Configuration Points
1. **PFC Configuration**: Enable on leaf switch server-facing ports (Ethernet0, Ethernet4)
2. **QoS Mapping**: Configure DSCP 46 → Priority 3 for RoCE traffic
3. **Host Configuration**: Enable RoCEv2 on server `eth1` interfaces
4. **VXLAN Consideration**: RoCE traffic will be encapsulated in VXLAN when crossing spines

## Verification Commands

### Check Current Configuration

**On leaf01**:
```bash
# Show VLANs
show vlan brief

# Show VXLAN configuration
show vxlan interface
show vxlan vlanvnimap

# Show BGP EVPN status
show ip bgp summary
show bgp l2vpn evpn summary

# Check interface status
show ip interfaces
show interface status
```

**On server01**:
```bash
# Check interface configuration
ip addr show eth1
ip link show eth1

# Check connectivity to other VLAN 10 servers
ping 172.16.10.103 -c 3  # server03
ping 172.16.10.105 -c 3  # server05
```

## Notes

- **SONiC Version**: This lab uses SONiC 202305 (config_db.json method, not NVUE)
- **Split-Unified Mode**: Routing configured via FRR, switch config via ConfigDB
- **No Inter-VLAN Routing**: This lab does not route between VLANs (pure L2 extension)
- **VXLAN Encapsulation**: All inter-leaf traffic is encapsulated in VXLAN
- **RDMA Considerations**: RoCE traffic should work within VLANs; may need special handling for VXLAN encapsulation

## Verified Configuration

### Successfully Configured Devices

**Switches with PFC Enabled**:
- ✅ **leaf01**: PFC enabled on priority 3 for Ethernet0 and Ethernet4
- ✅ **leaf02**: PFC enabled on priority 3 for Ethernet0 and Ethernet4
- ✅ **leaf03**: PFC enabled on priority 3 for Ethernet0 and Ethernet4

**Configuration Details**:
- Lossless buffer pools: 12.7 MB ingress/egress
- PORT_QOS_MAP: pfc_enable "3" on server-facing ports
- BUFFER_PG and BUFFER_QUEUE mappings for priority 3 traffic

**Hosts with RoCE Configured**:
- ✅ **server01** (172.16.10.101): Soft-RoCE (rxe0) device on eth1, VLAN 10
- ✅ **server03** (172.16.10.103): Soft-RoCE (rxe0) device on eth1, VLAN 10

**Test Results**:
- ✅ RDMA communication established between server01 and server03
- ✅ ~23 MB/sec bandwidth achieved with ib_send_bw
- ✅ Zero packet loss demonstrated
- ✅ PFC counters verified (PFC enabled and ready)

See `docs/results.md` for comprehensive test results and analysis.

---

**Last Updated**: December 30, 2025
