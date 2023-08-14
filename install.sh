#!/bin/bash

linux_username=$(whoami)
desktop_file="$HOME/.local/share/applications/linuxmultrbx.desktop"

# Dep check
if ! command -v wine64 &>/dev/null; then
    echo "Looks like you don't have wine installed."
    echo "Please install it with your distribution's package manager."
    exit 1
fi

if ! command -v curl &>/dev/null; then
    echo "Looks like you don't have curl installed."
    echo "Please install it with your distribution's package manager."
    exit 1
fi

if ! command -v kgx &>/dev/null; then
    echo "Looks like you don't have GNOME Console installed."
    echo "Please install it with your distribution's package manager."
    exit 1
fi

clear
echo "Welcome to the MULTRBX Linux installer!"

# Prompt
read -rp "Do you want to install MULTRBX? (y/N): " install_choice

if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    clear
    echo "Installing MULTRBX..."
    echo "Just a quick note: the installer might show an error. Ignore it."
    sleep 5
    
    # Installer: Wine
    mkdir -p ~/.multrbx/
    cd ~/.multrbx/
    curl https://mulrbx.com/MULTRBXInstaller.exe -o installer.exe
    WINEDEBUG=-all wine64 installer.exe
    # Wine install should be done by now
    
    clear
    echo "The install should've now completed and installed MULTRBX in Wine."
    echo "Now installing URI..."
    
    # Installer: URI
    # Create desktop file if it doesn't exist
    if [ ! -f "$desktop_file" ]; then
        echo "[Desktop Entry]
Name=MULTRBX
Exec=kgx --wait -e $HOME/.multrbx/middleman.sh %u
Type=Application
MimeType=x-scheme-handler/multrbx-launch;
NoDisplay=true" > "$desktop_file"

        sed -i "s|/home/$linux_username/|/home/$linux_username/|g" "$desktop_file"
        xdg-mime default linuxmultrbx.desktop x-scheme-handler/multrbx-launch;
        cd ~/.multrbx/
    else
        echo "Desktop file already exists. Skipping creation."
    fi

    # Rest of the script...
    middleman_script="$HOME/.multrbx/middleman.sh"
    echo "#!/usr/bin/env bash

if [[ \"\$1\" == \"multrbx-launch:\"* ]]; then
    ref=\${1#multrbx-launch://}
    echo \"[MIDDLEMAN] Scooped authentication key, passing this onto the launcher...\"
    
    # get just the good stuff
    ref=\${ref#multrbx-launch:}
    
    WINEDEBUG=-all wine64 ~/.wine/drive_c/MULTRBX/MultRBXLauncher.exe \"\$ref\"
else
    echo \"[MIDDLEMAN] URI invalid!\"
fi" > "$middleman_script"

    # Make the script executable
    chmod +x "$middleman_script"
    clear
    echo "MULTRBX installed successfully! Verify this by attempting to join a game."
else
    clear
    echo "Exiting"
    exit 1
fi

echo "Thanks for using the MULTRBX Linux installer!"
