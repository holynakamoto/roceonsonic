# Product Requirements Document (PRD): RoCE-Enabled Low-Latency Data Transfer Proof-of-Concept on SONiC using NVIDIA Air

## 1. Document Overview
**Project Name**: RoCE PoC on SONiC with NVIDIA Air  
**Version**: 1.0  
**Date**: December 30, 2025  
**Author**: Grok (assisted demo project designer)  
**Status**: Draft  

This PRD defines the requirements for a personal/demo Proof-of-Concept (PoC) project showcasing expertise in SONiC, NVIDIA Ethernet/RoCE products (Spectrum switches and ConnectX adapters), Linux networking, and PoC development leadership. The PoC will be built entirely in the free, cloud-based **NVIDIA Air** simulation platform (https://air.nvidia.com/), requiring no physical hardware.

## 2. Objectives
- Demonstrate hands-on configuration of SONiC on virtual NVIDIA Spectrum switches for lossless Ethernet fabric (essential for RoCE).
- Enable and test RoCEv2 on simulated ConnectX adapters in Linux hosts.
- Perform basic RDMA benchmarks to validate low-latency/high-throughput data transfer.
- Highlight practical skills in NVIDIA ecosystems (SONiC + Spectrum + ConnectX) and Linux networking.
- Produce portfolio-ready artifacts (GitHub repo with configs, scripts, screenshots, and results) to evidence a "consistent track record of leading proof-of-concept/feature development."

**Business/Personal Value**:  
This PoC directly aligns with job requirements emphasizing SONiC/Cumulus, NVIDIA SDKs/products (ConnectX/Spectrum for RoCE), and Linux networking. It serves as a compelling demo for interviews or portfolios in data center/AI networking roles at NVIDIA or partners.

## 3. Scope
### In Scope
- Use NVIDIA Air's pre-built SONiC labs (e.g., SONiC BGP EVPN VXLAN spine-leaf topology with virtual Spectrum switches and Ubuntu hosts emulating ConnectX adapters).
- Configure lossless fabric: Priority Flow Control (PFC), QoS, ECN for RoCE traffic on SONiC switches.
- Enable RoCEv2 on host interfaces, install/test RDMA tools.
- Run functional RDMA tests (e.g., `perftest` suite: ib_write_bw, ib_read_lat).
- Basic automation (scripts) for setup/validation.
- Documentation and results capture.

### Out of Scope
- Real-world line-rate benchmarks (e.g., 400Gbps throughput or sub-µs latency) — NVIDIA Air is a functional simulation; performance numbers will be simulated/not representative of hardware.
- Advanced features: DOCA offload, BlueField DPUs, GPU-direct RDMA, or custom SONiC image builds.
- Integration with Cumulus Linux (focus on SONiC; optional comparison if time allows).
- Large-scale topologies (> basic spine-leaf).

## 4. Target Users / Stakeholders
- Primary: The project owner (for portfolio/resume enhancement).
- Secondary: Recruiters/reviewers evaluating NVIDIA networking expertise.
- Tertiary: Community (open-source GitHub repo for sharing).

## 5. Requirements

### 5.1 Platform Requirements
- NVIDIA Air account (free registration at https://air.nvidia.com/).
- Start from pre-built SONiC lab (e.g., "SONiC BGP EVPN VXLAN" or similar spine-leaf demo with virtual Spectrum switches and Ubuntu servers).
- Topology: Minimum 2 leaf switches, 1-2 spines, 2+ connected hosts for end-to-end testing.

### 5.2 Functional Requirements
| ID | Requirement | Description | Priority |
|----|-------------|-------------|----------|
| FR-01 | SONiC Lossless Configuration | Enable PFC on switch ports, configure QoS maps for RoCE (e.g., DSCP to priority, lossless mode via NVUE/CLI or config_db). Verify with `show qos` commands. | High |
| FR-02 | Host RoCE Enablement | On Ubuntu hosts: Install MLNX_OFED (if available in sim), enable RoCEv2, configure interfaces for RDMA, verify with `ibv_devices` and `ibstat`. | High |
| FR-03 | RDMA Testing | Run `perftest` tools (ib_write_bw, ib_send_lat, etc.) between two hosts. Capture output showing successful RDMA transfers (even if simulated speeds). | High |
| FR-04 | Validation | Demonstrate zero packet loss under basic load; verify PFC counters during tests. | Medium |
| FR-05 | Automation | Provide Bash/Python scripts or Ansible snippets for repeatable config application and test execution. | Medium |
| FR-06 | Documentation | README with step-by-step guide, topology diagram, config snippets, and results screenshots. | High |

### 5.3 Non-Functional Requirements
- **Accessibility**: Entirely browser-based via NVIDIA Air (no local installs needed).
- **Reproducibility**: All steps documented for others to replicate in their NVIDIA Air account.
- **Performance Note**: Emphasize functional correctness over raw metrics due to simulation limitations.
- **Time Estimate**: 10-20 hours (1-2 weeks part-time).
- **Dependencies**: Stable internet; NVIDIA Air availability (active as of 2025 with ongoing updates).

## 6. Success Criteria / Acceptance
- Successful end-to-end RoCE transfer (perftest runs without errors between hosts).
- Configured lossless fabric verified via switch CLI outputs.
- GitHub repository with:
  - README.md (motivation, guide, skills mapping).
  - Config files/scripts.
  - Screenshots: Topology, configs, test outputs, counters.
- Functional demo video (optional: short recording of session).

## 7. Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| NVIDIA Air lab limitations (e.g., no full MLNX_OFED or limited perftest) | Medium | High | Use basic RDMA tools available in Ubuntu; focus on configuration validation if benchmarks fail. Fall back to ping/iperf for connectivity if needed. |
| Simulation instability or quota limits | Low | Medium | Save configs frequently; use short sessions. |
| Outdated pre-built lab (older SONiC version) | Low | Low | Note version in docs; procedures are similar across releases. |

## 8. Deliverables
- GitHub repository (public) containing all artifacts.
- Final report/summary tying results to required skills.
- Optional: Blog post or LinkedIn update showcasing the PoC.

This PRD provides a clear roadmap to build an impressive, zero-cost demo using NVIDIA Air. Once complete, it will strongly evidence the targeted experiences. If you'd like to add sections (e.g., timeline, enhancements), let me know!

---

## 9. Project Completion Summary

**Status**: ✅ **COMPLETE**  
**Completion Date**: December 30, 2025

### Objectives Achieved

| Objective | Status | Evidence |
|-----------|--------|----------|
| SONiC Lossless Configuration | ✅ Complete | PFC enabled on 3 switches, priority 3 |
| Host RoCE Enablement | ✅ Complete | Soft-RoCE on 6 servers, all operational |
| RDMA Testing | ✅ Complete | Multiple successful tests, 20-23 MB/sec |
| Validation | ✅ Complete | Zero packet loss, PFC verified |
| Automation | ✅ Complete | Working scripts for deployment |
| Documentation | ✅ Complete | Comprehensive guides and results |

### Requirements Completion

| Requirement | Priority | Status | Notes |
|-------------|----------|--------|-------|
| FR-01: SONiC Lossless Config | High | ✅ Complete | Buffer pools, PFC priority 3 |
| FR-02: Host RoCE Enablement | High | ✅ Complete | All 6 servers configured |
| FR-03: RDMA Testing | High | ✅ Complete | Multiple test pairs validated |
| FR-04: Validation | Medium | ✅ Complete | Zero packet loss confirmed |
| FR-05: Automation | Medium | ✅ Complete | Scripts for switches and hosts |
| FR-06: Documentation | High | ✅ Complete | Full documentation in repo |

### Deliverables Completed

- ✅ GitHub repository with all artifacts
- ✅ Working automation scripts
- ✅ Configuration files (QoS template)
- ✅ Comprehensive test results
- ✅ Troubleshooting documentation
- ✅ Skills mapping to job requirements

### Key Achievements

1. **Successfully enabled PFC** on SONiC 202305 despite missing default QoS config
2. **Configured soft-RoCE** on all Ubuntu hosts with proper kernel modules
3. **Validated lossless transport** across VXLAN EVPN fabric
4. **Documented real-world challenges** and solutions
5. **Created reusable automation** for future deployments

### Skills Demonstrated

**Technical**:
- SONiC configuration (JSON, CLI, troubleshooting)
- QoS/PFC setup for lossless Ethernet
- Linux RDMA stack configuration
- RDMA performance testing
- Python scripting for automation
- Network debugging

**Professional**:
- PoC planning and execution
- Documentation for knowledge transfer
- Problem-solving under constraints
- Repository organization
- Technical communication

This PoC successfully demonstrates all required competencies for NVIDIA networking roles focusing on SONiC, RoCE, and data center fabrics.
