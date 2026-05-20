# Machine Learning Accelerator Hardware Trojan Research Prototype

This repository contains the **latest structured RTL prototype** for the thesis project
`机器学习加速器的硬件木马攻击与防御研究`.

It focuses on a compact MLP-style accelerator and studies:

- **parameter-flow backdoor hardware Trojans**
- **compound trigger logic**
- **address-remapping and bit-flip attacks**
- **joint defense mechanisms**
- **batch RTL simulation and result export**

The repository is intended for **academic research, Verilog/RTL simulation, defense evaluation, and thesis reproduction only**.
It is not intended for real-world malicious deployment.

## 1. Repository structure

- `rtl/`
  - accelerator implementation
  - attack modules
  - defense modules
  - top-level integration
- `tb/`
  - single-case testbench
  - batch-evaluation testbench
  - scenario tasks and scoreboard
- `cfg/`
  - attack modes
  - defense modes
  - model profiles
  - experiment matrix
- `results/`
  - exported CSV summaries from batch simulation
- `PROJECT_OVERVIEW.md`
  - concise file/function overview for the current mainline project

## 2. What the system does

The accelerator executes a compact MLP inference path and allows Trojan logic to intervene in the **parameter flow** rather than only modifying the final output.

The current mainline implements:

- a compact `4 -> 4 -> 4` MLP accelerator
- grouped weight buffering and tile-based loading
- a compound Trojan trigger controller
- address-remapping attack
- bit-level weight-flip attack
- block integrity checking
- random trusted recomputation
- behavior anomaly monitoring
- alert fusion, attack localization, and safe fallback response

## 3. Quick run

Enter the repository root first:

```bash
cd advanced_mlp_trojan_github_repo
```

### Single-case demo

Compile:

```bash
iverilog -g2012 -I cfg -I tb \
  -o simv_single_demo \
  tb/tb_mlp2_single.v \
  rtl/top/mlp2_secure_accel_top.v \
  rtl/core/*.v \
  rtl/common/*.v \
  rtl/attack/*.v \
  rtl/defense/*.v
```

Run:

```bash
vvp simv_single_demo
```

Expected output pattern:

```text
single-baseline pred=3 trusted=3 defense=0 cycles=27
single-attack pred=2 final=0 trusted=0 remap=1 bitflip=0 defense=1 safe=1 ...
```

### Batch evaluation

Compile:

```bash
iverilog -g2012 -I cfg -I tb \
  -o simv_batch_demo \
  tb/tb_mlp2_batch.v \
  rtl/top/mlp2_secure_accel_top.v \
  rtl/core/*.v \
  rtl/common/*.v \
  rtl/attack/*.v \
  rtl/defense/*.v
```

Run:

```bash
vvp simv_batch_demo
```

Current verified batch summary:

- `Total runs = 147`
- `Attackable runs = 99`
- `Attack successes = 90`
- `Detected attacks = 77`
- `False positives = 0`
- `Localized attacks = 99`
- `Safe recoveries = 16`

## 4. Output fields

Common single-case output fields:

- `pred` / `predicted_class`: actual class predicted by the attacked hardware path
- `trusted`: class produced by the trusted reference path
- `final`: final class after safe-mode response
- `remap`: address-remapping attack was triggered
- `bitflip`: bit-flip attack was triggered
- `defense`: merged defense alert
- `safe`: safe-mode response activated
- `loc_valid`: localization information is valid
- `layer/tile/bank/addr`: suspected location of the attack
- `cycles`: cycle count of the inference

Batch summary fields:

- `Attack successes`: number of successful attack cases
- `Detected attacks`: number of attack cases detected by defenses
- `False positives`: benign cases wrongly reported as attacks
- `False negatives`: attack cases missed by defenses
- `Checksum hits`: integrity-check hits
- `Recompute hits`: trusted-recompute hits
- `Behavior hits`: behavior-monitor hits
- `Localized attacks`: attacks with valid localization output
- `Safe recoveries`: attacks successfully recovered under safe mode

## 5. Result files

- `results/batch_raw.csv`: raw per-scenario outputs
- `results/batch_summary.csv`: overall summary
- `results/group_summary.csv`: group-wise summary
- `results/attackmode_summary.csv`: attack-mode summary
- `results/attackprofile_summary.csv`: attack-profile summary
- `results/overhead_summary.csv`: defense-mask summary

## 6. Scope boundary

This repository is intentionally limited to:

- Verilog/RTL implementation
- controllable simulation
- reproducible batch evaluation
- hardware-Trojan defense research in an academic setting

It does not include:

- prior prototype versions
- thesis LaTeX source
- PDF deliverables
- unrelated temporary files or build artifacts
