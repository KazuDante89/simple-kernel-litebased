#!/usr/bin/env bash
echo "Cloning dependencies"
git clone --depth=1 https://github.com/KazuDante89/simple-kernel-litebased -b lite-new kernel
cd kernel
git clone --depth=1 https://github.com/kdrag0n/proton-clang clang
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b android-9.0.0_r39 stock
git clone --depth=1 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 -b android-9.0.0_r39 stock_32
git clone --depth=1 https://github.com/KazuDante89/AnyKernel3-EAS AnyKernel
echo "Done"
GCC="$(pwd)/aarch64-linux-android-"
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
TANGGAL=$(date +"%F-%S")
START=$(date +"%s")
export CONFIG_PATH=$PWD/arch/arm64/configs/lavender-perf_defconfig
PATH="${PWD}/clang/bin:${PWD}/stock/bin:${PWD}/stock_32/bin:${PATH}"
export ARCH=arm64
export KBUILD_BUILD_HOST=circleci
export KBUILD_BUILD_USER="kazudante"
# sticker plox
function sticker() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendSticker" \
        -d sticker="CAADBQADVAADaEQ4KS3kDsr-OWAUFgQ" \
        -d chat_id=$chat_id
}
# Send info plox channel
function sendinfo() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>• [EAS]-Simple-Kernel-litebeta5 •</b>%0ABuild started on <code>Circle CI</code>%0AFor device <b>Xiaomi Redmi Note7</b> (lavender)%0Abranch <code>$(git rev-parse --abbrev-ref HEAD)</code>(master)%0AUnder commit <code>$(git log --pretty=format:'"%h : %s"' -1)</code>%0AUsing compiler: <code>$(${GCC}gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</code>%0AStarted on <code>$(date)</code>%0A<b>Build Status:</b>#beta"
}
# Push kernel to channel
function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>Xiaomi Redmi Note 7/7s (lavender)</b> | <b>$(${GCC}gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')</b>"
}
# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)"
    exit 1
}
# Compile plox
function compile() {
   make O=out ARCH=arm64 lavender-perf_defconfig
       make -j$(nproc --all) O=out \
                             ARCH=arm64 \
			     CROSS_COMPILE=aarch64-linux-android- \
			     CROSS_COMPILE_ARM32=arm-linux-androideabi-
   mv out/arch/arm64/boot/Image.gz-dtb AnyKernel/Image.gz
   cp out/arch/arm64/boot/dts/qcom/sdm660-mtp_f7a.dtb AnyKernel
}
# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 Simple-Kernel-litebased.zip *
    cd ..
}
sticker
sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push
