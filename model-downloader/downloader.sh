#!/bin/bash


# Initialize variables for argument values
model_yaml=""
root_path="models"


# Function to download a model file and place it in the appropriate subfolder
## TODO ADD Name Override function

download_model() {
    local url=$1
    local folder=$2
    local file_name="${3:-$(basename "$url")}"

    # Check if the file already exists
    if [ -f "$root_path/$folder/$file_name" ]; then
        echo "File $file_name already exists in $root_path/$folder."
    else
        echo "Downloading $file_name..."
        mkdir -p "$root_path/$folder"
        wget -q --show-progress "$url" -O "$root_path/$folder/$file_name"
    fi
}

# Function to read YAML file and download models
download_models_from_yaml() {
    local yaml_file=$1

    # Get the number of model entries
    local num_entries=$(yq e '.model_files | length' "$yaml_file")
    # Read ignore folders from the YAML file
    local ignore_folders=($(yq e '.ignore_folders[]' "$yaml_file"))
    # Read ignore config_name from the YAML file
    local ignore_config_names=($(yq e '.ignore_config_name[]' "$yaml_file"))
    echo "Number of Files: $num_entries"

    # Download each model, skipping ignored folders
    for ((i = 0; i < num_entries; i++)); do
        local url=$(yq e ".model_files[$i].url" "$yaml_file")
        local folder=$(yq e ".model_files[$i].folder" "$yaml_file")
        local config_name=$(yq e ".model_files[$i].config_name" "$yaml_file")
        local file_name_overide=$(yq e ".model_files[$i].file_name" "$yaml_file")
        # Check if the folder is null or not set
        if [[ -z "$folder" || "$folder" == "null" ]]; then
            echo "Error: Folder name for URL $url is not set in the YAML file."
            continue
        fi
        
        # Check if the folder is in the ignore list
        if [[ " ${ignore_folders[*]} " =~ " ${folder} " ]]; then
            echo "Skipping download for $url as $folder as it is in the ignore list."
            continue
        fi

        # Check if the config_name is in the ignore list
        if [[ " ${ignore_config_names[*]} " =~ " ${config_name} " ]]; then
            echo "Skipping download for $url as $config_name as it is in the ignore list."
            continue
        fi 

        # Pass file_name_overide to download_model function if it exists and is not empty or null
        if [[ -n "$file_name_overide" && "$file_name_overide" != "null" ]]; then
            download_model "$url" "$folder" "$file_name_overide"
        else
            download_model "$url" "$folder"
        fi
    done
}


# Function to print usage
print_usage() {
    echo "Usage: $0 --model_yaml path/to/model_spec.yaml [--root_path path/to/modeldir]"
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --model_yaml) model_yaml="$2"; shift ;;
        --root_path) root_path="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; print_usage; exit 1 ;;
    esac
    shift
done

# Check if model_spec was provided
if [[ -z "$model_yaml" ]]; then
    echo "Error: --model_yaml is required."
    print_usage
    exit 1
fi


# Base directory for models
mkdir -p "$root_path"

# Read and download models from the YAML file
download_models_from_yaml "$model_yaml"
