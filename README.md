# build-k40g-ksu

红米 K40 游戏增强版 (ares / POCO F3 GT) **KernelSU 内核** GitHub Actions 云端自动编译。

## 设备信息

| 项目 | 说明 |
|------|------|
| 设备代号 | ares |
| SoC | MediaTek Dimensity 1200 (MT6893) |
| 架构 | arm64 |
| 内核类型 | 非 GKI（需自行编译） |

## 编译说明

### 触发方式

| 触发方式 | 说明 | 是否发布 Release |
|----------|------|:---:|
| **手动触发** (`workflow_dispatch`) | 在 Actions 页手动运行，可选 KSU/KSU-Next 版本和内核分支 | ✅ |
| **定时自动** (`schedule`) | 每周一 UTC 00:00 自动编译 KSU + KSU-Next 双版本 | ✅ |
| **Push 触发** | 仅 workflow 或 build.sh 变更时触发，编译 KSU 版 | ❌ (仅 artifact) |

### 手动使用步骤

1. 打开 [Actions](https://github.com/wuyands/build-k40g-ksu/actions) 页面
2. 选择 **"编译红米K40G KernelSU 内核"** → **Run workflow**
3. 选择参数：
   - **KernelSU 版本**: KernelSU / KernelSU-Next
   - **defconfig**: 默认 `ares_user`
   - **内核源码分支**: 默认 `main`
   - **强制开启 KPROBES**: 默认 `true`（非 GKI 设备建议开启）
4. 等待编译完成（约 20-40 分钟）
5. 在运行详情页下载 artifact，或到 [Releases](https://github.com/wuyands/build-k40g-ksu/releases) 页下载刷机包

## 刷入方法

1. **解锁 BootLoader**
2. 进入 Fastboot 或 TWRP Recovery
3. **卡刷 zip**：在 Recovery 中刷入 AnyKernel3 zip 包
4. 或 **fastboot 刷入**：用 magiskboot 替换原厂 boot.img 内核字段后 `fastboot flash boot`
5. 开机后安装 [KernelSU Manager](https://github.com/tiann/KernelSU/releases)

## 编译细节

- **内核源码**:
  - KernelSU: [WangCghy/KernelSU_ares](https://github.com/WangCghy/KernelSU_ares)
  - KernelSU-Next: [supercutefish/KernelSU-NEXT_Mi-ares](https://github.com/supercutefish/KernelSU-NEXT_Mi-ares)
- **工具链**: Neutron Clang (antman -S 09092023) + LLVM
- **defconfig**: `ares_user_defconfig`
- **运行环境**: ubuntu-22.04
- **打包**: osm0sis/AnyKernel3 (do.boot=1, write_boot)
- **关键选项**: `CONFIG_KSU=y`, `CONFIG_KPROBES=y`（build.sh 强制开启）

## 注意事项

> ⚠️ **非官方编译，仅供学习研究，刷机风险自负。**

- ares 为**非 GKI 设备**，KernelSU 官方自 v1.0 起不再官方支持，必须使用社区维护的内核分支自行编译
- 请确保使用的内核版本与手机当前系统底包版本匹配，否则可能无法开机
- 编译机需 glibc ≥ 2.36（Neutron Clang 要求），GitHub Actions ubuntu-22.04 满足此条件

## 致谢

- [KernelSU](https://github.com/tiann/KernelSU) - tiann
- [KernelSU-Next](https://github.com/rifsxd/KernelSU-Next) - rifsxd
- [AnyKernel3](https://github.com/osm0sis/AnyKernel3) - osm0sis
- [Neutron Clang](https://github.com/Neutron-Toolchains/neutron-toolchains) - Neutron-Toolchains
