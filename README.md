# 🔧 红米K40G KernelSU 内核 — 小白也能用的云端自动编译

> 📱 适用设备：**红米 K40 游戏增强版**（代号 `ares`，也称 POCO F3 GT）
>
> 🎯 本仓库让你**不需要电脑装环境、不需要懂命令行**，只需要动动鼠标在网页上点几下，就能在 GitHub 云端自动编译出带有 KernelSU 的 **boot.img**，直接 `fastboot flash boot` 刷入即可！

---

## 📋 目录

1. [前置准备：开启 GitHub Actions](#一前置准备开启-github-actions)
2. [Fork 仓库到你的账号](#二fork-仓库到你的账号)
3. [配置权限（GitHub Token）](#三配置权限github-token)
4. [获取原厂 stock boot.img](#四获取原厂-stock-bootimg)
5. [手动触发编译](#五手动触发编译)
6. [下载 boot.img](#六下载-bootimg)
7. [解锁 BootLoader](#七解锁-bootloader)
8. [刷入 boot.img](#八刷入-bootimg)
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

> 💡 **Fork 之后要不要修改任何文件？** 不需要！直接跳到下一步配置 Token 就行。

---

## 三、配置权限（GitHub Token）

编译完成后的 boot.img 会自动发布到 **Release** 页面，这需要你给 Actions 一个"写权限"。操作如下：

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

## 四、获取原厂 stock boot.img

> ⚠️ **这一步非常重要！** 工作流需要你提供原厂 boot.img 的下载地址，编译时会把 KernelSU 内核注入到这个 boot.img 里。如果 boot.img 和你手机当前系统版本不匹配，刷入后可能无法开机！

### 4.1 从哪里获取 boot.img？

boot.img 包含在小米官方线刷固件包里。获取方式：

1. 到 [MIUI 官方 ROM 下载站](https://roms.miuier.com/zh-cn/devices/ares/) 查找 ares（红米K40游戏增强版）的线刷包
2. 下载和你手机当前系统版本一致的 **fastboot 线刷包**（.tgz 格式，几个G）
3. 解压后找到 `boot.img` 文件（通常在 `images/` 目录下）

> 💡 **不会找？** 看手机：设置 → 我的设备 → MIUI 版本，记下完整版本号（如 `14.0.4.0.SJPCNXM`），然后到下载站找对应版本。

### 4.2 上传 boot.img 到可下载的地方

工作流需要一个**直接下载链接**（URL）来拉取 boot.img。你可以：

**方式A：上传到你的 GitHub 仓库 Release（推荐）**
1. 在你 Fork 的仓库创建一个 Release（随便起个 tag，如 `stock-boot`）
2. 把 boot.img 作为附件上传
3. 复制下载链接（右键附件 → 复制链接地址）

**方式B：上传到网盘/图床**
- 上传到支持直链下载的网盘或文件托管服务
- 确保链接是**直接下载**的（不是预览页面）

> ⚠️ 链接必须是 `curl` 能直接下载的直链，不能是需要登录或跳转的页面。

### 4.3 记下这个下载链接

下一步触发编译时需要填入这个 URL。

---

## 五、手动触发编译

### 5.1 触发工作流

1. 在你 Fork 的仓库页面，点 **Actions** 标签页
2. 左侧找到工作流 **「编译红米K40G KernelSU 内核」**
3. 点击 **Run workflow** 下拉按钮
4. 填写参数：
   - **KernelSU 版本**：选 `KernelSU`（新手推荐）
   - **defconfig**：默认 `ares_user`（不懂就别改）
   - **内核源码分支**：留空（自动用默认分支）
   - **强制开启 KPROBES**：默认 `true`（不懂就别改）
   - **原厂 stock boot.img 下载地址**：⚠️ **必填！** 粘贴第四步获取的 boot.img 直链 URL
5. 点击绿色 **Run workflow** 按钮
6. 等待约 20-40 分钟（可以在 Actions 页面看进度）

### 5.2 注意事项

- **boot.img 必须和你手机当前系统版本一致**，否则刷入后可能无法开机
- 编译完成后会自动发布 Release，里面是已注入 KSU 内核的 boot.img
- 定时任务（每周一）因为无法自动获取 boot.img URL，不会发布 Release

---

## 六、下载 boot.img

编译完成后，boot.img 会出现在两个地方：

### 方式一：从 Release 下载（推荐）

1. 在你 Fork 的仓库页面，点击右侧 **Releases**
2. 找到最新的 Release（名字类似 `KernelSU 红米K40G 内核 #1`）
3. 下载 `.img` 文件，例如 `ksu-boot-20250626-1200.img`

### 方式二：从 Actions Artifact 下载

1. 在 Actions 页面点进刚完成的运行记录
2. 页面底部 **Artifacts** 区域下载 `.img` 文件
3. Artifact 会保存 30 天，到期自动删除

> 📥 下载到电脑上后，这个 img 文件就是已经注入了 KernelSU 内核的 boot.img。

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

## 八、刷入 boot.img

### 8.1 准备工作

1. 电脑安装 [ADB 和 Fastboot 工具](https://developer.android.com/studio/releases/platform-tools)
2. 手机进入 Fastboot 模式（关机后按住 **音量下 + 电源键**）
3. USB 连接电脑
4. 打开命令提示符/终端，输入 `fastboot devices` 确认能识别到设备

### 8.2 刷入 boot.img

```bash
fastboot flash boot <下载的img文件名>
fastboot reboot
```

例如：
```bash
fastboot flash boot ksu-boot-20250626-1200.img
fastboot reboot
```

### 8.3 ⚠️ 安全建议：先临时引导测试

如果不确定 boot.img 是否兼容，可以先**临时引导**（不写入手机）：
```bash
fastboot boot <下载的img文件名>
```

如果能正常开机，说明兼容，再用 `fastboot flash boot` 正式刷入。如果无法开机，直接拔线重启即可恢复原系统。

> 💡 临时引导只是这一次用新内核启动，重启后还是原来的系统，不会修改手机里的任何东西。

---

## 九、验证 KernelSU 是否生效

刷完后开机，验证 KernelSU 是否正常工作：

1. 下载安装 [KernelSU Manager](https://github.com/tiann/KernelSU/releases)（下载 `.apk` 安装）
2. 打开 KernelSU Manager
3. 如果看到界面显示「工作中」或类似提示，说明刷入成功 ✅
4. 如果显示「不支持」或「未安装」，说明内核刷入失败，请检查：
   - boot.img 是否和你手机系统版本匹配？
   - 是否下载了最新的 Release？
   - 是否刷入了正确的分区（boot 分区，不是其他）？

---

## 十、常见问题 FAQ

### Q1: 编译失败了怎么办？

A: 点进 Actions 里失败的运行记录，查看日志找报错信息。常见原因：
- boot.img 下载失败 → 检查 URL 是否正确、是否为直链
- 网络问题导致源码下载失败 → 重新跑一次
- 如果多次失败，去 [Issues](https://github.com/wuyands/build-k40g-ksu/issues) 提问

### Q2: 刷入后无法开机怎么办？

A: 可能是 boot.img 与当前系统版本不匹配。进入 Fastboot，刷回官方 boot.img 即可恢复：
```bash
fastboot flash boot stock_boot.img
fastboot reboot
```

> 💡 所以第四步获取的 stock boot.img **一定要备份**，万一翻车可以刷回去。

### Q3: Fork 后还能同步原仓库的更新吗？

A: 可以。在你 Fork 的仓库页面，点击 **Sync fork** → **Update branch** 即可同步。

### Q4: 编译一次要多久？

A: 约 20-40 分钟，取决于 GitHub Actions 服务器的繁忙程度。

### Q5: GitHub Actions 免费额度够用吗？

A: 够用。GitHub 免费账号每月有 2000 分钟 Actions 额度，编译一次约 30 分钟，一个月编译几次完全够用。

### Q6: 需要 Root 权限才能刷吗？

A: 不需要。只要解锁了 BootLoader，就可以用 fastboot 刷入 boot.img。KernelSU 本身就是一种 Root 方案，刷入后你就有 Root 权限了。

### Q7: KernelSU 和 KernelSU-Next 有什么区别？

A: KernelSU 是原版；KernelSU-Next 是社区维护的增强版。新手建议先用 KernelSU。

### Q8: 我的系统是 MIUI/HyperOS，能用吗？

A: 可以。关键是 boot.img 要从你当前系统版本的固件包里提取。如果刷入后不开机，刷回官方 boot.img 即可。

### Q9: 编译出的内核会被检测为第三方内核吗？

A: **不会。** 编译脚本会自动清除源码中的自定义版本标识（如 `-khanra17_v0.1` 等），编译后 `uname -r` 输出与官方一致（`4.14.186`）。

### Q10: 定时任务为什么不发布 Release？

A: 定时任务（每周一）无法自动获取你的 boot.img URL（每次需要你手动填写），所以定时任务只编译内核不生成 boot.img、不发布 Release。要获取 boot.img，请手动触发工作流。

---

## 十一、编译细节（给想深入了解的人）

| 项目 | 说明 |
|------|------|
| 设备代号 | ares |
| SoC | MediaTek Dimensity 1200 (MT6893) |
| 架构 | arm64 |
| 内核类型 | 非 GKI（需自行编译内核） |
| 内核版本 | 4.14.186 |
| 内核源码 (KSU) | [WangCghy/KernelSU_ares](https://github.com/WangCghy/KernelSU_ares) |
| 内核源码 (KSU-Next) | [supercutefish/KernelSU-NEXT_Mi-ares](https://github.com/supercutefish/KernelSU-NEXT_Mi-ares) |
| 编译工具链 | apt clang-18 + lld-18 (Ubuntu 24.04) |
| boot.img 注入工具 | [magiskboot](https://github.com/topjohnwu/Magisk) (Magisk v27.0) |
| 运行环境 | ubuntu-24.04 |
| defconfig | `ares_user_defconfig` |

### 工作流程

1. 克隆内核源码 + 初始化 KernelSU 子模块
2. 用 apt 安装的 clang-18 编译内核 → 产出 `Image`
3. 下载用户提供的 stock boot.img
4. 用 magiskboot 解包 boot.img → 替换内核为编译出的 Image → 重新打包
5. 上传 boot.img artifact + 发布到 Release

### 关于内核标识

编译脚本会自动清除源码中的自定义 `LOCALVERSION`，并禁用 `CONFIG_LOCALVERSION_AUTO`。因此编译后 `uname -r` 输出为纯净的 `4.14.186`，与官方内核一致。

### 触发方式

| 触发方式 | 说明 | 生成 boot.img | 发布 Release |
|----------|------|:---:|:---:|
| 手动触发 | 需填写 boot.img URL | ✅ | ✅ |
| 定时自动 | 每周一编译双版本 | ❌（无 URL） | ❌ |
| Push 触发 | workflow/build.sh 变更时编译 | ❌（无 URL） | ❌ |

---

## ⚠️ 免责声明

> 本仓库非官方编译，仅供学习研究。刷机有风险，操作需谨慎。因使用本仓库编译的内核造成的任何问题（包括但不限于：无法开机、数据丢失、硬件损坏），作者不承担任何责任。

---

## 🙏 致谢

- [KernelSU](https://github.com/tiann/KernelSU) - tiann
- [KernelSU-Next](https://github.com/rifsxd/KernelSU-Next) - rifsxd
- [Magisk](https://github.com/topjohnwu/Magisk) - topjohnwu (magiskboot 工具)
- 内核源码维护者 [WangCghy](https://github.com/WangCghy) & [supercutefish](https://github.com/supercutefish)
