#!/bin/bash
# PocoOptimize - Battery Drain Test
# Measures battery consumption over time

echo "========================================"
echo "PocoOptimize Battery Drain Test"
echo "========================================"

LOG_FILE="/sdcard/pocooptimize_battery_$(date '+%Y%m%d_%H%M%S').log"
TEST_DURATION=3600  # 1 hour
SAMPLE_INTERVAL=300  # Sample every 5 minutes

log() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

get_battery_level() {
    cat /sys/class/power_supply/battery/capacity 2>/dev/null || echo "0"
}

get_battery_temp() {
    temp=$(cat /sys/class/power_supply/battery/temp 2>/dev/null || echo "0")
    echo $((temp / 10))
}

get_battery_current() {
    # Current in microamps (negative = discharging)
    cat /sys/class/power_supply/battery/current_now 2>/dev/null || echo "0"
}

log "Starting battery drain test..."
log "Duration: $((TEST_DURATION / 60)) minutes"
log "Sample interval: $((SAMPLE_INTERVAL / 60)) minutes"
log ""

# Check if charging
status=$(cat /sys/class/power_supply/battery/status 2>/dev/null)
if [ "$status" = "Charging" ]; then
    log "WARNING: Device is charging. Please disconnect charger for accurate results."
    log "Waiting 30 seconds for you to disconnect..."
    sleep 30
    status=$(cat /sys/class/power_supply/battery/status 2>/dev/null)
    if [ "$status" = "Charging" ]; then
        log "ERROR: Device still charging. Test aborted."
        exit 1
    fi
fi

log "Device status: $status"
log ""

# Record initial state
INITIAL_LEVEL=$(get_battery_level)
INITIAL_TIME=$(date +%s)

log "Initial battery level: ${INITIAL_LEVEL}%"
log "Initial temperature: $(get_battery_temp)°C"
log ""

log "Timestamp,Battery%,Temp(°C),Current(mA),Drain(%/h)"
log "========================================"

SAMPLES=0
START_TIME=$(date +%s)

while [ $(($(date +%s) - START_TIME)) -lt $TEST_DURATION ]; do
    CURRENT_LEVEL=$(get_battery_level)
    CURRENT_TEMP=$(get_battery_temp)
    CURRENT_MA=$(get_battery_current)
    CURRENT_MA=$((CURRENT_MA / 1000))  # Convert to milliamps
    
    # Calculate drain rate
    ELAPSED=$(( $(date +%s) - INITIAL_TIME ))
    if [ $ELAPSED -gt 0 ]; then
        DRAIN=$((INITIAL_LEVEL - CURRENT_LEVEL))
        DRAIN_PER_HOUR=$(awk "BEGIN {printf \"%.2f\", ($DRAIN * 3600.0 / $ELAPSED)}")
    else
        DRAIN_PER_HOUR="0.00"
    fi
    
    TIMESTAMP=$(date '+%H:%M:%S')
    log "$TIMESTAMP,$CURRENT_LEVEL,$CURRENT_TEMP,$CURRENT_MA,$DRAIN_PER_HOUR"
    
    ((SAMPLES++))
    sleep $SAMPLE_INTERVAL
done

# Final calculations
FINAL_LEVEL=$(get_battery_level)
FINAL_TIME=$(date +%s)
TOTAL_ELAPSED=$((FINAL_TIME - INITIAL_TIME))
TOTAL_DRAIN=$((INITIAL_LEVEL - FINAL_LEVEL))
AVG_DRAIN_PER_HOUR=$(awk "BEGIN {printf \"%.2f\", ($TOTAL_DRAIN * 3600.0 / $TOTAL_ELAPSED)}")

log ""
log "========================================"
log "Battery Drain Test Results"
log "========================================"
log "Test duration: $((TOTAL_ELAPSED / 60)) minutes"
log "Initial level: ${INITIAL_LEVEL}%"
log "Final level: ${FINAL_LEVEL}%"
log "Total drain: ${TOTAL_DRAIN}%"
log "Average drain rate: ${AVG_DRAIN_PER_HOUR}%/hour"
log ""

# Estimate full battery life
if [ $(echo "$AVG_DRAIN_PER_HOUR > 0" | bc -l) -eq 1 ]; then
    ESTIMATED_HOURS=$(awk "BEGIN {printf \"%.1f\", (100.0 / $AVG_DRAIN_PER_HOUR)}")
    log "Estimated battery life (100% to 0%): ${ESTIMATED_HOURS} hours"
fi

log ""
log "Results saved to: $LOG_FILE"
log "========================================"
