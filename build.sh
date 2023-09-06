#!/bin/bash

repos_dir=~/repos

if [ -d "$repos_dir" ]; then
    cd "$repos_dir"
else
    mkdir -p "$repos_dir"
    cd "$repos_dir"
fi

if git --version >/dev/null 2>&1; then 
    echo "Git is installed, proceding."
else 
    echo "Git is not installed"
    echo "This script will now install git" 
    sudo apt-get install git
fi


git clone https://github.com/lllyasviel/Fooocus.git

# move Dockerfile and begin changing the repo
mv Dockerfile-aidreaming $repos_dir/Fooocus/
mv requirements_aidreaming.txt $repos_dir/Fooocus/

cd $repos_dir/Fooocus

#Pinning to a known working version
git checkout 09e0d1cb3ae5a1d74443009a41da9f96c1b54683

echo ""
echo "If you have already downloaded the models separately You will need to interrupt"
echo "this build process and place them in the right location within the git repo." 
sleep 2
echo "The contents of this script contains the directories for the models."
sleep 2
echo "Once this is done restart the script and type anything other than 'exit' at the following prompt."
echo ""

sleep 5

read -p "Do you want to download the models? (Type 'yes' to download now (checks if file exists first), 'exit' to interrupt this process): " confirmation
if [ "$confirmation" = "yes" ]; then
    # Downlaoding models only if they are not already downloaded
    base_model='https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0_0.9vae.safetensors'
    if [ -f ~/repos/Fooocus/models/checkpoints/sd_xl_base_1.0_0.9vae.safetensors ]; then 
        echo "Base model already exists"; 
    else 
        echo "Base model does not exist."
        echo "Downloading to ~/repos/Foocus/models/checkpoints"
        wget -P ~/repos/Fooocus/models/checkpoints $base_model
    fi

    refiner_model='https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0_0.9vae.safetensors'
    if [ -f ~/repos/Fooocus/models/checkpoints/sd_xl_refiner_1.0_0.9vae.safetensors ]; then 
        echo "refiner model already exists"; 
    else 
        echo "refiner model does not exist."
        echo "Downloading to ~/repos/Foocus/models/checkpoints"
        wget -P ~/repos/Fooocus/models/checkpoints $refiner_model
    fi


    lora_model='https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_offset_example-lora_1.0.safetensors'
    if [ -f ~/repos/Fooocus/models/loras/sd_xl_offset_example-lora_1.0.safetensors ]; then 
        echo "Lora model already exists"; 
    else 
        echo "Lora model does not exist."
        echo "Downloading to ~/repos/Foocus/models/loras"
        wget -P ~/repos/Fooocus/models/loras $lora_model
    fi
elif [ "$confirmation" = "exit" ]; then
    echo "Process interrupted. Exiting the script."
    exit 0
else
    echo "Confirmation not received. Skipping the download. This prevent the models being built into the docker image."
    sleep 5
fi


# Change the default number of images to generate per prompt to 1
sed -i "s/image_number = gr.Slider(label='Image Number', minimum=1, maximum=32, step=1, value=2)/image_number = gr.Slider(label='Image Number', minimum=1, maximum=32, step=1, value=1)/" ~/repos/Fooocus/webui.py

# Stop the launch script trying to download models
sed -i "s/download_models()/#download_models()/" launch.py

# enable cuda_malloc() function
sed -i "s/# cuda_malloc()/cuda_malloc()/" launch.py

# build container
echo "Building the docker image"
sleep 1
sudo docker build -f $repos_dir/Fooocus//Dockerfile-aidreaming -t aidreaming:0.0.1 .

echo ""
echo "You can now run the container with"
echo "docker run --gpus all -p 7860:7860 aidreaming:0.0.1"
echo ""
echo "This does not work in --detached mode."
echo "if you want to volume mount the models into  container use -v $(pwd)/localmodel:/app/models/checkpoints"

