
# Use the official PyTorch image with CUDA support
FROM pytorch/pytorch:2.2.2-cuda11.8-cudnn8-devel

# Set working directory
WORKDIR /app

# Install basic utilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    gcc \
    wget \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the current directory contents into the container at /app
COPY . /app

# Ensure Python 3.9 is used and update pip
RUN conda install python=3.9 && \
    pip install --upgrade pip

# Install Python dependencies
RUN pip install torch==2.2.2 torchvision==0.17.0 cython && \
    pip install git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI && \
    pip install scipy onnx onnxruntime submitit panopticapi

# Expose any necessary ports if required by the model\EXPOSE 8000 # Example

# Run the model or script 
CMD ["python", "YOUR_MODEL_SCRIPT.py"]