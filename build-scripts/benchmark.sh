#!/bin/bash
# PocoOptimize - Benchmark Runner
# Automated benchmark for performance testing

echo "========================================="
echo "PocoOptimize Benchmark Runner"
echo "========================================="

if [ ! -f /system/build.prop ]; then
    echo "ERROR: Must run on Android device"
    exit 1
fi

# Output file
OUTPUT_FILE="/sdcard/pocooptimize_benchmark_$(date '+%Y%m%d_%H%M%S').txt"

log_result() {
    echo "$1" | tee -a "$OUTPUT_FILE"
}

log_result "Device: $(getprop ro.product.model)"
log_result "Date: $(date)"
log_result ""
log_result "========================================="

# CPU Information
log_result "CPU INFORMATION"
log_result "========================================="
for cpu in /sys/devices/system/cpu/cpu*/cpufreq; do
    if [ -d "$cpu" ]; then
        cpu_num=$(basename $(dirname "$cpu"))
        cur_freq=$(cat "$cpu/scaling_cur_freq" 2>/dev/null || echo "N/A")
        max_freq=$(cat "$cpu/scaling_max_freq" 2>/dev/null || echo "N/A")
        governor=$(cat "$cpu/scaling_governor" 2>/dev/null || echo "N/A")
        
        cur_mhz=$((cur_freq / 1000))
        max_mhz=$((max_freq / 1000))
        
        log_result "$cpu_num: ${cur_mhz}MHz / ${max_mhz}MHz ($governor)"
    fi
done

log_result ""

# GPU Information
log_result "GPU INFORMATION"
log_result "========================================="
if [ -d /sys/class/kgsl/kgsl-3d0 ]; then
    gpu_freq=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/cur_freq 2>/dev/null || echo "N/A")
    gpu_max=$(cat /sys/class/kgsl/kgsl-3d0/max_gpuclk 2>/dev/null || echo "N/A")
    gpu_gov=$(cat /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null || echo "N/A")
    
    gpu_mhz=$((gpu_freq / 1000000))
    gpu_max_mhz=$((gpu_max / 1000000))
    
    log_result "Current: ${gpu_mhz}MHz"
    log_result "Maximum: ${gpu_max_mhz}MHz"
    log_result "Governor: $gpu_gov"
else
    log_result "GPU information not available"
fi

log_result ""

# Memory Information
log_result "MEMORY INFORMATION"
log_result "========================================="
log_result "$(free -h | grep -E 'Mem|Swap')"

if [ -f /proc/sys/vm/swappiness ]; then
    swappiness=$(cat /proc/sys/vm/swappiness)
    log_result "Swappiness: $swappiness"
fi

log_result ""

# Thermal Information
log_result "THERMAL INFORMATION"
log_result "========================================="
for zone in /sys/class/thermal/thermal_zone*/; do
    if [ -d "$zone" ]; then
        zone_type=$(cat "${zone}type" 2>/dev/null)
        zone_temp=$(cat "${zone}temp" 2>/dev/null)
        
        if [ -n "$zone_temp" ] && [ "$zone_temp" != "0" ]; then
            zone_temp_c=$((zone_temp / 1000))
            log_result "$zone_type: ${zone_temp_c}°C"
        fi
    fi
done

log_result ""

# Battery Information
log_result "BATTERY INFORMATION"
log_result "========================================="
if [ -d /sys/class/power_supply/battery ]; then
    batt_cap=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null || echo "N/A")
    batt_temp=$(cat /sys/class/power_supply/battery/temp 2>/dev/null || echo "N/A")
    batt_status=$(cat /sys/class/power_supply/battery/status 2>/dev/null || echo "N/A")
    
    batt_temp_c=$((batt_temp / 10))
    
    log_result "Capacity: ${batt_cap}%"
    log_result "Temperature: ${batt_temp_c}°C"
    log_result "Status: $batt_status"
fi

log_result ""

# Display Information
log_result "DISPLAY INFORMATION"
log_result "========================================="
refresh_rate=$(settings get system peak_refresh_rate 2>/dev/null || echo "N/A")
log_result "Peak refresh rate: ${refresh_rate}Hz"

log_result ""

# Performance Tests
log_result "PERFORMANCE TESTS"
log_result "========================================="

# CPU stress test (simple calculation)
log_result "Running CPU stress test..."
start_time=$(date +%s%N)
result=0
for i in {1..1000000}; do
    result=$((result + i))
done
end_time=$(date +%s%N)
elapsed=$(( (end_time - start_time) / 1000000 ))
log_result "CPU calculation time: ${elapsed}ms"

# Memory speed test
log_result "Running memory test..."
dd if=/dev/zero of=/data/local/tmp/test_file bs=1M count=100 oflag=direct 2>&1 | grep -i "copied" | tee -a "$OUTPUT_FILE"
rm -f /data/local/tmp/test_file

log_result ""
log_result "========================================="
log_result "Benchmark completed!"
log_result "Results saved to: $OUTPUT_FILE"
log_result "========================================="

echo ""
echo "You can view results with: cat $OUTPUT_FILE"
