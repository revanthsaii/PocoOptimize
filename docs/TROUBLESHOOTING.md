# Troubleshooting Guide

## Common Issues

### Device Won't Boot
**Problem:** Device bootloops after installing PocoOptimize

**Solution:**
1. Boot into safe mode: `adb reboot safemode`
2. Disable the problematic module
3. Reboot normally
4. Re-enable modules one at a time to identify the issue

### Performance Not Improved
**Problem:** No FPS improvement in games

**Solution:**
1. Verify installation: Check system properties are applied
2. Clear app cache: Settings > Apps > Storage > Clear Cache
3. Disable other optimization apps (they may conflict)
4. Reboot device
5. Update to latest PocoOptimize version

### Device Heating
**Problem:** Temperature increased after installation

**Solution:**
1. Disable thermal management module
2. Check for background tasks consuming CPU
3. Reduce refresh rate to 60Hz
4. Allow device to cool before using

### Battery Drain Increased
**Problem:** Battery drains faster

**Solution:**
1. Disable battery optimization module
2. Check for wakelocks: Use BetterBatteryStats app
3. Clear cache and restart
4. Restore default battery config

### Module Installation Failed
**Problem:** Magisk installation fails

**Solution:**
1. Update Magisk to v27.0+
2. Clear Magisk cache
3. Download latest module version
4. Try installing again

## Getting Help

- Check [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) for setup issues
- Visit GitHub Issues for bugs
- Join Discussions for questions
