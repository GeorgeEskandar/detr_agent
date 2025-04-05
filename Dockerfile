FROM pytorch/pytorch:1.9.0-cuda10.2-cudnn7-runtime

# Set the working directory
WORKDIR /workspace

# Install necessary system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    git \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

# Update PATH environment variable
ENV PATH="/opt/conda/bin:$PATH"

# Create and activate a conda environment
RUN conda create -n detr_env python=3.9 -y && \
    echo "source activate detr_env" > ~/.bashrc

# Activate the environment
SHELL ["/bin/bash", "-c", "source activate detr_env"]

# Install conda packages
RUN conda install -y \
    cython \
    pycocotools \
    scipy=1.9.0

# Install Python packages
RUN conda install -y torchvision=0.10.0

# Copy the project files into the docker working directory
COPY . /workspace

# Expose the port the app runs on
EXPOSE 8000

# Define the command to run the model
CMD ["python", "main.py"]
