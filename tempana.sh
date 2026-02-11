#!/bin/bash

# --- 1. Configuration ---
THRESHOLD=35
EMAIL_SCRIPT="/home/markkhor/temperature_analysis/send_email.sh"

# --- 2. Get Live Data ---
# Read the sensor
RAW_TEMP=$(cat /sys/class/thermal/thermal_zone0ca/temp)

# Math: We calculate with decimals for the display, but use whole numbers for the 'if' check
# This creates a display like 37.5
DISPLAY_TEMP=$(echo "scale=1; $RAW_TEMP / 1000" | bc -l)
# This creates a whole number for the bash comparison (e.g., 37)
CURRENT_TEMP=$((RAW_TEMP / 1000))
NOW = $(date +"%Y-%m-%d %H:%M:%S")


# --- 4. Logic Check ---
if [ "$CURRENT_TEMP" -ge "$THRESHOLD" ]; then
    echo "STATUS: [CRITICAL] - Sending Email Alert..."
    
    # Create the message for the email
    MESSAGE="CRITICAL ALERT: High temperature of ${DISPLAY_TEMP}°C detected at $(date +%H:%M:%S)"
    
    # Run the email script
    if [ -f "$EMAIL_SCRIPT" ]; then
        bash "$EMAIL_SCRIPT" "$MESSAGE" 2>/dev/null
        echo "SUCCESS: Email sent."
    else
        echo "ERROR: Email script not found at $EMAIL_SCRIPT"
    fi
else
    echo "STATUS: [NORMAL] - No action required"
fi