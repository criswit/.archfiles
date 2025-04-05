#!/bin/bash
set -e

# Configuration
MEDIA_DIR="/media/jellyfin"
JELLYFIN_USER="jellyfin"
JELLYFIN_GROUP="jellyfin"
JELLYFIN_CONFIG_DIR="/etc/jellyfin"
CONTENT_TYPE="mixed"  # Options: movies, tvshows, music, books, photos, homevideos, mixed

echo "Setting up Jellyfin media library automatically..."

# Ensure media directory exists with proper permissions
if [ ! -d "$MEDIA_DIR" ]; then
    echo "Creating media directory..."
    sudo mkdir -p "$MEDIA_DIR"
fi

echo "Setting permissions..."
sudo chown -R $JELLYFIN_USER:$JELLYFIN_GROUP "$MEDIA_DIR"
sudo chmod -R 755 "$MEDIA_DIR"

# Update Jellyfin configuration to include the media library
echo "Configuring Jellyfin to recognize the media library..."

# Create the config directory if it doesn't exist
sudo mkdir -p "$JELLYFIN_CONFIG_DIR"

# Generate a unique library ID
LIBRARY_ID=$(cat /proc/sys/kernel/random/uuid)

# Create or update library configuration
sudo tee "$JELLYFIN_CONFIG_DIR/library.xml" > /dev/null << EOF
<?xml version="1.0" encoding="utf-8"?>
<ServerConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <Libraries>
    <MediaLibrary>
      <Name>Media</Name>
      <Id>${LIBRARY_ID}</Id>
      <Paths>
        <Path>${MEDIA_DIR}</Path>
      </Paths>
      <LibraryOptions>
        <EnablePhotos>true</EnablePhotos>
        <EnableRealtimeMonitor>true</EnableRealtimeMonitor>
        <EnableChapterImageExtraction>false</EnableChapterImageExtraction>
        <ExtractChapterImagesDuringLibraryScan>false</ExtractChapterImagesDuringLibraryScan>
        <PathInfos>
          <PathInfo>
            <Path>${MEDIA_DIR}</Path>
            <NetworkPath></NetworkPath>
            <Type>${CONTENT_TYPE}</Type>
          </PathInfo>
        </PathInfos>
        <SaveLocalMetadata>true</SaveLocalMetadata>
        <EnableInternetProviders>true</EnableInternetProviders>
        <EnableAutomaticSeriesGrouping>true</EnableAutomaticSeriesGrouping>
        <EnableEmbeddedTitles>false</EnableEmbeddedTitles>
        <EnableEmbeddedEpisodeInfos>false</EnableEmbeddedEpisodeInfos>
        <AllowEmbeddedSubtitles>AllowAll</AllowEmbeddedSubtitles>
      </LibraryOptions>
    </MediaLibrary>
  </Libraries>
</ServerConfiguration>
EOF

# Fix permissions on config files
sudo chown -R $JELLYFIN_USER:$JELLYFIN_GROUP "$JELLYFIN_CONFIG_DIR"
sudo chmod -R 644 "$JELLYFIN_CONFIG_DIR"/*.xml
sudo find "$JELLYFIN_CONFIG_DIR" -type d -exec chmod 755 {} \;

# Restart Jellyfin to apply changes
echo "Restarting Jellyfin service..."
sudo systemctl restart jellyfin

echo "Media library setup complete! Your media in $MEDIA_DIR should now be available in Jellyfin."
echo "It may take some time for Jellyfin to scan and catalog all media files."
echo "Access Jellyfin at http://localhost:8096"
