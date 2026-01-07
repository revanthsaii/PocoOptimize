#!/bin/bash
# PocoOptimize - Compatibility Test Script
# Tests device compatibility before installation

echo "========================================"
echo "PocoOptimize Compatibility Checker"
echo "========================================"

# Check if running on Android
if [ ! -f /system/build.prop ]; then
    echo "ERROR: Not running on Android device"
    exit 1
fi

echo "✓ Running on Android device"

# Get device info
DEVICE_MODEL=$(getprop ro.product.model)
DEVICE_BRAND=$(getprop ro.product.brand)
DEVICE_NAME=$(getprop ro.product.name)
ANDROID_VERSION=$(getprop ro.build.version.release)
SDK_VERSION=$(getprop ro.build.version.sdk)
SOC_MODEL=$(getprop ro.soc.model)

echo ""
echo "Device Information:"
echo "  Brand: $DEVICE_BRAND"
echo "  Model: $DEVICE_MODEL"
echo "  Name: $DEVICE_NAME"
echo "  Android: $ANDROID_VERSION (SDK $SDK_VERSION)"
echo "  SOC: $SOC_MODEL"
echo ""

# Check if Poco F6
COMPATIBLE=0
if echo "$DEVICE_MODEL" | grep -qi "Poco F6\|23113RKC6G"; then
    echo "✓ Device detected: Poco F6 (Primary target)"
    COMPATIBLE=1
elif echo "$SOC_MODEL" | grep -qi "SM8650\|8 Gen 3"; then
    echo "⚠ Device uses Snapdragon 8 Gen 3 (May be compatible)"
    COMPATIBLE=1
else
    echo "⚠ WARNING: This is not a Poco F6"
    echo "  Optimizations may not work properly"
    echo "  Proceed with caution"
fi

# Check Android version
if [ "$SDK_VERSION" -lt 33 ]; then
    echo "✗ ERROR: Android 13+ (SDK 33+) required"
    echo "  Your version: Android $ANDROID_VERSION (SDK $SDK_VERSION)"
    exit 1
fi

echo "✓ Android version compatible (SDK $SDK_VERSION)"

# Check for root access
if ! command -v su &> /dev/null; then
    echo "✗ ERROR: Root access not available"
    echo "  Please root your device first"
    exit 1
fi

echo "✓ Root access available"

# Check for Magisk
if [ ! -d /data/adb/magisk ]; then
    echo "✗ ERROR: Magisk not detected"
    echo "  Please install Magisk 27.0+"
    exit 1
fi

MAGISK_VERSION=$(magisk -V 2>/dev/null || echo "unknown")
echo "✓ Magisk detected (Version: $MAGISK_VERSION)"

if [ "$MAGISK_VERSION" != "unknown" ] && [ "$MAGISK_VERSION" -lt 27000 ]; then
    echo "⚠ WARNING: Magisk 27.0+ recommended"
    echo "  Your version may be outdated"
fi

# Check available storage
FREE_SPACE=$(df /data | tail -1 | awk '{print $4}')
if [ "$FREE_SPACE" -lt 512000 ]; then  # 512MB in KB
    echo "⚠ WARNING: Low storage space on /data"
    echo "  At least 500MB free space recommended"
else
    echo "✓ Sufficient storage available"
fi

# Check kernel version
KERNEL_VERSION=$(uname -r)
echo ""
echo "Kernel version: $KERNEL_VERSION"

# Check for key kernel features
echo ""
echo "Checking kernel features:"

# CPU frequency scaling
if [ -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
    echo "  ✓ CPU frequency scaling supported"
else
    echo "  ✗ CPU frequency scaling not found"
fi

# GPU device
if [ -d /sys/class/kgsl/kgsl-3d0 ]; then
    echo "  ✓ Adreno GPU detected"
else
    echo "  ⚠ GPU control may not work"
fi

# Thermal zones
THERMAL_ZONES=$(ls -d /sys/class/thermal/thermal_zone* 2>/dev/null | wc -l)
echo "  ✓ Thermal zones found: $THERMAL_ZONES"

# I/O schedulers
if [ -f /sys/block/sda/queue/scheduler ]; then
    SCHEDULERS=$(cat /sys/block/sda/queue/scheduler)
    echo "  ✓ I/O schedulers: $SCHEDULERS"
fi

echo ""
echo "========================================"
if [ $COMPATIBLE -eq 1 ]; then
    echo "✓ Device is compatible with PocoOptimize"
    echo "  You can proceed with installation"
    exit 0
else
    echo "⚠ Compatibility check completed with warnings"
    echo "  Review warnings above before proceeding"
    exit 2
fi
