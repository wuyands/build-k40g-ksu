# 🔧 红米 K40G KernelSU 内核 — 小白也能用的云端自动编译

> 📱 **适用设备**：红米 K40 游戏增强版（代号 `ares`，也称 POCO F3 GT）
>
> 🎯 本仓库让你**不需要电脑装环境、不需要懂命令行**，只需在网页上点几下，就能在 GitHub 云端自动编译出带有 KernelSU 的 **boot.img**，刷入手机即可获得 Root。

---

## ✨ 工作原理

```
你提供原厂 boot.img URL  →  GitHub Actions 云端编译 KSU 内核  →  用 magiskboot 注入内核  →  产出可 fastboot 刷入的 boot.img
       (必填)                  (WangCghy/KernelSU_ares)         (替换 boot 中的 Image)         (Release / Artifact 下载)
```

> ⚠️ **重要**：工作流**必须**填写 `boot_img_url` 参数（原厂 boot.img 的下载地址），否则只会编译内核镜像，不会产出可刷入的 boot.img。详见[第四节](#四获取原厂-bootimg必填参数)。

---

## 📋 目录

1. [前置准备：开启 GitHub Actions](#一前置准备开启-github-actions)
2. [Fork 仓库到你的账号](#二fork-仓库到你的账号)
3. [配置权限（GitHub Token）](#三配置权限github-token)
4. [获取原厂 boot.img（必填参数）](#四获取原厂-bootimg必填参数)
5. [手动触发编译](#五手动触发编译)
6. [下载 boot.img](#六下载-bootimg)
7. [解锁 BootLoader](#七解锁-bootloader)
8. [刷入内核](#八刷入内核)
9. [验证 KernelSU 是否生效](#九验证-kernelsu-是否生效)
10. [常见问题 FAQ](#十常见问题-faq)
11. [编译细节（给想深入了解的人）](#十一编译细节给想深入了解的人)

---

## 一、前置准备：开启 GitHub Actions

如果你的 GitHub 账号是**新注册的**，默认 Actions 可能没有开启。需要先开启：

1. 点页面顶部的 **Actions** 标签页
2. 点绿色的 **「I understand my workflows, go ahead and enable them」** 按钮
3. 如果提示要验证邮箱，去邮箱里点一下验证链接即可

> ✅ 以后 Fork 的仓库也会自动继承这个设置。

---

## 二、Fork 仓库到你的账号

点击右上角的 **Fork** 按钮，把这个仓库复制到你自己账号下。

- Fork 后你会得到 `你的用户名/build-k40g-ksu` 这样一个仓库
- 后续所有操作都在**你自己 Fork 的仓库**里进行，不需要动原仓库

> 💡 **Fork 之后要不要修改任何文件？** 不需要！直接跳到下一步配置 Token 就行。如果你只是想编译，什么都不要改。

---

## 三、配置权限（GitHub Token）

编译完成的 boot.img 会自动发布到 **Release** 页面，这需要你给 Actions 一个"写权限"。操作如下：

### 3.1 生成 Personal Access Token

1. 点击 GitHub 右上角头像 → **Settings**
2. 左侧菜单拉到最下面 → **Developer settings**
3. 左侧选 **Personal access tokens** → **Tokens (classic)**
4. 点击 **Generate new token** → **Generate new token (classic)**
5. 在 Note 里随便填个名字，比如 `K40G KSU Build`
6. 过期时间 **Expiration** 选 **No expiration**（永不过期）
7. 权限勾选 **repo** 下面的所有（全勾上最简单）
8. 拉到页面底部，点 **Generate token**
9. ⚠️ **立刻复制生成的 token**（以 `ghp_` 开头），页面关闭后就再也看不到了！

### 3.2 把 Token 配到你的 Fork 仓库

1. 打开你 Fork 的仓库页面（`你的用户名/build-k40g-ksu`）
2. 点击 **Settings** 标签页
3. 左侧菜单选 **Secrets and variables** → **Actions**
4. 点击绿色 **New repository secret** 按钮
5. **Name** 填 `PAT_TOKEN`
6. **Secret** 粘贴刚才复制的 token（以 `ghp_` 开头的）
7. 点 **Add secret** 保存

> ✅ 现在权限就配置好了！

---

## 四、获取原厂 boot.img（必填参数）

> 🔑 这是整个流程**最关键的一步**。`boot.img` 必须与你手机**当前系统版本完全一致**，否则刷入后无法开机。

### 4.1 从官方 ROM 包提取（推荐）

1. 到 [xiaomifirmwareupdater.com](https://xiaomifirmwareupdater.com/miui/ares/) 或 [miuirom.org](https://miuirom.org/) 搜索 `ares`，下载与你手机当前 MIUI/HyperOS 版本**完全一致**的完整 ROM 包（`.tgz` 或 `.zip`）
2. 解压 ROM 包，找到 `boot.img`（通常在 `images/` 目录下）
3. 这个 `boot.img` 就是你要上传的文件

### 4.2 从手机直接提取（需 root 或 TWRP）

如果手机已 root 或有 TWRP：

```bash
# 通过 adb 拉取（手机需连接电脑、开启 USB 调试）
adb shell "su -c 'dd if=/dev/block/by-name/boot_a of=/sdcard/boot.img'"
adb pull /sdcard/boot.img
```

> ⚠️ 注意 `boot_a` / `boot_b` 对应 A/B 分区，提取当前活动槽位即可（可用 `getprop ro.boot.slot_suffix` 查询）。

### 4.3 上传 boot.img 获取直链

工作流需要通过 URL 下载 boot.img，你有几种选择：

| 方式 | 操作 | 适合 |
|------|------|------|
| **本仓库 Release**（推荐） | 在你 Fork 的仓库创建一个 Release（如 tag `stock-boot-miui14`），把 boot.img 作为 asset 上传，得到直链 `https://github.com/你的用户名/build-k40g-ksu/releases/download/stock-boot-miui14/boot.img` | 私有 / 长期可用 |
| GitHub Release（其他仓库） | 上传到任意你的 GitHub 仓库的 Release | 同上 |
| 直链网盘 | 蓝奏云 / OneDrive 直链等（注意不能要登录） | 临时 |

> 💡 boot.img 通常约 64-128MB，GitHub Release asset 单文件上限 2GB，足够用。
>
> ⚠️ 如果你的 Fork 仓库是**私有**的，工作流下载 boot.img 时需要 PAT_TOKEN 有权限访问该 Release。最简单的做法是放在**同一个仓库**的 Release 里。

---

## 五、手动触发编译

1. 在你 Fork 的仓库页面，点 **Actions** 标签页
2. 左侧找到工作流 **「编译红米K40G KernelSU 内核」**
3. 点击 **Run workflow** 下拉按钮
4. 填写参数：

   | 参数 | 说明 | 推荐值 |
   |------|------|--------|
   | **KernelSU 版本** | `KernelSU`（原版）或 `KernelSU-Next`（社区增强版） | 新手选 `KernelSU` |
   | **defconfig** | 内核配置名 | `ares_user`（不要改） |
   | **内核源码分支** | 留空使用默认（KSU→`T`，KSU-Next→`main`） | 留空 |
   | **强制开启 KPROBES** | KSU 运行所需的内核选项 | `true`（不要改） |
   | **boot_img_url** ⚠️ | 原厂 boot.img 的下载地址，[见第四节](#四获取原厂-bootimg必填参数) | **必填！** |

5. 点击绿色 **Run workflow** 按钮
6. 等待约 20-40 分钟（可以在 Actions 页面看进度）

> 📌 **不填 `boot_img_url` 会怎样？**
> 工作流会编译内核镜像，但**跳过** boot.img 注入和 Release 发布步骤。你只能从 Artifact 下载原始 `Image` 文件，需要自己用 magiskboot 打包。新手务必填写此参数。

---

## 六、下载 boot.img

编译完成后，产物是 **`ksu-boot-YYYYMMDD-HHMM.img`**（或 `ksunext-boot-*.img`），可以从两处下载：

### 方式一：从 Release 下载（推荐）

1. 在你 Fork 的仓库页面，点击右侧 **Releases**
2. 找到最新的 Release（名字类似 `KernelSU 红米K40G 内核 #13`）
3. 下载 `.img` 文件，例如 `ksu-boot-20260626-1810.img`

> ✅ Release 永久保存，可随时下载。

### 方式二：从 Actions Artifact 下载

1. 在 Actions 页面点进刚完成的运行记录
2. 页面底部 **Artifacts** 区域下载 `.img` 文件
3. Artifact 会保存 30 天，到期自动删除

> 📥 下载到电脑上后，把 `.img` 文件传到手机或保留在电脑上用于 fastboot 刷入。

---

## 七、解锁 BootLoader

> ⚠️ **解锁 BL 会清除手机全部数据，请先备份！**

1. 在手机上进入 **设置 → 我的设备 → 全部参数**，连续点击 **MIUI 版本** 7 次，开启「开发者选项」
2. 进入 **设置 → 更多设置 → 开发者选项**
3. 打开 **OEM 解锁** 和 **USB 调试**
4. 点 **设备解锁状态** → **绑定账号和设备**（需要小米账号已登录）
5. 在电脑下载 [小米解锁工具](https://www.miui.com/unlock/index.html) 并安装
6. 手机关机，同时按住 **音量下 + 电源键** 进入 Fastboot 模式
7. USB 连接电脑，打开小米解锁工具，按提示操作
8. 解锁过程可能需要等待 168 小时（7天），这是小米的安全机制，无法跳过

> 🔓 解锁成功后手机会自动重启并清除所有数据。

---

## 八、刷入内核

### 8.1 准备工作

1. 电脑安装 [Google USB 驱动](https://developer.android.com/studio/run/win-usb) 和 [platform-tools](https://developer.android.com/studio/releases/platform-tools)（包含 `fastboot` 命令）
2. 把 `platform-tools` 目录加到系统 PATH，或在命令行 `cd` 到该目录
3. 把第六节下载的 `ksu-boot-*.img` 放到方便的位置（如 `D:\flash\`）

### 8.2 Fastboot 刷入（推荐）

1. 手机关机，同时按住 **音量下 + 电源键** 进入 Fastboot 模式（屏幕显示兔子图标）
2. USB 连接电脑
3. 打开 PowerShell / CMD，验证设备已识别：

   ```powershell
   fastboot devices
   # 应输出类似: <serial>  fastboot
   ```

4. **先备份原厂 boot.img**（万一刷坏可恢复）：

   ```powershell
   fastboot boot ksu-boot-20260626-1810.img   # 临时引导，不刷入，验证能否开机
   ```

   > 💡 如果临时引导能正常开机，说明内核兼容，再正式刷入。如果卡开机，重启回到原系统即可，无任何副作用。

5. 正式刷入：

   ```powershell
   fastboot flash boot_a ksu-boot-20260626-1810.img
   fastboot flash boot_b ksu-boot-20260626-1810.img   # A/B 分区都刷，避免 OTA 后失效
   fastboot reboot
   ```

   > 📌 K40G 是 A/B 分区设备，`boot_a` 和 `boot_b` 都要刷。如果不确定当前槽位，两个都刷最稳妥。

6. 手机重启，等待开机（首次开机可能稍慢，2-5 分钟正常）

### 8.3 刷坏了怎么恢复？

如果刷入后**无法开机**（卡 logo、循环重启）：

1. 手机关机，按住 **音量下 + 电源键** 进入 Fastboot（即使系统起不来，Fastboot 通常仍可进入）
2. 刷回**原厂 boot.img**（第 4.2 节你提取的那个）：

   ```powershell
   fastboot flash boot_a stock_boot.img
   fastboot flash boot_b stock_boot.img
   fastboot reboot
   ```

3. 手机会恢复原系统

> ⚠️ 所以**务必保留一份原厂 boot.img** 做备份！这也是为什么第 4.1/4.2 节强调要拿到这个文件。

---

## 九、验证 KernelSU 是否生效

刷完后开机，验证 KernelSU 是否正常工作：

1. 下载安装 [KernelSU Manager](https://github.com/tiann/KernelSU/releases)（下载 `.apk` 安装）
2. 打开 KernelSU Manager
3. 如果看到界面显示「工作中」或类似提示，说明刷入成功 ✅
4. 如果显示「不支持」或「未安装」，说明内核刷入失败，请检查：
   - 是否刷入了正确的 `.img` 文件？
   - 是否下载了最新的 Release？
   - **boot.img 是否与当前系统版本匹配？**（最常见原因）
   - `boot_a` 和 `boot_b` 是否都刷了？

---

## 十、常见问题 FAQ

### Q1: 编译失败了怎么办？

A: 点进 Actions 里失败的运行记录，查看日志找报错信息。常见原因：
- 网络问题导致源码下载失败 → 重新跑一次
- 工具链下载失败 → 等几分钟重新跑
- 如果多次失败，去 [Issues](https://github.com/wuyands/build-k40g-ksu/issues) 提问

### Q2: Fork 后还能同步原仓库的更新吗？

A: 可以。在你 Fork 的仓库页面，点击 **Sync fork** → **Update branch** 即可同步。如果原仓库有工作流更新，同步后你的也会更新。

### Q3: 编译一次要多久？

A: 约 20-40 分钟，取决于 GitHub Actions 服务器的繁忙程度。

### Q4: GitHub Actions 免费额度够用吗？

A: 够用。GitHub 免费账号每月有 2000 分钟 Actions 额度，编译一次约 30 分钟，一个月手动编译几次完全够用。

### Q5: 刷入后无法开机怎么办？

A: 通常是 **boot.img 与当前系统版本不匹配**。按[第 8.3 节](#83-刷坏了怎么恢复)刷回原厂 boot.img 即可恢复。下次编译前，确认 boot.img 来自与手机当前完全一致的 ROM 版本。

### Q6: 需要 Root 权限才能刷吗？

A: 不需要。只要解锁了 BootLoader，就可以通过 fastboot 刷入 boot.img。KernelSU 本身就是一种 Root 方案，刷入后你就有 Root 权限了。

### Q7: KernelSU 和 KernelSU-Next 有什么区别？

A: KernelSU 是原版；KernelSU-Next 是社区维护的增强版，增加了更多内核版本的兼容性和新特性。新手建议先用 KernelSU。

### Q8: 我的系统是 MIUI/HyperOS，能用吗？

A: 可以。只要**boot.img 来自你当前系统版本的固件**就行。如果刷入后不开机，说明 boot.img 版本不匹配，刷回原厂 boot.img 即可。

### Q9: 可以用在非 MIUI 系统上吗（类原生等）？

A: 取决于内核是否兼容。理论上只要是 ares 的 ROM 都可以尝试，但不保证 100% 兼容。你需要从对应的 ROM 包中提取 boot.img。

### Q10: 我不懂技术，这个教程我真的能操作下来吗？

A: 可以！这个教程就是为不懂命令行的小白写的。整个过程你只需要在网页上点点鼠标，解锁 BL 和刷机部分跟着步骤一步步来就行。如果卡住了，去 [Issues](https://github.com/wuyands/build-k40g-ksu/issues) 提问。

### Q11: `boot_img_url` 可以填别人的吗？

A: **强烈不建议**。boot.img 必须与你手机当前系统版本**完全一致**，别人的 boot.img 可能是不同 ROM 版本的，刷入后大概率不开机。一定要按[第四节](#四获取原厂-bootimg必填参数)自己提取或从对应 ROM 包获取。

### Q12: 编译出的内核会被检测为第三方内核吗？

A: 编译脚本会清除源码中自定义的 `LOCALVERSION` 标识（如 `-khanra17_v0.1` 等），并关闭 `CONFIG_LOCALVERSION_AUTO`（不再自动追加 git 提交哈希）。但这只是版本号层面的处理，**不保证**能通过所有检测（如银行 App、SafetyNet/Play Integrity 等）。如需过检测，请配合 Shamiko、LSPosed 等隐藏模块使用。

### Q13: 为什么要同时刷 boot_a 和 boot_b？

A: K40G 是 A/B 分区设备，系统会在两个槽位间切换（OTA 后切换到另一个槽位）。如果只刷一个，OTA 后另一个槽位仍是原厂内核，KSU 会失效。两个都刷最稳妥。

---

## 十一、编译细节（给想深入了解的人）

| 项目 | 说明 |
|------|------|
| 设备代号 | ares |
| SoC | MediaTek Dimensity 1200 (MT6893) |
| 架构 | arm64 |
| 内核类型 | 非 GKI（需自行编译内核） |
| 内核版本 | 4.14.186 |
| 内核源码 (KSU) | [WangCghy/KernelSU_ares](https://github.com/WangCghy/KernelSU_ares) (分支 `T`) |
| 内核源码 (KSU-Next) | [supercutefish/KernelSU-NEXT_Mi-ares](https://github.com/supercutefish/KernelSU-NEXT_Mi-ares) (分支 `main`) |
| 工具链 | Ubuntu apt `clang-18` + `lld-18` + `gcc-aarch64-linux-gnu` |
| boot 注入工具 | [magiskboot](https://github.com/topjohnwu/Magisk) (v27.0) |
| 运行环境 | ubuntu-24.04 |
| defconfig | `ares_user_defconfig` |

### 编译流程

```
1. 克隆内核源码 + KernelSU 子模块
2. make ares_user_defconfig 生成 .config
3. 清除 LOCALVERSION 标识 (隐藏第三方内核特征)
4. 强制开启 KPROBES / KSU 选项 (非 GKI 设备必需)
5. clang-18 编译内核 → out/arch/arm64/boot/Image
6. 下载 stock boot.img (用户提供的 URL)
7. magiskboot unpack boot.img → 替换 kernel → repack
8. 上传 ksu-boot-*.img 到 Release 和 Artifact
```

### 触发方式

| 触发方式 | 说明 | 产出 boot.img | 发布 Release |
|----------|------|:---:|:---:|
| 手动触发 (`workflow_dispatch`) | Actions 页手动 Run，需填 `boot_img_url` | ✅（填了 URL 时） | ✅（填了 URL 时） |
| 定时自动 (`schedule`) | 每周一 UTC 00:00 编译双版本 | ❌（无 URL 参数） | ❌ |
| Push 触发 | `.github/workflows/*.yml` 或 `build.sh` 变更时 | ❌（无 URL 参数） | ❌ |

> 📌 定时和 Push 触发由于没有 `boot_img_url` 参数，只会编译内核镜像（Artifact 可下载 `Image`），不会产出可刷入的 boot.img，也不会发布 Release。

### 产物命名规则

| 变体 | 文件名格式 | 示例 |
|------|-----------|------|
| KernelSU | `ksu-boot-YYYYMMDD-HHMM.img` | `ksu-boot-20260626-1810.img` |
| KernelSU-Next | `ksunext-boot-YYYYMMDD-HHMM.img` | `ksunext-boot-20260626-1810.img` |

---

## ⚠️ 免责声明

> 本仓库非官方编译，仅供学习研究。刷机有风险，操作需谨慎。因使用本仓库编译的内核造成的任何问题（包括但不限于：无法开机、数据丢失、硬件损坏），作者不承担任何责任。

---

## 🙏 致谢

- [KernelSU](https://github.com/tiann/KernelSU) - tiann
- [KernelSU-Next](https://github.com/rifsxd/KernelSU-Next) - rifsxd
- [Magisk](https://github.com/topjohnwu/Magisk) - topjohnwu (magiskboot 工具)
- 内核源码维护者 [WangCghy](https://github.com/WangCghy) & [supercutefish](https://github.com/supercutefish)
