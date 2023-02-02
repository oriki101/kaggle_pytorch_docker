IMAGE_NAME="kaggle_pytorch:1.11.0-cuda11.3-cudnn8-runtime"

docker run --rm -it \
    --privileged \
    --gpus all \
    --shm-size 50G \
    -e LOCAL_UID=$(id -u $USER) \
    -e LOCAL_GID=$(id -g $USER) \
    -e PYTHONPATH=/home/developer/transformers:/home/developer/transformers/experiments/minigrid/dependencies/gym-minigrid:/home/developer/transformers/experiments/minigrid/dependencies/torch-ac \
    -v $(pwd)/../kaggle_pytorch_docker:/home/jovyan/kaggle_pytorch_docker\
    --net host \
    -e USE_VNC=true \
    -e DISPLAY=:5 \
    -e BUSID=$(nvidia-xconfig --query-gpu-info | grep BusID | sed -n 1p | cut -d' ' -f 6) \
    -e SCREEN_RESOLUTION=1280x1024x24 \
    -e VNC_PASSWORD=passpass \
    --name $(id -u -n)-kaggle_pytorch \
    ${IMAGE_NAME}
