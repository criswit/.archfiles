#!/bin/bash
set -e

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
ExecStart=/usr/bin/jellyfin
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
	sudo systemctl daemon-reload
else
	echo "Jellyfin systemd service already exists."
fi

echo "Jellyfin setup complete. You can now enable and start the service with:"
echo "sudo systemctl enable jellyfin"
echo "sudo systemctl start jellyfin"
