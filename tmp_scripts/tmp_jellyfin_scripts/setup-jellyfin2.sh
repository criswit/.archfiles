#!/bin/bash
set -e

echo "Setting up Jellyfin environment..."

# Create jellyfin user if it doesn't exist
if ! id "jellyfin" &>/dev/null; then
	echo "Creating jellyfin user..."
	sudo useradd -r -s /bin/false jellyfin
else
	echo "Jellyfin user already exists."
fi

# Create media directory if it doesn't exist
if [ ! -d "/media/jellyfin" ]; then
	echo "Creating /media/jellyfin directory..."
	sudo mkdir -p /media/jellyfin
	sudo chown jellyfin:jellyfin /media/jellyfin
	sudo chmod 755 /media/jellyfin
else
	echo "/media/jellyfin directory already exists."
	# Ensure proper ownership even if directory exists
	sudo chown jellyfin:jellyfin /media/jellyfin
	sudo chmod 755 /media/jellyfin
fi

# Add jellyfin to necessary groups if not already a member
for group in video audio; do
	if ! groups jellyfin | grep -q "\b$group\b"; then
		echo "Adding jellyfin to $group group..."
		sudo usermod -aG $group jellyfin
	else
		echo "Jellyfin already in $group group."
	fi
done

# Create required directories with proper permissions
for dir in "/var/lib/jellyfin" "/var/log/jellyfin" "/var/cache/jellyfin" "/etc/jellyfin"; do
	if [ ! -d "$dir" ]; then
		echo "Creating $dir..."
		sudo mkdir -p "$dir"
	fi
	sudo chown jellyfin:jellyfin "$dir"
	sudo chmod 755 "$dir"
done

# Create systemd service file if it doesn't exist
if [ ! -f "/etc/systemd/system/jellyfin.service" ]; then
	echo "Creating jellyfin systemd service..."
	cat <<'EOF' | sudo tee /etc/systemd/system/jellyfin.service >/dev/null
[Unit]
Description=Jellyfin Media Server
After=network.target

[Service]
User=jellyfin
Group=jellyfin
WorkingDirectory=/var/lib/jellyfin
ExecStart=/usr/bin/jellyfin --datadir /var/lib/jellyfin --logdir /var/log/jellyfin
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
	sudo systemctl daemon-reload
else
	echo "Jellyfin systemd service already exists."
	# Make sure service doesn't have nowebclient flag
	if grep -q "nowebclient" /etc/systemd/system/jellyfin.service; then
		echo "Removing nowebclient flag from service file..."
		sudo sed -i 's|--nowebclient||g' /etc/systemd/system/jellyfin.service
		sudo systemctl daemon-reload
	fi
fi

# Fix web client symlink if needed
if [ -d "/usr/share/jellyfin/web" ] && [ ! -d "/usr/lib/jellyfin/jellyfin-web" ]; then
	echo "Creating symlink for web client..."
	sudo mkdir -p /usr/lib/jellyfin
	sudo ln -sf /usr/share/jellyfin/web /usr/lib/jellyfin/jellyfin-web
elif [ -d "/usr/share/jellyfin-web" ] && [ ! -d "/usr/lib/jellyfin/jellyfin-web" ]; then
	echo "Creating symlink for web client..."
	sudo mkdir -p /usr/lib/jellyfin
	sudo ln -sf /usr/share/jellyfin-web /usr/lib/jellyfin/jellyfin-web
fi

echo "Jellyfin setup complete. You can now enable and start the service with:"
echo "sudo systemctl enable jellyfin"
echo "sudo systemctl start jellyfin"
echo "Once started, you can access the web interface at http://localhost:8096"
