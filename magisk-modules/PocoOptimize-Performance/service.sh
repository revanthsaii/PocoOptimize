#!/system/bin/sh
# PocoOptimize Performance Module - Service Script
# Runs on boot to apply performance optimizations
# Author: Revanth Sai

MODDIR=${0%/*}
LOG_FILE="/data/local/tmp/pocooptimize_performance.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log "========================================="
log "PocoOptimize Performance Module Starting"
log "========================================="

# Wait for system to fully boot
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 1
done

log "System boot completed, waiting additional 30s for stability..."
sleep 30

# ===== CPU OPTIMIZATION =====
log "Applying CPU optimizations..."

# Set CPU governor to schedutil on all cores
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    if [ -f "$cpu" ]; then
        echo "schedutil" > "$cpu" 2>/dev/null && log "Set schedutil governor: $cpu"
    fi
done

# CPU frequency scaling (if writable)
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
    if [ -w "$cpu" ]; then
        echo "3187200" > "$cpu" 2>/dev/null && log "Set max freq: $cpu"
    fi
done

# Input boost optimization
if [ -f /sys/module/cpu_boost/parameters/input_boost_freq ]; then
    echo "0:1804800 1:0 2:0 3:0 4:2419200 5:0 6:0 7:0" > /sys/module/cpu_boost/parameters/input_boost_freq 2>/dev/null
    log "Applied input boost configuration"
fi

if [ -f /sys/module/cpu_boost/parameters/input_boost_ms ]; then
    echo "100" > /sys/module/cpu_boost/parameters/input_boost_ms 2>/dev/null
    log "Set input boost duration to 100ms"
fi

# ===== GPU OPTIMIZATION =====
log "Applying GPU optimizations..."

# GPU governor
if [ -f /sys/class/kgsl/kgsl-3d0/devfreq/governor ]; then
    echo "msm-adreno-tz" > /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null
    log "Set GPU governor to msm-adreno-tz"
fi

# GPU max frequency
if [ -f /sys/class/kgsl/kgsl-3d0/max_gpuclk ]; then
    echo "855000000" > /sys/class/kgsl/kgsl-3d0/max_gpuclk 2>/dev/null
    log "Set GPU max frequency to 855MHz"
fi

# GPU idle timeout
if [ -f /sys/class/kgsl/kgsl-3d0/idle_timer ]; then
    echo "64" > /sys/class/kgsl/kgsl-3d0/idle_timer 2>/dev/null
    log "Set GPU idle timer to 64ms"
fi

# ===== MEMORY OPTIMIZATION =====
log "Applying memory optimizations..."

# VM swappiness
if [ -f /proc/sys/vm/swappiness ]; then
    echo "60" > /proc/sys/vm/swappiness 2>/dev/null
    log "Set swappiness to 60"
fi

# VFS cache pressure
if [ -f /proc/sys/vm/vfs_cache_pressure ]; then
    echo "100" > /proc/sys/vm/vfs_cache_pressure 2>/dev/null
    log "Set VFS cache pressure to 100"
fi

# Dirty ratio for better IO
if [ -f /proc/sys/vm/dirty_ratio ]; then
    echo "20" > /proc/sys/vm/dirty_ratio 2>/dev/null
    log "Set dirty ratio to 20"
fi

if [ -f /proc/sys/vm/dirty_background_ratio ]; then
    echo "10" > /proc/sys/vm/dirty_background_ratio 2>/dev/null
    log "Set dirty background ratio to 10"
fi

# ===== I/O SCHEDULER =====
log "Applying I/O scheduler optimizations..."

for queue in /sys/block/*/queue; do
    if [ -f "$queue/scheduler" ]; then
        # Try to set deadline, fallback to available schedulers
        echo "deadline" > "$queue/scheduler" 2>/dev/null || echo "cfq" > "$queue/scheduler" 2>/dev/null
    fi
    
    # Increase read-ahead
    if [ -f "$queue/read_ahead_kb" ]; then
        echo "2048" > "$queue/read_ahead_kb" 2>/dev/null
    fi
done

log "I/O scheduler configuration applied"

# ===== KERNEL TWEAKS =====
log "Applying kernel tweaks..."

# Disable gentle fair sleepers for better gaming performance
if [ -f /sys/kernel/debug/sched_features ]; then
    echo "NO_GENTLE_FAIR_SLEEPERS" > /sys/kernel/debug/sched_features 2>/dev/null
    log "Disabled gentle fair sleepers"
fi

# TCP congestion control
if [ -f /proc/sys/net/ipv4/tcp_congestion_control ]; then
    echo "bbr" > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null || \
    echo "cubic" > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null
    log "Set TCP congestion control"
fi

# ===== TOUCHSCREEN OPTIMIZATION =====
log "Applying touchscreen optimizations..."

# Reduce touch latency (device-specific, may not work on all devices)
if [ -d /sys/class/input ]; then
    for touch in /sys/class/input/input*/; do
        if [ -f "${touch}name" ]; then
            name=$(cat "${touch}name")
            if echo "$name" | grep -qi "touch\|fts\|atmel"; then
                # Adjust touch sampling rate if supported
                if [ -f "${touch}poll_ms" ]; then
                    echo "4" > "${touch}poll_ms" 2>/dev/null
                    log "Set touch polling for $name"
                fi
            fi
        fi
    done
fi

# ===== DISPLAY & RENDERING =====
log "Checking display configurations..."

# SurfaceFlinger optimizations are applied via system.prop

log "Performance optimizations applied successfully!"
log "Module version: v1.0.0"
log "========================================="

exit 0
