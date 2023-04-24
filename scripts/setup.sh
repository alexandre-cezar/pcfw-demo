#!/bin/bash

# Set the paths to the scripts
file1_path="/home/ubuntu/prepare.sh"
file2_path="/home/ubuntu/port_scan.sh"
file3_path="/home/ubuntu/suspicious_ip.sh"
file4_path="/home/ubuntu/log4j.sh"

# Makes the scripts executable
sudo chmod +x "$file1_path"
sudo chmod +x "$file2_path"
sudo chmod +x "$file3_path"
sudo chmod +x "$file4_path"

#Installs the required libraries and dependencies
sudo "$file1_path"

# Define the cron job commands
cron_command1="$file2_path"
cron_command2="$file3_path"

# Define the cron schedules
cron_schedule1="5 * * * *"
cron_schedule2="15 * * * *"

# Write the cron job commands and schedules to the crontab file
(crontab -l 2>/dev/null; echo "$cron_schedule1 $cron_command1") | crontab -
(crontab -l 2>/dev/null; echo "$cron_schedule2 $cron_command2") | crontab -

# Starts the Log4j app
sudo "$file4_path"