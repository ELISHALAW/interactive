#!/usr/bin/env bash

# --- Configuration ---
LOG_DIR="/home/markkhor/law"
DATE_STAMP=$(date +%Y%m%d)
LOG_FILE="$LOG_DIR/system_stats_${DATE_STAMP}.csv"
HISTORY_FILE="/home/markkhor/temperature_analysis/highest_temps_history.log"

# --- 1. Safety Check ---
# Ensure the directory exists
mkdir -p "$LOG_DIR"

# Check if the log file for today exists before trying to read it
if [[ ! -f "$LOG_FILE" ]]; then
    echo "Error: Log file $LOG_FILE not found. Nothing to analyze."
    exit 1
fi

# --- 2. Time Check ---
# Get current time in HH:MM format
CURRENT_TIME=$(date +"%H:%M")

# --- 3. The Logic (Set for 10:30) ---
if [[ "$CURRENT_TIME" == "10:30" ]]; then
    
    # Use awk to find the max temperature in the file
    # -F',' sets the comma as the field separator
    DAILY_HIGH=$(awk -F',' '
    NR>1 {
        # Column 4 looks like " TEMPERATURE: 35.0"
        # We split it by the colon to get the number
        split($4, a, ": "); 
        temp = a[2];
        
        # If this temp is higher than our current max, or if it is the first row
        if (temp > max_t || NR==2) { 
            max_t = temp; 
            max_time = $1; 
        }
    }
    END {
        # Only output if we actually found a temperature
        if (max_t != "") 
            printf "%s - MAX TEMP (at 10:30): %.1f°C\n", max_time, max_t
    }' "$LOG_FILE")

    # --- 4. Record to History ---
    if [[ -n "$DAILY_HIGH" ]]; then
        echo "$DAILY_HIGH" >> "$HISTORY_FILE"
        echo "Successfully recorded highest morning temperature to $HISTORY_FILE"
    else
        echo "No data found in log file."
    fi

else
    echo "Current time is $CURRENT_TIME. Script is set to record at 10:30."
fi