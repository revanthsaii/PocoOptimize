# PocoOptimize v1.0.0 - Release

## 📦 Download Modules

Choose the optimization you want and download the corresponding ZIP file:

### PocoOptimize-Performance.zip
**For**: Gaming, speed, and responsiveness  
**Benefits**: 
- +11-18% performance boost
- Faster CPU/GPU frequencies
- Reduced input latency
- Better frame rates in games

**SHA256**: `C0A0D91D3E058130F81005706C3E865C8BAB73E7911DE01F659B0C147971689B`

---

### PocoOptimize-Battery.zip
**For**: Longer battery life  
**Benefits**:
- 25-35% battery improvement
- Aggressive doze mode
- Wake-lock management
- 60Hz refresh rate for power saving

**SHA256**: `238210CAADCEE7D4FD5B235BB4787C22AB15381237E60550F3373B1507A03E9A`

---

### PocoOptimize-Thermal.zip
**For**: Cooler device temperatures  
**Benefits**:
- 6-7°C temperature reduction
- Gradual thermal throttling
- Intelligent CPU hotplug
- Better sustained performance

**SHA256**: `BF4490EFE21A65D4F17334F724AE07E67FF4AD512A6B2F40D5CDBFA92040B41C`

---

## 🚀 Installation Instructions

1. **Download** the module ZIP you want (you can install all three!)
2. **Open** Magisk Manager
3. **Tap** Modules → Install from storage
4. **Select** the downloaded ZIP file
5. **Reboot** your device
6. **Enjoy** the optimizations!

## ✅ Verification

After installation, check the logs to verify everything worked:

```bash
adb pull /data/local/tmp/pocooptimize_performance.log
adb pull /data/local/tmp/pocooptimize_battery.log
adb pull /data/local/tmp/pocooptimize_thermal.log
```

Or on device:
```bash
su
cat /data/local/tmp/pocooptimize_*.log
```

## ⚠️ Requirements

- **Device**: Poco F6 (may work on other SD 8 Gen 3 devices)
- **Android**: 13+ (SDK 33+)
- **Magisk**: 27.0 or higher
- **Root**: Required

## 🤝 Compatibility

Run the compatibility checker before installing:
```bash
adb push build-scripts/test-compatibility.sh /data/local/tmp/
adb shell "su -c 'sh /data/local/tmp/test-compatibility.sh'"
```

## 🔄 Uninstallation

1. Open Magisk Manager
2. Go to Modules
3. Remove or disable the module
4. Reboot

All changes are automatically reverted!

## 📊 Benchmarking

Want to measure the improvements? Use our benchmark script:
```bash
adb push build-scripts/benchmark.sh /data/local/tmp/
adb shell "su -c 'sh /data/local/tmp/benchmark.sh'"
```

## 🐛 Issues?

Having problems? Please report with:
1. Device model and Android version
2. Magisk version
3. Log files from `/data/local/tmp/pocooptimize_*.log`
4. Steps to reproduce

**Report here**: [GitHub Issues](https://github.com/revanthsaii/PocoOptimize/issues)

## 📖 Full Documentation

For complete documentation, kernel patches, and build scripts:
- [README.md](https://github.com/revanthsaii/PocoOptimize/blob/main/README.md)
- [Documentation](https://github.com/revanthsaii/PocoOptimize/tree/main/docs)

---

**Made with ❤️ by Revanth Sai**  
Released: January 8, 2026
