#!/bin/bash

# Add the mongodb 3.2.20 repository to the source list
wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add -
echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

# Update the source list with new repository
sudo apt-get update

# Install specific version of mongodb
sudo apt-get install -y mongodb-org=3.2.20

# Copy the new config file
sudo cp ../../config_files/mongod.conf /etc/

# Start mongodb service with the new config file and on each system boot
sudo systemctl enable mongod.service --now
