# PocoOptimize Installation Guide

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation Methods](#installation-methods)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required
- **Device**: Poco F6 with custom ROM or MIUI (rooted preferred)
- **Android Version**: Android 13 or higher
- **Storage**: Minimum 500MB free space
- **Magisk**: Version 27.0 or higher (for Magisk modules)
- **Root Access**: Required for all installation methods

### Recommended
- USB debugging enabled
- ADB installed on computer
- A backup of your current system

## Installation Methods

### Method 1: Magisk Module (RECOMMENDED)

**Pros**: Systemless, reversible, easy on/off toggle
**Cons**: Requires Magisk

#### Steps:

1. **Download the Module**
   ```
   - Visit: https://github.com/revanthsaii/PocoOptimize/releases
   - Download: PocoOptimize-v1.0.zip (latest release)
   ```

2. **Install via Magisk Manager**
   ```
   - Open Magisk Manager
   - Tap the Modules tab
   - Tap the + button
   - Select the downloaded PocoOptimize*.zip file
   - Wait for installation to complete
   - Reboot your device
   ```

3. **Verify Installation**
   ```bash
   # After reboot, check system properties
   adb shell getprop ro.pocooptimize.enabled
   # Should return: 1
   ```

4. **Module Management**
   ```
   - Enable/Disable: Magisk Manager > Modules > Toggle
   - Remove: Long-press module > Delete
   - View logs: Magisk Manager > Logs
   ```

### Method 2: Android Native App

**Pros**: Easy UI, real-time monitoring
**Cons**: Requires app to remain installed

#### Steps:

1. **Enable Installation from Unknown Sources**
   ```
   - Settings > Security > Unknown Sources > Enable
   ```

2. **Install APK**
   ```
   - Download: PocoOptimize-v1.0.apk
   - Open with package installer
   - Tap Install
   ```

3. **Grant Root Permissions**
   ```
   - Open PocoOptimize app
   - A root permission dialog will appear
   - Tap "Grant" in SuperSU/Magisk
   ```

4. **Apply Optimizations**
   ```
   - Main screen shows optimization options
   - Select desired modules
   - Tap "Apply & Reboot"
   - Device will reboot with optimizations active
   ```

5. **Monitor Performance**
   ```
   - Dashboard tab shows real-time metrics:
     * CPU frequency
     * GPU load
     * Temperature
     * Battery drain rate
   ```

### Method 3: ADB Manual Installation

**Pros**: Full control, educational
**Cons**: Requires terminal knowledge, manual configuration

#### Prerequisites:
```bash
# Install ADB
# Windows: Download Android SDK Platform Tools
# Linux/Mac: brew install android-platform-tools

# Verify ADB connection
adb devices
# Output: device serial number should show
```

#### Steps:

1. **Push Configuration Files**
   ```bash
   # Clone the repository
   git clone https://github.com/revanthsaii/PocoOptimize.git
   cd PocoOptimize
   
   # Push property files
   adb push system-properties/performance.conf /data/local/tmp/
   adb push system-properties/battery.conf /data/local/tmp/
   adb push system-properties/thermal.conf /data/local/tmp/
   ```

2. **Apply System Properties**
   ```bash
   adb shell
   su
   
   # Performance tweaks
   setprop dalvik.vm.heapsize 512m
   setprop ro.performance.mode 1
   setprop ro.config.ringtone_path /system/media/audio/ringtones/
   
   # Battery optimization
   setprop ro.com.google.clientidbase android-google
   setprop ro.setupwizard.mode optional
   setprop ro.com.android.dataroaming false
   
   # Network tweaks
   setprop net.tcp.buffersize.default 4096,87380,704512,4096,16384,110208
   setprop net.tcp.buffersize.wifi 4096,87380,704512,4096,16384,110208
   
   # Save and persist
   exit
   exit
   adb reboot
   ```

3. **Verify Changes**
   ```bash
   adb shell
   getprop ro.performance.mode
   # Should return: 1
   ```

## Verification

### After Installation, Verify:

1. **Boot Successfully**
   - Device boots without bootloops
   - No "Unfortunately stopped" errors

2. **Check System Properties**
   ```bash
   # Via ADB
   adb shell getprop ro.pocooptimize.enabled
   
   # Or in Settings > About > Build info (if available)
   ```

3. **Run Benchmark**
   ```bash
   # Download AnTuTu or Geekbench
   # Compare scores before/after
   # Expected improvement: 10-15%
   ```

4. **Test Stability**
   - Open heavy apps (Genshin Impact, PUBG)
   - Play games for 30 minutes
   - Monitor temperature
   - Check for crashes

## Troubleshooting

### Device Won't Boot

**Solution 1: Safe Mode**
```bash
adb reboot safemode
# Uninstall problematic module
# Reboot normally
```

**Solution 2: TWRP Recovery**
```bash
# If Safe Mode doesn't work
adb reboot recovery
# In TWRP: Wipe Dalvik Cache
# Reboot System
```

**Solution 3: Restore Backup**
```bash
# If you made a backup before installation
# Restore using TWRP or your backup tool
```

### Performance Not Improved

- **Check installation**: Verify properties are set
- **Clear cache**: Settings > Apps > Storage > Clear Cache
- **Update module**: Download latest version
- **Check conflicts**: Other optimization apps may conflict

### Device Heating Excessively

- **Disable thermal management module**
- **Check background processes**
- **Reduce refresh rate to 60Hz**
- **Let device cool down before using**

### Battery Drain Increased

- **Disable battery module**
- **Check for wakelocks**: BetterBatteryStats app
- **Restore default battery config**

## Rollback Instructions

### Via Magisk Manager
```
Modules > PocoOptimize > Delete > Reboot
```

### Via ADB
```bash
adb shell
su
setprop ro.performance.mode 0
# Reset other properties to default
exit
exit
adb reboot
```

## Support

If you encounter issues:
1. Check [Troubleshooting](docs/TROUBLESHOOTING.md)
2. Visit [GitHub Issues](https://github.com/revanthsaii/PocoOptimize/issues)
3. Join our [Discussions](https://github.com/revanthsaii/PocoOptimize/discussions)

---

**Last Updated**: December 2024
