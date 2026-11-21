#!/bin/bash

# Setup Ccache
export USE_CCACHE=1
export CCACHE_EXEC=$(which ccache)

# Path dan Direktori
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export KERNEL_DIR="${SCRIPT_DIR}"
export CLANG_DIR="${KERNEL_DIR}/clang-r365631c/bin"
export GCC_64_DIR="${KERNEL_DIR}/gcc-arm64/bin"
export GCC_32_DIR="${KERNEL_DIR}/gcc-arm32/bin"
export PATH="${CLANG_DIR}:${GCC_64_DIR}:${GCC_32_DIR}:${PATH}"
export LD_LIBRARY_PATH="${KERNEL_DIR}/clang-r365631c/lib64:${LD_LIBRARY_PATH}"

# Build identity (override through environment when needed)
export KBUILD_BUILD_USER="${KBUILD_BUILD_USER:-$(id -un)}"
export KBUILD_BUILD_HOST="${KBUILD_BUILD_HOST:-$(hostname)}"

# Konfigurasi Compiler dan Arsitektur
export ARCH=arm64
export SUBARCH=arm64
export CC="ccache clang"
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-android-
export CROSS_COMPILE_ARM32=arm-linux-androideabi-

cd ${KERNEL_DIR}

# Generate kombinasi defconfig
make O=out ARCH=${ARCH} CC="${CC}" vendor/xiaomi/mi8996_defconfig vendor/xiaomi/gemini.config

# Mematikan LTO untuk mencegah Out of Memory di workspace
./scripts/config --file out/.config --disable LTO
./scripts/config --file out/.config --disable LTO_CLANG
./scripts/config --file out/.config --enable LTO_NONE

# Eksekusi kompilasi
echo "Melanjutkan build tanpa LTO..."
make -j$(nproc --all) O=out ARCH=${ARCH} CC="${CC}" KCFLAGS="-Wno-unknown-warning-option" 2>&1 | tee build.log
