#!/bin/bash

if git --version >/dev/null 2>&1; then 
    echo "Git is installed, proceding."
else 
    echo "Git is not installed"
    echo "This script will now install git" 
    sudo apt-get install git
fi

git clone https://github.com/lllyasviel/Fooocus.git

# place Dockerfile and requirements to Fooocus directory and begin building the container state
cp $(pwd)/Dockerfile-aidreaming $repos_dir/Fooocus/
cp $(pwd)/requirements_aidreaming.txt $repos_dir/Fooocus/

cd $repos_dir/Fooocus

#Pinning to a known working version
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
    ./model-downloader/downloader.sh --model_yaml ./model-downloader/model_files.yaml --root_path ./models
fi 



## I think this Might beable to be done in config or in dockerfile
# Change the default number of images to generate per prompt to 1
sed -i "s/image_number = gr.Slider(label='Image Number', minimum=1, maximum=32, step=1, value=2)/image_number = gr.Slider(label='Image Number', minimum=1, maximum=32, step=1, value=1)/" ~/repos/Fooocus/webui.py
# Stop the launch script trying to download models
sed -i "s/^download_models()/#download_models()/" launch.py


## Not Sure if this is still neccessary
# enable cuda_malloc() function
sed -i "s/# cuda_malloc()/cuda_malloc()/" launch.py

# build container
echo "Building the docker image"
sleep 1
sudo docker build -f $repos_dir/Fooocus/Dockerfile-aidreaming -t aidreaming:0.0.1 .

echo ""
echo "You can now run the container with"
echo "docker run --gpus all -p 7860:7860 aidreaming:0.0.1"
echo ""
echo "This does not work in --detached mode."
echo "if you want to volume mount the models into  container use -v $(pwd)/localmodel:/app/models/checkpoints"

