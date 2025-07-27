#!/bin/bash

# Create logs directory if it doesn't exist
mkdir -p ./logs

# Create log file with current date
date=$(date +%m-%d-%y)
filename="./logs/$date.txt"

# Timestamp function
log_time() {
  date +%H:%M:%S
}

echo "[$(log_time)] Checking and updating iptables rule..." | tee -a "$filename"

# Find rule with port 3128 and IP subnet
LINE=$(grep "tcp" /etc/iptables.conf | grep "3128" | grep "10.42.69.0/24" | awk -F " -j" '{print $1}')
RESULT="$LINE,3001"

# Check if port 3001 is already there
EXISTING=$(grep "tcp" /etc/iptables.conf | grep "3128" | grep "10.42.69.0/24" | grep "3001")

if [ "$EXISTING" == "" ]; then
    echo "[$(log_time)] Port 3001 not open, updating rule..." | tee -a "$filename"
    sudo sed -i "s|$LINE|$RESULT|g" /etc/iptables.conf 2>> "$filename"
else
    echo "[$(log_time)] Port 3001 already included." | tee -a "$filename"
fi

# Reload iptables
echo "[$(log_time)] Reloading iptables rules..." | tee -a "$filename"
sudo iptables-restore < /etc/iptables.conf 2>> "$filename"

# Verify if new rule is active
ACTIVE_RULE=$(sudo iptables -S | grep "10.42.69.0/24" | grep "3001")

if [ "$ACTIVE_RULE" != "" ]; then
    echo "[$(log_time)]Rule with port 3001 is now active" | tee -a "$filename"
else
    echo "[$(log_time)] ❌ Port 3001 rule not active. Please check manually." | tee -a "$filename"
fi
