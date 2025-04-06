#!/bin/bash
set -e

echo "Fixing Jellyfin web client issue..."

# Option 1: Install the missing web client package if available in repositories
if pacman -Ss jellyfin-web &>/dev/null; then
	echo "Installing jellyfin-web package..."
	sudo pacman -S jellyfin-web --noconfirm
elif yay -Ss jellyfin-web &>/dev/null; then
	echo "Installing jellyfin-web package from AUR..."
	yay -S jellyfin-web --noconfirm --answerdiff=n --answerclean=n --answeredit=n
else
	# Option 2: Modify service to run without web client
	echo "Web client package not found. Modifying service to run without web client..."
	sudo sed -i 's|ExecStart=/usr/bin/jellyfin --datadir /var/lib/jellyfin --logdir /var/log/jellyfin|ExecStart=/usr/bin/jellyfin --datadir /var/lib/jellyfin --logdir /var/log/jellyfin --nowebclient|' /etc/systemd/system/jellyfin.service
fi

# Create a basic configuration file if it doesn't exist
if [ ! -f "/etc/jellyfin/system.xml" ]; then
	echo "Creating basic configuration..."
	cat <<'EOF' | sudo tee /etc/jellyfin/system.xml >/dev/null
<?xml version="1.0" encoding="utf-8"?>
<ServerConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <HostWebClient>false</HostWebClient>
  <EnableUPnP>true</EnableUPnP>
  <PublicPort>8096</PublicPort>
  <HttpServerPortNumber>8096</HttpServerPortNumber>
  <HttpsPortNumber>8920</HttpsPortNumber>
  <EnableHttps>false</EnableHttps>
  <IsStartupWizardCompleted>false</IsStartupWizardCompleted>
</ServerConfiguration>
EOF
	sudo chown jellyfin:jellyfin /etc/jellyfin/system.xml
fi

echo "Reloading systemd and restarting Jellyfin..."
sudo systemctl daemon-reload
sudo systemctl restart jellyfin

echo "Waiting for Jellyfin to start..."
sleep 5
sudo systemctl status jellyfin

echo "If Jellyfin is running, you can access it at http://localhost:8096"
echo "Once it's running, you can complete setup through the web interface"
