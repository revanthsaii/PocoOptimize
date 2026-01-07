#!/bin/bash
# PocoOptimize - Stability Test
# Long-running test to ensure no crashes or bootloops

echo "========================================"
echo "PocoOptimize Stability Test"
echo "========================================"

if [ ! -f /system/build.prop ]; then
    echo "ERROR: Must run on Android device"
    exit 1
fi

LOG_FILE="/sdcard/pocooptimize_stability_$(date '+%Y%m%d_%H%M%S').log"
TEST_DURATION=3600  # 1 hour in seconds
CHECK_INTERVAL=60   # Check every 60 seconds

log() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting stability test..."
log "Duration: $((TEST_DURATION / 60)) minutes"
log "Device: $(getprop ro.product.model)"
log ""

START_TIME=$(date +%s)
CURRENT_TIME=$START_TIME
ISSUES_FOUND=0

while [ $((CURRENT_TIME - START_TIME)) -lt $TEST_DURATION ]; do
    ELAPSED=$((CURRENT_TIME - START_TIME))
    REMAINING=$((TEST_DURATION - ELAPSED))
    
    log "Test running... Elapsed: $((ELAPSED / 60))m | Remaining: $((REMAINING / 60))m"
    
    # Check for bootloop indicators
    BOOT_COUNT=$(getprop sys.boot_completed)
    if [ "$BOOT_COUNT" != "1" ]; then
        log "WARNING: Boot completion flag not set!"
        ((ISSUES_FOUND++))
    fi
    
    # Check system responsiveness
    if ! dumpsys window 2>&1 | grep -q "mCurrentFocus"; then
        log "WARNING: System may be unresponsive"
        ((ISSUES_FOUND++))
    fi
    
    # Check thermal status
    for zone in /sys/class/thermal/thermal_zone*/temp; do
        if [ -f "$zone" ]; then
            temp=$(cat "$zone" 2>/dev/null)
            if [ -n "$temp" ] && [ "$temp" -gt 95000 ]; then
                zone_name=$(dirname "$zone")
                log "WARNING: High temperature detected in $zone_name: $((temp / 1000))°C"
                ((ISSUES_FOUND++))
            fi
        fi
    done
    
    # Check for kernel panics
    if dmesg | tail -100 | grep -qi "panic\|oops\|bug:"; then
        log "ERROR: Kernel panic/oops detected in dmesg!"
        ((ISSUES_FOUND++))
    fi
    
    # Check memory pressure
    MEMFREE=$(free | grep Mem | awk '{print $4}')
    MEMTOTAL=$(free | grep Mem | awk '{print $2}')
    MEMPERCENT=$((MEMFREE * 100 / MEMTOTAL))
    
    if [ "$MEMPERCENT" -lt 5 ]; then
        log "WARNING: Low memory: ${MEMPERCENT}% free"
        ((ISSUES_FOUND++))
    fi
    
    # Sleep and update time
    sleep $CHECK_INTERVAL
    CURRENT_TIME=$(date +%s)
done

log ""
log "========================================"
log "Stability Test Complete"
log "========================================"
log "Total duration: $((TEST_DURATION / 60)) minutes"
log "Issues found: $ISSUES_FOUND"

if [ $ISSUES_FOUND -eq 0 ]; then
    log "✓ PASSED: No stability issues detected"
    exit 0
else
    log "⚠ WARNING: $ISSUES_FOUND potential issues detected"
    log "Review log file: $LOG_FILE"
    exit 1
fi
