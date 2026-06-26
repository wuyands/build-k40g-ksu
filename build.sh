#!/bin/bash
# build.sh - 红米 K40G (ares) KernelSU 内核编译脚本
# 用法: bash build.sh <defconfig名> <是否开启kprobes>
#   参数1: defconfig 名, 不含 _defconfig 后缀 (默认 ares_user)
#   参数2: 是否强制开启 KPROBES (true/false, 默认 true)

set -e

export LC_ALL=C
export ARCH=arm64

DEFCONFIG="${1:-ares_user}"
ENABLE_KPROBES="${2:-true}"

# 脚本应在 kernel 源码根目录执行
if [ ! -f "Makefile" ] || [ ! -d "arch/arm64" ]; then
  echo "错误: 请在内核源码根目录执行此脚本"
  exit 1
fi

CLANG_DIR="${PWD}/clang"

# 1. 生成 defconfig
echo "::group::生成 .config ($DEFCONFIG)"
make O=out ARCH=arm64 "${DEFCONFIG}_defconfig"
echo "::endgroup::"

# 2. 隐藏自定义内核标识 — 防止被检测为第三方内核
echo "::group::清除 LOCALVERSION 标识"
cd out
# 使用 scripts/config 安全地修改内核配置
../scripts/config --file .config \
  --set-str CONFIG_LOCALVERSION '""' \
  --disable CONFIG_LOCALVERSION_AUTO

# 兜底: 如果 scripts/config 不可用, 直接 sed
if grep -q 'CONFIG_LOCALVERSION=' .config; then
  sed -i 's/CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION=""/g' .config
else
  echo 'CONFIG_LOCALVERSION=""' >> .config
fi
sed -i 's/CONFIG_LOCALVERSION_AUTO=y/# CONFIG_LOCALVERSION_AUTO is not set/g' .config
cd ..
make O=out ARCH=arm64 olddefconfig
echo "当前 LOCALVERSION 配置:"
grep -E "CONFIG_LOCALVERSION" out/.config || true
echo "::endgroup::"

# 3. 强制开启 KernelSU / KPROBES 相关选项 (非 GKI 设备必需)
if [ "$ENABLE_KPROBES" = "true" ]; then
  echo "::group::开启 KPROBES / KSU 选项"
  cd out
  # KernelSU 相关
  grep -q "CONFIG_KSU" .config || echo "CONFIG_KSU=y" >> .config
  sed -i 's/# CONFIG_KSU is not set/CONFIG_KSU=y/g' .config
  sed -i 's/CONFIG_KSU=.*/CONFIG_KSU=y/g' .config
  # KPROBES 相关 (KSU 运行所需)
  for opt in CONFIG_KPROBES CONFIG_HAVE_KPROBES CONFIG_KPROBE_EVENTS \
             CONFIG_MODULES CONFIG_MODULE_UNLOAD; do
    grep -q "^${opt}=" .config || echo "${opt}=y" >> .config
    sed -i "s/# ${opt} is not set/${opt}=y/g" .config
  done
  cd ..
  make O=out ARCH=arm64 olddefconfig
  echo "已开启的 KSU/KPROBES 选项:"
  grep -E "CONFIG_KSU|CONFIG_KPROBES|CONFIG_KPROBE_EVENTS" out/.config || true
  echo "::endgroup::"
fi

# 4. 编译内核 (Neutron Clang + LLVM 工具链)
echo "::group::开始编译内核"
PATH="${CLANG_DIR}/bin:${PATH}" make -j"$(nproc --all)" O=out \
  ARCH=arm64 \
  CC="clang" \
  CLANG_TRIPLE=aarch64-linux-gnu- \
  CROSS_COMPILE="${CLANG_DIR}/bin/aarch64-linux-gnu-" \
  CROSS_COMPILE_ARM32="${CLANG_DIR}/bin/arm-linux-gnueabi-" \
  LD=ld.lld \
  STRIP=llvm-strip \
  AS=llvm-as \
  AR=llvm-ar \
  NM=llvm-nm \
  OBJCOPY=llvm-objcopy \
  OBJDUMP=llvm-objdump \
  CONFIG_NO_ERROR_ON_MISMATCH=y 2>&1 | tee error.log
echo "::endgroup::"

# 5. 检查错误
if grep -qiE "error:|fatal:" error.log; then
  echo "::error::编译过程中发现错误, 请查看 error.log"
  grep -iE "error:|fatal:" error.log | head -20
  exit 1
fi

# 6. 输出产物信息
echo "::group::编译产物"
ls -lh out/arch/arm64/boot/Image* 2>/dev/null || { echo "未找到 Image, 编译失败"; exit 1; }
echo ""
echo "设备树 (dtb):"
find out/arch/arm64/boot/dts -name '*.dtb' 2>/dev/null | head -20
echo "::endgroup::"

echo ""
echo "✅ 内核编译完成: out/arch/arm64/boot/Image"
