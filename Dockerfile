FROM nvidia/cuda:11.7-cudnn8-devel-ubuntu20.04

# Set up the environment and install miniconda
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
ENV USER=detr
RUN useradd -ms /bin/bash $USER
USER $USER
WORKDIR /home/$USER

# Download and install miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /home/$USER/miniconda.sh \
    && /bin/bash /home/$USER/miniconda.sh -b -p $HOME/miniconda \
    && rm /home/$USER/miniconda.sh

# Initialize conda
ENV PATH="$HOME/miniconda/bin:$PATH"
RUN conda init bash

# Clone the DETR repository
RUN git clone https://github.com/facebookresearch/detr.git
WORKDIR /home/$USER/detr

# Create and activate conda environment
RUN conda create -n detr_env python=3.9 -y
RUN echo "conda activate detr_env" >> ~/.bashrc
SHELL ["/bin/bash", "-c"]
RUN conda activate detr_env

# Install PyTorch and torchvision
RUN conda install -n detr_env -c pytorch pytorch=1.13.1 torchvision

# Install additional dependencies for COCO evaluation
RUN conda install -n detr_env -c conda-forge cython scipy
RUN pip install -U -n detr_env 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI'

# Optional: Install panopticapi for panoptic segmentation
RUN pip install -n detr_env git+https://github.com/cocodataset/panopticapi.git

# Expose directory for COCO dataset
VOLUME ["/data/coco"]

CMD ["/bin/bash"]

# Command to evaluate DETR R50 on COCO val5k can be run manually as:
# python main.py --batch_size 2 --no_aux_loss --eval --resume https://dl.fbaipublicfiles.com/detr/detr-r50-e632da11.pth --coco_path /data/coco