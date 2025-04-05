#!/bin/bash

# Check for the actual error in the logs
echo "Checking Jellyfin logs for specific errors..."
sudo journalctl -u jellyfin -n 50 --no-pager

# Check if jellyfin binary exists and is executable
echo -e "\nChecking if jellyfin binary exists and is executable:"
if [ -f /usr/bin/jellyfin ]; then
  ls -la /usr/bin/jellyfin
else
  echo "ERROR: /usr/bin/jellyfin does not exist!"
fi

# Check permissions on data directories
echo -e "\nChecking permissions on Jellyfin directories:"
for dir in /var/lib/jellyfin /media/jellyfin /etc/jellyfin /var/cache/jellyfin /var/log/jellyfin; do
  echo "Directory: $dir"
  if [ -d "$dir" ]; then
    ls -ld "$dir"
  else
    echo "  Does not exist"
  fi
done

# Try running jellyfin directly to see output
echo -e "\nTrying to run jellyfin as the jellyfin user to see error output:"
sudo -u jellyfin /usr/bin/jellyfin --version

echo -e "\nIf all checks passed but service still fails, try running with specific config:"
echo "sudo -u jellyfin /usr/bin/jellyfin --datadir /var/lib/jellyfin --logdir /var/log/jellyfin"
