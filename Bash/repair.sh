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

echo "[$(log_time)] Checking port 3001 rule..." | tee -a "$filename"

# Check if iptables.conf exists
if [ ! -f /etc/iptables.conf ]; then
    echo "[$(log_time)] ERROR: /etc/iptables.conf not found" | tee -a "$filename"
    exit 1
fi

# Check if port 3001 rule already exists (accessible from any IP)
EXISTING_3001=$(grep "dport 3001" /etc/iptables.conf)

if [ -z "$EXISTING_3001" ]; then
    echo "[$(log_time)] Port 3001 rule not found, adding new rule..." | tee -a "$filename"
    
    # Create a rule for port 3001 accessible from any IP
    # Assuming you want ACCEPT rule - adjust the target and chain as needed
    NEW_3001_RULE="-A INPUT -p tcp --dport 3001 -j ACCEPT"
    
    echo "[$(log_time)] New rule to add: $NEW_3001_RULE" | tee -a "$filename"
    
    # Create a temporary file for the update
    temp_file="/tmp/iptables_temp_$$"
    
    # Add the new rule before the COMMIT line (if exists) or at the end
    if grep -q "COMMIT" /etc/iptables.conf; then
        # Insert before COMMIT
        sed '/COMMIT/i\'"$NEW_3001_RULE" /etc/iptables.conf > "$temp_file"
    else
        # Add at the end
        cp /etc/iptables.conf "$temp_file"
        echo "$NEW_3001_RULE" >> "$temp_file"
    fi
    
    # Replace the original file
    sudo cp "$temp_file" /etc/iptables.conf
    rm -f "$temp_file"
    
    echo "[$(log_time)] Added rule for port 3001 accessible from any IP" | tee -a "$filename"
else
    echo "[$(log_time)] Port 3001 rule already exists: $EXISTING_3001" | tee -a "$filename"
fi

# Reload iptables
echo "[$(log_time)] Reloading iptables rules..." | tee -a "$filename"
sudo iptables-restore < /etc/iptables.conf 2>> "$filename"

if [ $? -eq 0 ]; then
    echo "[$(log_time)] iptables-restore completed successfully" | tee -a "$filename"
else
    echo "[$(log_time)] ERROR: iptables-restore failed" | tee -a "$filename"
fi

# Give iptables a moment to apply rules
sleep 2

# Verify if port 3001 rule is active
echo "[$(log_time)] Checking if port 3001 rule is active..." | tee -a "$filename"

ACTIVE_RULE_3001=$(sudo iptables -L -n | grep "3001")
if [ -n "$ACTIVE_RULE_3001" ]; then
    echo "[$(log_time)] ✓ Rule for port 3001 is now active" | tee -a "$filename"
    echo "[$(log_time)] Active rule: $ACTIVE_RULE_3001" | tee -a "$filename"
else
    echo "[$(log_time)] ✗ Port 3001 rule not found in active rules" | tee -a "$filename"
fi

echo "[$(log_time)] Script completed. Check the log file for details: $filename" | tee -a "$filename"
