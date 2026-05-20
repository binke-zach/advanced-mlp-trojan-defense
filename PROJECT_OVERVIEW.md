# Project Overview

This file gives a concise overview of the **current mainline files** in the clean GitHub-ready repository.

## 1. Core structure

### `rtl/common`

- `pe_mac.v`: basic MAC processing element
- `lfsr16.v`: pseudo-random generator for recomputation sampling
- `argmax4.v`: 4-class decision module
- `checksum_tile.v`: tile-level checksum helper
- `quant_clip.v`: intermediate activation clipping

### `rtl/core`

- `mlp2_ctrl.v`: top-level control flow for loading and inference
- `weight_addr_gen.v`: legal/shadow address generation
- `weight_loader_dma.v`: tile-based weight loading path
- `banked_weight_buffer.v`: grouped on-chip weight storage
- `activation_buffer.v`: intermediate activation storage
- `fc_tile_compute.v`: FC tile compute unit
- `mlp2_accel_core.v`: compact MLP inference core

### `rtl/attack`

- `trojan_trigger_fsm.v`: compound trigger controller
- `atk_addr_remap_ctrl.v`: address-remapping Trojan
- `atk_weight_bitflip_injector.v`: bit-level weight-flip Trojan
- `attack_profile_rom.v`: malicious parameter profile storage
- `attack_mux.v`: final attack-path selector

### `rtl/defense`

- `def_block_checksum_guard.v`: block integrity defense
- `def_random_recompute_ctrl.v`: random trusted recomputation
- `def_behavior_monitor.v`: access anomaly monitor
- `def_alert_fusion.v`: merged system alert generator
- `def_attack_locator.v`: suspected attack location output
- `def_response_ctrl.v`: safe fallback response controller

### `rtl/top`

- `mlp2_secure_accel_top.v`: full platform integration

## 2. Verification files

### `tb`

- `tb_mlp2_single.v`: single-case demonstration testbench
- `tb_mlp2_batch.v`: batch evaluation testbench
- `tb_scenario_tasks.vh`: shared scenario tasks
- `tb_scoreboard.vh`: metric accumulation logic

## 3. Configuration files

### `cfg`

- `attack_modes.vh`: attack mode definitions
- `defense_modes.vh`: defense mask definitions
- `model_profiles.vh`: target/non-target model settings and trigger input values
- `exp_matrix.mem`: full scenario matrix for batch evaluation

## 4. Result files

### `results`

- `batch_raw.csv`: per-scenario outputs
- `batch_summary.csv`: overall metrics
- `group_summary.csv`: group-wise metrics
- `attackmode_summary.csv`: attack-mode metrics
- `attackprofile_summary.csv`: attack-profile metrics
- `overhead_summary.csv`: defense-mask and average-cycle metrics

## 5. Most important files for presentation

If you want to understand the whole platform quickly, open these files first:

1. `rtl/top/mlp2_secure_accel_top.v`
2. `rtl/attack/trojan_trigger_fsm.v`
3. `rtl/attack/atk_addr_remap_ctrl.v`
4. `rtl/attack/atk_weight_bitflip_injector.v`
5. `rtl/defense/def_block_checksum_guard.v`
6. `rtl/defense/def_random_recompute_ctrl.v`
7. `rtl/defense/def_behavior_monitor.v`
8. `rtl/defense/def_attack_locator.v`
9. `tb/tb_mlp2_batch.v`
10. `cfg/exp_matrix.mem`

## 6. One-sentence summary

This repository packages a compact RTL research platform for studying parameter-flow hardware Trojans in machine learning accelerators, together with joint defenses, localization, safe response, and batch evaluation.
