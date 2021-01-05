#!/bin/bash

# Update the sources list
sudo apt-get update -y

# Upgrade any packages that are outdated
sudo apt-get upgrade -y

# Install GIT
sudo apt-get install git -y

# Install NodeJS Dependencies
sudo apt-get install software-properties-common -y

# Install NodeJS 12 from official repository
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install nodejs -y

# Add the DB IP address to bash
echo "export DB_HOST=120.50.10.137" >> ~/.bashrc

# Reload bash so the environment variable is loaded
source ~/.bashrc

# Install pm2
sudo npm install pm2 -g

# Install nginx
sudo apt-get install nginx -y

# Copy the new configuration file
sudo cp ../../config_files/nginx.conf /etc/nginx/

# Restart nginx to update the config file
sudo service nginx restart

# Navigate to the app folder
cd ../.../app/

# Ensure dependancies are installed
npm install

# Run the app.js
pm2 start app.js --update-env
