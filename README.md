# 机器学习加速器硬件木马攻防 RTL 研究平台

本仓库对应毕业设计 **《机器学习加速器的硬件木马攻击与防御研究》** 的**最新主线工程**，聚焦于一个小型 MLP 加速器上的**参数流后门型硬件木马攻击**与**联合防御机制**。

它不是一个零散的 Verilog 样例集合，而是一套可以完整复现实验闭环的 RTL 级研究平台，覆盖：

- **小型机器学习加速器建模**
- **参数流后门木马植入与复合触发**
- **地址重映射与位级翻转两类攻击**
- **完整性校验、可信重计算、行为监测三类防御**
- **攻击定位与安全退化响应**
- **147 组 batch 场景的自动化评估**

> 使用边界：本仓库仅用于 **Verilog/RTL 仿真、学术研究、论文复现与防御评估**，不面向现实部署或破坏性用途。

---

## 1. 项目一句话概括

本项目构建了一套**中等复杂度、可复现、可批量评估的机器学习加速器硬件木马攻防实验平台**，重点研究参数流后门型木马如何改变推理结果，以及联合防御如何检测、定位并减轻攻击影响。

---

## 2. 系统做了什么

当前平台实现的是一个小型 `4 → 4 → 4` MLP 加速器，并将攻击与防御都放入**参数流**路径中，而不是只在输出端做简单篡改。

### 核心能力

1. **加速器核心**
   - Tile 化权重加载
   - 分组权重缓冲区
   - 中间激活缓存
   - 两层全连接推理

2. **攻击主线**
   - 复合触发控制器
   - 地址重映射木马
   - 位级权重翻转木马

3. **防御主线**
   - 块级完整性校验
   - 随机可信重计算
   - 行为异常监测
   - 告警融合
   - 攻击定位
   - 安全退化运行

---

## 3. 实验流程总览

```mermaid
flowchart LR
    A[模型参数与输入样本] --> B[权重加载与地址生成]
    B --> C[参数流攻击介入]
    C --> D[片上缓冲区写入]
    D --> E[两层 MLP 推理]
    E --> F[结果检测与告警融合]
    F --> G[攻击定位与安全响应]
    G --> H[单样例/Batch 统计结果]
```

### 这个流程的含义

- **输入层**：给定模型参数、输入样本、攻击模式和防御配置。
- **运行层**：控制器安排权重装载、Tile 访问和两层推理。
- **攻击层**：木马在参数流中重映射地址或翻转位值。
- **防御层**：从参数完整性、结果可信性和访问行为三个方向检测异常。
- **响应层**：输出系统级告警、定位信息，并在 safe mode 下回退最终结果。
- **统计层**：统一导出 batch 结果，支撑论文图表与对比分析。

---

## 4. 仓库目录

```text
advanced_mlp_trojan_github_repo/
├── rtl/
│   ├── common/     # 基础计算与工具模块
│   ├── core/       # MLP 核心、控制器、地址生成、权重加载与缓冲
│   ├── attack/     # 复合触发、地址重映射、位翻转、攻击配置
│   ├── defense/    # 完整性校验、重计算、行为监测、定位、响应
│   └── top/        # 顶层集成
├── tb/             # 单样例与 batch testbench、场景任务、统计器
├── cfg/            # 攻击/防御模式、模型配置、实验矩阵
├── results/        # CSV 结果文件
├── README.md
└── PROJECT_OVERVIEW.md
```

如果你想最快理解整个工程，建议先看：

1. `rtl/top/mlp2_secure_accel_top.v`
2. `rtl/attack/trojan_trigger_fsm.v`
3. `rtl/attack/atk_addr_remap_ctrl.v`
4. `rtl/attack/atk_weight_bitflip_injector.v`
5. `rtl/defense/def_block_checksum_guard.v`
6. `rtl/defense/def_random_recompute_ctrl.v`
7. `rtl/defense/def_behavior_monitor.v`
8. `tb/tb_mlp2_batch.v`
9. `cfg/exp_matrix.mem`

更细的文件说明见：
- `PROJECT_OVERVIEW.md`

---

## 5. 快速运行

进入仓库目录：

```bash
cd advanced_mlp_trojan_github_repo
```

### 5.1 单样例演示

编译：

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

运行：

```bash
vvp simv_single_demo
```

典型输出：

```text
single-baseline pred=3 trusted=3 defense=0 cycles=27
single-attack pred=2 final=0 trusted=0 remap=1 bitflip=0 defense=1 safe=1 code=100 loc_valid=1 layer=1 tile=2 bank=1 addr=6 cycles=27
```

