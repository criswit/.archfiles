#!/bin/bash

dotfiles_dir=$(dirname "$(pwd)")/.archfiles

# set up gnome desktop environment

## default applications ##
gsettings set org.gnome.desktop.default-applications.terminal exec '/usr/bin/wezterm start --always-new-process'

## wallpaper ##

#gsettings set org.gnome.desktop.background picture-uri file:///"$HOME"/.archfiles/media/mister_squiggly.png

## dark theme ##

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

## keybindings ##

# Create a proper array format for gsettings
PATHS_ARRAY=$(jq -r '.keybindings | to_entries | map("/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom\(.key)/") | tojson' "$dotfiles_dir/config.json")

# Get all existing custom keybindings
EXISTING_PATHS=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings)
echo "Existing keybindings: $EXISTING_PATHS"

# Process each keybinding
jq -r '.keybindings | to_entries[] | [.key, .value.name, .value.command, .value.binding] | @tsv' "$dotfiles_dir/config.json" | while IFS=$'\t' read -r index name command binding; do
    echo "Index: $index"
    echo "Name: $name"
    echo "Command: $command"
    echo "Binding: $binding"
    echo "-------------------"

    # Check if this binding is assigned elsewhere
    if [ ! -z "$binding" ]; then
        # Check built-in shortcuts
        CONFLICTS=$(gsettings list-recursively | grep -i "$binding" | grep -v "custom-keybinding")
        if [ ! -z "$CONFLICTS" ]; then
            echo "Found conflicts for $binding:"
            echo "$CONFLICTS"
            echo "Removing conflicting shortcuts..."
            echo "$CONFLICTS" | while read -r conflict; do
                SCHEMA=$(echo "$conflict" | cut -d' ' -f1)
                KEY=$(echo "$conflict" | cut -d' ' -f2)
                echo "Clearing $SCHEMA $KEY"
                gsettings set "$SCHEMA" "$KEY" "[]"
            done
        fi

        # Check custom shortcuts
        if [ ! -z "$EXISTING_PATHS" ] && [ "$EXISTING_PATHS" != "[]" ]; then
            echo "$EXISTING_PATHS" | sed -e 's/\[//g' -e 's/\]//g' -e 's/, /\n/g' | sed -e "s/'//g" | while read -r path; do
                if [ ! -z "$path" ]; then
                    CURRENT_BINDING=$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$path" binding)
                    if [ "$CURRENT_BINDING" = "'$binding'" ]; then
                        echo "Found existing custom binding: $path"
                        CURRENT_NAME=$(gsettings get org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$path" name)
                        echo "Removing binding from $CURRENT_NAME"
                        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$path" binding "''"
                    fi
                fi
            done
        fi
    fi

    # Now set the new binding
    KEY_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom$index/"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$KEY_PATH" name "$name"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$KEY_PATH" command "$command"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:"$KEY_PATH" binding "$binding"
done

# Finally, set all custom keybindings at once
echo "Setting keybindings array: $PATHS_ARRAY"
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$PATHS_ARRAY"
