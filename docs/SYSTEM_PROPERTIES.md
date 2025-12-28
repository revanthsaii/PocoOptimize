# System Properties Reference

## Overview

This document lists all system properties modified by PocoOptimize.

## Performance Properties

```properties
ro.performance.mode=1
sys.perf_mode_enabled=1
ro.kernel.android.checkjni=0
```

## Battery Properties

```properties
ro.setupwizard.mode=optional
ro.com.android.dataroaming=false
power.messaging.wakelock_timeout=60000
power.nonscreen_timeout=300000
```

## Display Properties

```properties
ro.min_refresh_rate=60
ro.peak_refresh_rate=120
```

## Network Properties

```properties
net.tcp.buffersize.default=4096,87380,704512,4096,16384,110208
net.tcp.buffersize.wifi=4096,87380,704512,4096,16384,110208
```

## Memory Properties

```properties
vm.swappiness=100
vm.vfs_cache_pressure=50
```

## GPU Properties

```properties
ro.opengles.version=196610
```

For more details, see KERNEL_MODS.md