这两行分别表示：
- **基线场景**：系统正常运行，预测类别与可信类别一致，防御不误报。
- **攻击场景**：攻击成功将结果推向目标类别，同时系统检测、定位并在 safe mode 下恢复最终输出。

### 5.2 Batch 批量实验

编译：

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

运行：

```bash
vvp simv_batch_demo
```

batch 会自动执行 `cfg/exp_matrix.mem` 中定义的 **147 组场景**，并在终端末尾打印汇总结果。

---

## 6. 当前实验结果摘要

当前最新 batch 结果如下：

| 指标 | 数值 |
|---|---:|
| Total runs | 147 |
| Attackable runs | 99 |
| Attack successes | 90 |
| Detected attacks | 77 |
| False positives | 0 |
| False negatives | 22 |
| Checksum hits | 99 |
| Recompute hits | 52 |
| Behavior hits | 66 |
| Localized attacks | 99 |
| Safe recoveries | 16 |

如果换成更直观的结论表达，就是：

- 攻击在可攻击场景中具有较高成功率；
- 联合防御能够覆盖大多数攻击场景，且**误报率为 0**；
- 定位机制覆盖全部可攻击场景；
- 安全模式在部分场景下能够将最终结果恢复到可信输出。

---

## 7. 输出字段说明

### 单样例输出字段

- `pred` / `predicted_class`：受攻击后实际输出类别
- `trusted`：可信路径输出类别
- `final`：安全响应后的最终输出类别
- `remap`：地址重映射攻击是否命中
- `bitflip`：位翻转攻击是否命中
- `defense`：联合防御是否报警
- `safe`：安全模式是否激活
- `loc_valid`：定位信息是否有效
- `layer / tile / bank / addr`：定位出的可疑攻击位置
- `cycles`：本轮推理周期数

### Batch 汇总字段

- `Attack successes`：攻击成功改变推理结果的次数
- `Detected attacks`：被防御成功检测出的攻击次数
- `False positives`：正常场景误报次数
- `False negatives`：攻击场景漏检次数
- `Checksum hits`：完整性校验命中次数
- `Recompute hits`：可信重计算命中次数
- `Behavior hits`：行为监测命中次数
- `Localized attacks`：成功给出定位信息的攻击次数
- `Safe recoveries`：安全模式成功恢复可信结果的次数

---

## 8. 结果文件说明

`results/` 目录中的文件含义如下：

- `batch_raw.csv`：逐场景原始结果
- `batch_summary.csv`：总体统计结果
- `group_summary.csv`：按实验组统计
- `attackmode_summary.csv`：按攻击模式统计
- `attackprofile_summary.csv`：按攻击配置统计
- `overhead_summary.csv`：按防御配置统计平均周期和检测效果

这些文件可以直接用于论文中的：
- 总体结果表
- 分组柱状图
- 攻击模式对比图
- 防御开销对比图

---

## 9. 为什么这个项目有研究价值

这个仓库的价值不在于做一个很大的神经网络，而在于它把以下几个环节**完整打通**了：

1. **系统建模**：构建了一个具备参数装载、片上缓冲和两层推理的小型加速器；
2. **攻击建模**：在参数流中实现了复合触发、地址重映射和位级翻转两类木马；
3. **防御建模**：实现了完整性校验、重计算、行为监测、定位和安全响应；
4. **实验评估**：通过 batch testbench 完成 147 组场景的自动化评估。

因此，它更像一个**小型硬件安全研究平台**，而不仅仅是几个 Verilog 样例模块。

---

## 10. 适用边界

本仓库仅保留了**当前最新主线工程**，不包含：

- 旧版样例工程
- 论文 LaTeX 源码
- PDF / docx / html 等交付文件
- 临时编译产物

它适用于：

- RTL/Verilog 仿真
- 学术研究复现
- 防御评估
- 毕设/论文结果核对

不适用于：

- 现实破坏性部署
- 非法硬件篡改
- 商业级直接落地

---

## 11. 相关文档

如果你还需要更细的工程认知或论文材料，可以查看当前主项目目录下的补充文档：

- `advanced_mlp_trojan_eval_project/docs/final_defense_briefing_and_demo.md`
- `advanced_mlp_trojan_eval_project/docs/final_defense_project_map.md`
- `advanced_mlp_trojan_eval_project/docs/reviewer_feedback_followup.md`
- `advanced_mlp_trojan_eval_project/docs/final_defense_ppt_outline.md`

这些文件主要面向：
- 最终答辩讲解
- 现场演示
- 评审意见回应
- PPT 提纲整理
