
# Use the official CUDA image from NVIDIA optimized for PyTorch
FROM nvidia/cuda:10.2-cudnn8-devel-ubuntu18.04

# Set up environment variables
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PATH=/opt/conda/bin:$PATH

# Install basic utilities
RUN apt-get update --fix-missing && apt-get install -y \
    wget \
    git \
    curl \
    ca-certificates \
    sudo \
    bzip2 \
    libx11-6 \
 && rm -rf /var/lib/apt/lists/*

# Install Miniconda and Python 3.7
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# Create a conda environment with PyTorch and Torchvision
RUN conda install -c pytorch \
    pytorch=1.5.0 \
    torchvision=0.6.0 \
    cudatoolkit=10.2

# Install additional dependencies
RUN pip install cython && \
    pip install 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI'

# Optional: Install additional tools for panoptic segmentation
RUN pip install 'git+https://github.com/cocodataset/panopticapi.git'

# Set the working directory
WORKDIR /detr

# Copy the repository files
COPY . .

# Command to execute when running the container
CMD ["python", "main.py", "--batch_size", "2", "--no_aux_loss", "--eval", "--resume", "https://dl.fbaipublicfiles.com/detr/detr-r50-e632da11.pth", "--coco_path", "/path/to/coco"]