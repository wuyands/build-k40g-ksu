# 🔧 红米K40G KernelSU 内核 — 小白也能用的云端自动编译

> 📱 适用设备：**红米 K40 游戏增强版**（代号 `ares`，也称 POCO F3 GT）
>
> 🎯 本仓库让你**不需要电脑装环境、不需要懂命令行**，只需要动动鼠标在网页上点几下，就能在 GitHub 云端自动编译出带有 KernelSU 的内核刷机包！

---

## 📋 目录

1. [前置准备：开启 GitHub Actions](#一前置准备开启-github-actions)
2. [Fork 仓库到你的账号](#二fork-仓库到你的账号)
3. [配置权限（GitHub Token）](#三配置权限github-token)
4. [手动触发编译](#四手动触发编译)
5. [下载刷机包](#五下载刷机包)
6. [解锁 BootLoader](#六解锁-bootloader)
7. [刷入内核](#七刷入内核)
8. [验证 KernelSU 是否生效](#八验证-kernelsu-是否生效)
9. [常见问题 FAQ](#九常见问题-faq)
10. [编译细节（给想深入了解的人）](#十编译细节给想深入了解的人)

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

编译完成后的刷机包会自动发布到 **Release** 页面，这需要你给 Actions 一个"写权限"。操作如下：

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

## 四、手动触发编译

### 4.1 标准用户（大部分情况）

1. 在你 Fork 的仓库页面，点 **Actions** 标签页
2. 左侧找到工作流 **「编译红米K40G KernelSU 内核」**
3. 点击 **Run workflow** 下拉按钮
4. 弹出的参数保持默认就行：
   - **KernelSU 版本**：选 `KernelSU`（新手推荐）
   - **defconfig**：默认 `ares_user`（不要改）
   - **内核源码分支**：默认 `main`（不要改）
   - **强制开启 KPROBES**：默认 `true`（不要改）
5. 点击绿色 **Run workflow** 按钮
6. 等待约 20-40 分钟（可以在 Actions 页面看进度）

### 4.2 进阶用户（可选）

- 如果想尝鲜，**KernelSU 版本**可以选 `KernelSU-Next`
- 定时自动编译：每周一 UTC 00:00 自动跑一次，同时编译 KSU 和 KSU-Next 双版本
- 手动编译触发后会**自动发布 Release**，定时编译也一样

---

## 五、下载刷机包

编译完成后，刷机包会出现在两个地方：

### 方式一：从 Release 下载（推荐）

1. 在你 Fork 的仓库页面，点击右侧 **Releases**
2. 找到最新的 Release（名字类似 `KernelSU 红米K40G 内核 #1`）
3. 下载 `.zip` 文件，例如 `ksu-ares-20250626-1200.zip`

### 方式二：从 Actions Artifact 下载

1. 在 Actions 页面点进刚完成的运行记录
2. 页面底部 **Artifacts** 区域下载 `.zip` 文件
3. Artifact 会保存 30 天，到期自动删除

> 📥 下载到电脑上后，把这个 zip 文件传到手机里备用。

---

## 六、解锁 BootLoader

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

## 七、刷入内核

### 方案一：TWRP 卡刷（推荐小白）

1. 下载 ares 的 TWRP Recovery：[TWRP for ares](https://twrp.me)
2. 手机关机，同时按住 **音量下 + 电源键** 进入 Fastboot
3. 电脑执行：`fastboot flash recovery twrp-ares.img`
4. 同时按住 **音量上 + 电源键** 进入 TWRP
5. 在 TWRP 中点 **安装**，选择你传到手机的 `.zip` 刷机包
6. 滑动确认刷入，完成后点 **重启系统**

### 方案二：Fastboot 直接刷入

1. 把 zip 包解压，提取出 `Image` 文件
2. 用 [magiskboot](https://github.com/topjohnwu/Magisk/releases) 替换原厂 boot.img 的内核
3. 执行 `fastboot flash boot 修改后的boot.img`

> ⚠️ 方案二较复杂，新手直接用 TWRP 卡刷即可。

---

## 八、验证 KernelSU 是否生效

刷完后开机，验证 KernelSU 是否正常工作：

1. 下载安装 [KernelSU Manager](https://github.com/tiann/KernelSU/releases)（下载 `.apk` 安装）
2. 打开 KernelSU Manager
3. 如果看到界面显示「工作中」或类似提示，说明刷入成功 ✅
4. 如果显示「不支持」或「未安装」，说明内核刷入失败，请检查：
   - 是否刷入了正确的 zip 包？
   - 是否下载了最新的 Release？
   - 手机系统版本是否和内核匹配？

---

## 九、常见问题 FAQ

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

A: 可能是内核版本与当前系统不匹配。进入 Fastboot，刷回官方 boot.img 即可恢复：
1. 从官方 ROM 包中提取 boot.img
2. `fastboot flash boot boot.img` 刷回

### Q6: 需要 Root 权限才能刷吗？

A: 不需要。只要解锁了 BootLoader，就可以刷入内核。KernelSU 本身就是一种 Root 方案，刷入后你就有 Root 权限了。

### Q7: KernelSU 和 KernelSU-Next 有什么区别？

A: KernelSU 是原版；KernelSU-Next 是社区维护的增强版，增加了更多内核版本的兼容性和新特性。新手建议先用 KernelSU。

### Q8: 我的系统是 MIUI/HyperOS，能用吗？

A: 可以。只要内核源码和当前系统版本匹配就行。如果刷入后不开机，说明内核版本不匹配，刷回官方 boot.img 即可。

### Q9: 可以用在非 MIUI 系统上吗（类原生等）？

A: 取决于内核是否兼容。理论上只要是 ares 的 ROM 都可以尝试，但不保证 100% 兼容。

### Q10: 我不懂技术，这个教程我真的能操作下来吗？

A: 可以！这个教程就是为不懂命令行的小白写的。整个过程你只需要在网页上点点鼠标，解锁 BL 和刷机部分跟着截图一步步来就行。如果卡住了，去 [Issues](https://github.com/wuyands/build-k40g-ksu/issues) 提问。

### Q11: 编译出的内核会被检测为第三方内核吗？

A: **不会。** 本仓库的编译脚本已经做了处理，编译时会自动清除源码中自带的自定义版本标识（如 `-khanra17_v0.1` 等），并且关闭 `CONFIG_LOCALVERSION_AUTO`（不再自动追加 git 提交哈希）。编译后的内核 `uname -r` 输出将与官方内核一致（`4.14.186`），无法通过版本号区分是否为第三方内核。

---

## 十、编译细节（给想深入了解的人）

| 项目 | 说明 |
|------|------|
| 设备代号 | ares |
| SoC | MediaTek Dimensity 1200 (MT6893) |
| 架构 | arm64 |
| 内核类型 | 非 GKI（需自行编译内核） |
| 内核版本 | 4.14.186 |
| 内核源码 (KSU) | [WangCghy/KernelSU_ares](https://github.com/WangCghy/KernelSU_ares) |
| 内核源码 (KSU-Next) | [supercutefish/KernelSU-NEXT_Mi-ares](https://github.com/supercutefish/KernelSU-NEXT_Mi-ares) |
| 工具链 | Neutron Clang (09092023) |
| 打包工具 | [osm0sis/AnyKernel3](https://github.com/osm0sis/AnyKernel3) |
| 运行环境 | ubuntu-22.04 |
| defconfig | `ares_user_defconfig` |

### 关于内核标识

编译脚本会自动清除源码中的自定义 `LOCALVERSION`（如 `-khanra17_v0.1`、`-eatcatsfish-T`），并禁用 `CONFIG_LOCALVERSION_AUTO`（不再自动追加 git 哈希）。因此编译后 `uname -r` 输出为纯净的 `4.14.186`，与官方内核一致，不会被检测为第三方内核。

### 触发方式

| 触发方式 | 说明 | 发布 Release |
|----------|------|:---:|
| 手动触发 | Actions 页手动 Run workflow | ✅ |
| 定时自动 | 每周一 UTC 00:00 编译双版本 | ✅ |
| Push 触发 | workflow/build.sh 变更时编译 KSU | ❌ |

---

## ⚠️ 免责声明

> 本仓库非官方编译，仅供学习研究。刷机有风险，操作需谨慎。因使用本仓库编译的内核造成的任何问题（包括但不限于：无法开机、数据丢失、硬件损坏），作者不承担任何责任。

---

## 🙏 致谢

- [KernelSU](https://github.com/tiann/KernelSU) - tiann
- [KernelSU-Next](https://github.com/rifsxd/KernelSU-Next) - rifsxd
- [AnyKernel3](https://github.com/osm0sis/AnyKernel3) - osm0sis
- [Neutron Clang](https://github.com/Neutron-Toolchains/neutron-toolchains)
- 内核源码维护者 [WangCghy](https://github.com/WangCghy) & [supercutefish](https://github.com/supercutefish)
