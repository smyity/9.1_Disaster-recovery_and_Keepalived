#!/bin/bash

pr_file="/etc/keepalived/weight_variable"

current_load=$(echo "$(echo "$(cat /proc/loadavg | awk '{print $1}') * 100" | bc -l | awk -F. '{print $1}')")

if [[ $current_load -gt 80 ]]; then
    echo "-20" > "$pr_file"
else
    echo "0" > "$pr_file"
fi
