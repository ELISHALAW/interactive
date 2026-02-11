#!/bin/bash

LOG_DIR="$HOME/temp_logs"
DATE=${1:-$(date -d "yesterday" +%Y%m%d 2>/dev/null || date -v-1d +%Y%m%d 2>/dev/null)}
LOG_FILE="$LOG_DIR/temperature_${DATE}.csv"

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file not found: $LOG_FILE"
    echo ""
    echo "Available logs:"
    ls -1 "$LOG_DIR"/temperature_*.csv 2>/dev/null || echo "  No logs found"
    exit 1
fi

echo "========================================"
echo "Temperature Analysis for: $DATE"
echo "========================================"
echo ""

awk -F',' '
NR==1 {next}
{
    if ($2 != "" && $2 != "NA") {
        temp = $2
        time = $1
        
        if (max_pkg == "" || temp > max_pkg) {
            max_pkg = temp
            max_pkg_time = time
        }
        if (min_pkg == "" || temp < min_pkg) {
            min_pkg = temp
            min_pkg_time = time
        }
        sum_pkg += temp
        count_pkg++
        
        if ($3 != "") {
            if (max_c0 == "" || $3 > max_c0) {
                max_c0 = $3
                max_c0_time = time
            }
        }
        
        if ($4 != "") {
            if (max_c1 == "" || $4 > max_c1) {
                max_c1 = $4
                max_c1_time = time
            }
        }
        
        if ($5 != "") {
            if (max_c2 == "" || $5 > max_c2) {
                max_c2 = $5
                max_c2_time = time
            }
        }
        
        if ($6 != "") {
            if (max_c3 == "" || $6 > max_c3) {
                max_c3 = $6
                max_c3_time = time
            }
        }
        
        hour = substr(time, 12, 2)
        hour_sum[hour] += temp
        hour_count[hour]++
    }
}
END {
    if (count_pkg > 0) {
        print "PACKAGE TEMPERATURE:"
        printf "   Highest: %.1f degrees C at %s\n", max_pkg, max_pkg_time
        printf "   Lowest:  %.1f degrees C at %s\n", min_pkg, min_pkg_time
        printf "   Average: %.1f degrees C\n", sum_pkg/count_pkg
        print ""
        
        print "CORE TEMPERATURES (Highest):"
        printf "   Core 0: %.1f degrees C at %s\n", max_c0, max_c0_time
        printf "   Core 1: %.1f degrees C at %s\n", max_c1, max_c1_time
        printf "   Core 2: %.1f degrees C at %s\n", max_c2, max_c2_time
        printf "   Core 3: %.1f degrees C at %s\n", max_c3, max_c3_time
        print ""
        
        print "HOTTEST HOURS OF THE DAY:"
        n = 0
        for (h in hour_sum) {
            avg = hour_sum[h] / hour_count[h]j
            hours[n] = h
            avgs[n] = avg
            n++
        }
        
        for (i = 0; i < n-1; i++) {
            for (j = 0; j < n-i-1; j++) {
                if (avgs[j] < avgs[j+1]) {
                    temp_avg = avgs[j]
                    avgs[j] = avgs[j+1]
                    avgs[j+1] = temp_avg
                    temp_hour = hours[j]
                    hours[j] = hours[j+1]
                    hours[j+1] = temp_hour
                }
            }
        }
        
        limit = (n < 5) ? n : 5
        for (i = 0; i < limit; i++) {
            printf "   #%d: %s:00 - Average: %.1f degrees C (%d readings)\n", i+1, hours[i], avgs[i], hour_count[hours[i]]
        }
        print ""
        
        print "STATISTICS:"
        printf "   Total records: %d\n", count_pkg
        printf "   Temperature range: %.1f degrees C\n", max_pkg - min_pkg
        printf "   Hours tracked: %d\n", n
        
    } else {
        print "No valid temperature data found."
    }
}
' "$LOG_FILE"

echo "========================================"
ENDOFFILE
