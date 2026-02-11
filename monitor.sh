#!/usr/bin/env bash

# --- Configuration ---
LOG_DIR="/home/markkhor/law"
LOG_FILE="$LOG_DIR/system_stats_${1:-$(date +%Y%m%d)}.csv"
EMAIL_SCRIPT="/home/markkhor/temperature_analysis/send_email.sh" 

# --- Initialization & Daily Report ---
mkdir -p "$LOG_DIR"

# Check if the file for the NEW day exists
if [[ ! -f "$LOG_FILE" ]]; then
    # Attempt to create the file and add the header
    echo "timestamp,cpu,memory,temperature" > "$LOG_FILE"
fi

# --- Data Gathering ---
TIMESTAMP=$(TZ="Asia/Kuala_Lumpur" date +"%Y-%m-%d %H:%M:%S")

# CPU, Memory, and Temperature gathering
CPU_IDLE=$(vmstat 1 2 | tail -1 | awk '{print $15}')
CPU_USAGE=$((100 - CPU_IDLE))
MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_FREE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
MEM_USAGE=$(( 100 * (MEM_TOTAL - MEM_FREE) / MEM_TOTAL ))

IF_TEMP="/sys/class/thermal/thermal_zone0/temp"
if [[ -f "$IF_TEMP" ]]; then
    TEMP_RAW=$(cat "$IF_TEMP")
    TEMP_C=$(echo "scale=1; $TEMP_RAW / 1000" | bc)
else
    TEMP_C="0.0"
fi

# --- Save to Log ---
echo "$TIMESTAMP,CPU: $CPU_USAGE,Memory percentage usage: $MEM_USAGE, TEMPERATURE: $TEMP_C" >> "$LOG_FILE"