#!/bin/bash

# Install Java
sudo apt-get update
sudo apt-get install -y openjdk-11-jdk

# Install Maven
sudo apt-get install -y maven

# Clone the vulnerable app repository
git clone https://github.com/alexandre-cezar/log4shell-vulnerable-app.git

# Install Nmap
sudo apt-get update
sudo apt-get install -y nmap

# Install curl
sudo apt-get update
sudo apt-get install -y curl