
    # Use the official CUDA image with cuDNN and Ubuntu 20.04
    FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04

    # Set working directory
    WORKDIR /workspace/detr

    # Install system dependencies and Conda
    RUN apt-get update && apt-get install -y --no-install-recommends \
        wget \
        git \
        && rm -rf /var/lib/apt/lists/*
        
    # Install Miniconda
    ENV PATH="/root/miniconda3/bin:\$PATH"
    RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
        && /bin/bash Miniconda3-latest-Linux-x86_64.sh -b \
        && rm Miniconda3-latest-Linux-x86_64.sh

    # Clone DETR repository
    RUN git clone https://github.com/facebookresearch/detr.git ./

    # Create the Conda environment and install dependencies
    RUN conda install -c pytorch \
        pytorch=2.0.1 torchvision=0.15.2 torchaudio=2.0.2 pytorch-cuda=11.8 \
        scipy cython \
        && conda clean -ya

    # Install pycocotools for COCO evaluation
    RUN pip install -U 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI' \
        && pip install 'git+https://github.com/cocodataset/panopticapi.git'

    # Default command to run inference
    ENTRYPOINT ["python", "main.py", "--batch_size", "2", "--no_aux_loss", "--eval", "--resume", "https://dl.fbaipublicfiles.com/detr/detr-r50-e632da11.pth", "--coco_path", "/path/to/coco"]
  