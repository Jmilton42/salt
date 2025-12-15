#!/bin/bash
# Script to add local users for competition
# Password: machine-PLACE-4!

# Array of usernames
USERS=("Gabe" "Byrge" "Jmac" "Nate" "Foister" "Behn" "Joey" "Carter" "Chandler" "Trey" "Grant" "Grayson")

# Users who should have sudo permissions (first 5)
SUDO_USERS=("Gabe" "Byrge" "Jmac" "Nate" "Foister")

# Password for all users
PASSWORD="machine-PLACE-4!"

# Loop through users and create them
for USER in "${USERS[@]}"; do
    # Check if user already exists
    if id "$USER" &>/dev/null; then
        echo "User $USER already exists, updating password..."
        echo "$USER:$PASSWORD" | chpasswd
    else
        echo "Creating user $USER..."
        # Create user with home directory
        useradd -m -s /bin/bash "$USER"
        
        # Set password
        echo "$USER:$PASSWORD" | chpasswd
        
        # Force password change on first login (optional, comment out if not needed)
        # chage -d 0 "$USER"
        
        echo "User $USER created successfully"
    fi
    
    # Add to sudo group if in SUDO_USERS array
    if [[ " ${SUDO_USERS[@]} " =~ " ${USER} " ]]; then
        echo "Adding $USER to sudo group..."
        usermod -aG sudo "$USER" 2>/dev/null || usermod -aG wheel "$USER" 2>/dev/null
        echo "$USER granted sudo permissions"
    fi
done

echo "All users processed successfully!"
