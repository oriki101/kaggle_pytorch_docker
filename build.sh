#!/bin/bash
IMAGE_NAME="kaggle_pytorch:1.11.0-cuda11.3-cudnn8-runtime"
docker build . -t ${IMAGE_NAME}
