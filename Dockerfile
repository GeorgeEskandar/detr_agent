# Use a base image with CUDA 10.1/10.2 compatible PyTorch
FROM pytorch/pytorch:1.5.1-cuda10.1-cudnn7-runtime

# Set the working directory
WORKDIR /workspace/detr

# Install conda and update it
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Add Miniconda to the path
ENV PATH /opt/conda/bin:$PATH

# Install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy

# Clone the repository
RUN git clone https://github.com/facebookresearch/detr.git /workspace/detr

# Install PyTorch, torchvision
RUN conda install -y -c pytorch \
    pytorch=1.5.1 \
    torchvision=0.6.1

# Install Cython and Scipy
RUN conda install -y cython scipy

# Install pycocotools
RUN pip install -U 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI'

# (Optional) Install panopticapi for panoptic functionalities
RUN pip install git+https://github.com/cocodataset/panopticapi.git

# Set the default command to run the model
CMD ["python", "main.py", "--batch_size", "2", "--no_aux_loss", "--eval", "--resume", "https://dl.fbaipublicfiles.com/detr/detr-r50-e632da11.pth", "--coco_path", "/path/to/coco"]