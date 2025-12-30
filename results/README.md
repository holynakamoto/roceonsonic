# Test Results Directory

This directory contains raw test outputs and validation results from the RoCE PoC.

## Files

### Expected Results Files

After running the PoC, you should have:

- `test_results.txt` - Summary of test results (included)
- `sonic_pfc_priority_output.txt` - Output from `show pfc priority` command
- `sonic_buffer_config_output.txt` - Output from `show buffer configuration` command
- `host_ibv_devices_output.txt` - Output from `ibv_devices` command
- `rdma_test_results.txt` - Full output from ib_send_bw and ib_write_bw tests
- `pfc_counters_output.txt` - Output from `show pfc counters` command

### Test Results Summary

See `test_results.txt` for a summary of completed PoC test results.

### Capturing Results

Use these commands to capture results:

**Switch Verification**:
```bash
# On leaf01 (or any leaf switch)
show pfc priority > sonic_pfc_priority_output.txt
show buffer configuration > sonic_buffer_config_output.txt
show pfc counters > pfc_counters_output.txt
```

**Host Verification**:
```bash
# On server01 or server03
ibv_devices > host_ibv_devices_output.txt
rdma link show >> host_ibv_devices_output.txt
```

**RDMA Tests**:
```bash
# Test outputs are automatically saved by run_rdma_tests.sh
# Or capture manually:
ib_send_bw -d rxe0 -F <server_ip> > rdma_test_results.txt 2>&1
```

## Notes

- Store actual test outputs here for reference
- Compare results against documented results in `docs/results.md`
- Screenshots should be stored in `screenshots/` directory

---

**Last Updated**: December 30, 2025
