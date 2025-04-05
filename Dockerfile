# Use the specified base Docker image with PyTorch
FROM pytorch/pytorch:1.5.1-cuda10.1-cudnn7-devel

# Set the working directory
WORKDIR /detr

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install conda if not already installed (commented to verify presence in base first)
# RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
#     /bin/bash ~/miniconda.sh -b -p /opt/conda && \
#     rm ~/miniconda.sh && \
#     /opt/conda/bin/conda clean -tipsy
# ENV PATH /opt/conda/bin:$PATH

# Copy the current directory contents into the container
COPY . /detr

# Create and activate conda environment with the specified Python version
RUN conda create -n detr_env python=3.7 && \
    echo "source activate detr_env" > ~/.bashrc

# Install Python dependencies in the conda environment
RUN /bin/bash -c "source activate detr_env && conda install \
    cython==0.29.23 \
    scipy==1.5.4 \
    torchvision==0.6.0 && \
    pip install -U \
    'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI' \
    git+https://github.com/cocodataset/panopticapi.git"

# Default command to run the model (to be specified appropriately)
CMD ["/bin/bash", "-c", "source activate detr_env && python -c 'print(\"Model running...\")'"]
