#!/bin/bash
# PocoOptimize - Performance Test
# Benchmarks system performance to measure improvements

echo "========================================"
echo "PocoOptimize Performance Test"
echo "========================================"

LOG_FILE="/sdcard/pocooptimize_perf_$(date '+%Y%m%d_%H%M%S').log"

log() {
    echo "$1" | tee -a "$LOG_FILE"
}

log "Device: $(getprop ro.product.model)"
log "Test started: $(date)"
log ""

# CPU Performance Test
log "========== CPU BENCHMARK =========="
log "Testing CPU performance..."

# Sysbench CPU test (if available)
if command -v sysbench &> /dev/null; then
    log "Running sysbench CPU test..."
    sysbench cpu --cpu-max-prime=20000 run | tee -a "$LOG_FILE"
else
    # Simple CPU stress test
    log "Running custom CPU test..."
    start=$(date +%s%N)
    for i in {1..10000000}; do
        result=$((i * i))
    done
    end=$(date +%s%N)
    elapsed=$(( (end - start) / 1000000 ))
    log "CPU test completed in ${elapsed}ms"
fi

log ""

# Memory Performance Test
log "========== MEMORY BENCHMARK =========="
log "Testing memory speed..."

# Read test
dd if=/dev/zero of=/data/local/tmp/test bs=1M count=500 conv=fdatasync 2>&1 | grep -i "copied" | tee -a "$LOG_FILE"

# Write test
dd if=/data/local/tmp/test of=/dev/null bs=1M 2>&1 | grep -i "copied" | tee -a "$LOG_FILE"

rm -f /data/local/tmp/test

log ""

# Storage I/O Test
log "========== STORAGE BENCHMARK =========="
log "Testing storage performance..."

# Random write
dd if=/dev/urandom of=/data/local/tmp/random bs=1M count=100 oflag=direct 2>&1 | grep -i "copied" | tee -a "$LOG_FILE"

# Random read
dd if=/data/local/tmp/random of=/dev/null bs=1M iflag=direct 2>&1 | grep -i "copied" | tee -a "$LOG_FILE"

rm -f /data/local/tmp/random

log ""

# System Information
log "========== SYSTEM STATUS =========="

# CPU frequencies
log "CPU Frequencies:"
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq; do
    if [ -f "$cpu" ]; then
        freq=$(cat "$cpu")
        cpu_name=$(echo "$cpu" | grep -oP 'cpu\d+')
        log "  $cpu_name: $((freq / 1000)) MHz"
    fi
done

# GPU frequency
if [ -f /sys/class/kgsl/kgsl-3d0/devfreq/cur_freq ]; then
    gpu_freq=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/cur_freq)
    log "GPU: $((gpu_freq / 1000000)) MHz"
fi

log ""

# Temperature readings
log "Current Temperatures:"
for zone in /sys/class/thermal/thermal_zone*/; do
    type_file="${zone}type"
    temp_file="${zone}temp"
    if [ -f "$type_file" ] && [ -f "$temp_file" ]; then
        type=$(cat "$type_file")
        temp=$(cat "$temp_file")
        if [ "$temp" -ne 0 ]; then
            log "  $type: $((temp / 1000))°C"
        fi
    fi
done

log ""
log "========================================"
log "Performance test completed!"
log "Results saved to: $LOG_FILE"
log "========================================"
