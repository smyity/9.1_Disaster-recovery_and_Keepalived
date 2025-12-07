#!/bin/bash

pr_file="/etc/keepalived/weight_variable"

idle_pc=$((100-$(iostat -c 1 2 | head -n 4 | tail -n 1 | awk '{print $NF}' | sed 's/,/./' | awk -F. '{print $1}')))

echo "-$idle_pc" > "$pr_file"
