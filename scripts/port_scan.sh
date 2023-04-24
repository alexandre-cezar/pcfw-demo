#!/bin/bash

private_subnet="172.20.2.0/24"

# Executes nmap SYN scan against the private subnet
echo "Starting SYN scan..."
sudo nmap -sS $private_subnet

# Execute nmap UDP scan against the private subnet
echo "Starting UDP scan..."
sudo nmap -sU $private_subnet