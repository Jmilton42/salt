#!/bin/bash

CONFIG_FILE="/etc/mysql/mariadb.conf.d/50-server.cnf"

# Check if file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file $CONFIG_FILE not found."
    exit 1
fi


# Change bind-address to 0.0.0.0 (all addresses)
# Using sed to find the line starting with bind-address and replace it
sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' "$CONFIG_FILE"

if [ $? -eq 0 ]; then
    echo "Successfully updated bind-address to 0.0.0.0 in $CONFIG_FILE"
else
    echo "Error updating file."
    exit 1
fi

# Restart MariaDB to apply changes
echo "Restarting MariaDB service..."
systemctl restart mariadb

if [ $? -eq 0 ]; then
    echo "MariaDB restarted successfully."
else
    echo "Warning: Failed to restart MariaDB. Please restart manually."
fi
