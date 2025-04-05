FROM nvidia/cuda:10.2-cudnn7-devel

# Set environment variables
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PYTHONUNBUFFERED=1

# Install Python and necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.8 \
    python3-pip \
    python3.8-dev \
    && rm -rf /var/lib/apt/lists/*

# Install conda
RUN pip3 install conda

# Set up the working directory
WORKDIR /workspace/detr

# Clone the DETR repository
RUN git clone https://github.com/facebookresearch/detr.git .

# Create conda environment and install dependencies
RUN conda install -c pytorch pytorch=1.5 torchvision=0.6 cudatoolkit=10.2 && \
    conda install cython scipy && \
    pip install -U 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI' && \
    pip install git+https://github.com/cocodataset/panopticapi.git

# Copy project files into the container
COPY . /workspace/detr

# Command to run the model
CMD ["python3", "main.py", "--batch_size", "2", "--no_aux_loss", "--eval", "--resume", "https://dl.fbaipublicfiles.com/detr/detr-r50-e632da11.pth", "--coco_path", "/path/to/coco"]