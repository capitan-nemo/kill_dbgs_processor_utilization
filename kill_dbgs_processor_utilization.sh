#!/bin/bash

# Function to get CPU statistics
get_cpu_stats() {
    # Read the first line of /proc/stat which contains aggregate CPU stats
    read -r _ user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat

    # Calculate total and active CPU time
    local total_time=$((user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice))
    local active_time=$((user + nice + system + irq + softirq + steal + guest + guest_nice))

    echo "$active_time $total_time"
}

# Get initial CPU stats
read -r prev_active prev_total <<< "$(get_cpu_stats)"

# Wait for a short interval to capture a meaningful change
sleep 1

# Get current CPU stats
read -r current_active current_total <<< "$(get_cpu_stats)"

# Calculate the difference in active and total time
active_diff=$((current_active - prev_active))
total_diff=$((current_total - prev_total))

# Calculate CPU utilization percentage
if (( total_diff > 0 )); then
    cpu_util=$(awk "BEGIN {printf \"%d\", ($active_diff * 100.0) / $total_diff}")
else
    cpu_util=0.00
fi

if (( cpu_util > 80 )); then
  echo "Current CPU Utilization: $cpu_util% I will kill dbgs"
  pkill --signal SIGKILL dbgs
fi

