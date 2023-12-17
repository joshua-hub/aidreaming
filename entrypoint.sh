#!/bin/bash

# Function to create symbolic links for files and directories
link_files_and_dirs() {
    local src_dir=$1
    local dest_dir=$2

    # Find all files in the source directory
    find "$src_dir" -type f | while read -r file; do
        # Create a symbolic link in the destination directory
        local dest_path="$dest_dir/${file#$src_dir/}"
        if [ ! -e "$dest_path" ]; then
            echo "Linking file: $file -> $dest_path"
            ln -sf "$file" "$dest_path"
        else
            echo "File already exists: $dest_path"
        fi
    done
}

# Link files and directories from /app/external_models to /app/models
link_files_and_dirs /app/external_models /app/models

echo "Symlinking complete"
# Execute the main command of the container
echo "Launching Fooocus"
exec python3 -u /app/launch.py --listen || echo "Python script exited with error code $?"