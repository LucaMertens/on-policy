FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV SC2PATH=/opt/StarCraftII

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    unzip \
    build-essential \
    cmake \
    libssl-dev \
    libffi-dev \
    python3-dev \
    xvfb \
    x11vnc \
    xauth \
    libx11-dev \
    libxext-dev \
    libxrender-dev \
    libxtst6 \
    libxi6 \
    && rm -rf /var/lib/apt/lists/*

# Download and install StarCraft II (headless Linux version)
RUN mkdir -p /tmp/sc2 && \
    cd /tmp/sc2 && \
    wget -q http://blzdistsc2-a.akamaihd.net/Linux/SC2.4.10.zip && \
    unzip -q -P "iagreetotheeula" SC2.4.10.zip && \
    mv StarCraftII /opt/ && \
    rm -rf /tmp/sc2

# Download mini games for PySC2
RUN mkdir -p /opt/StarCraftII/Maps && \
    cd /tmp && \
    wget -q https://github.com/deepmind/pysc2/releases/download/v1.2/mini_games.zip && \
    unzip -q mini_games.zip && \
    rm -rf /opt/StarCraftII/Maps/mini_games && \
    mv mini_games /opt/StarCraftII/Maps/ && \
    rm mini_games.zip


# Download SMAC Maps
RUN cd /opt && \
    wget https://github.com/oxwhirl/smac/releases/download/v1/SMAC_Maps_V1.tar.gz && \
    tar -xzf SMAC_Maps_V1.tar.gz && \
    mv SMAC_Maps /opt/StarCraftII/Maps/ && \
    rm SMAC_Maps_V1.tar.gz

# Download stableid.json for SMAC
RUN cd /opt/StarCraftII && \
    wget https://raw.githubusercontent.com/Blizzard/s2client-proto/master/stableid.json


ENV PYTHONPATH=/workspace/on-policy

ENV DISPLAY=:0
ENV QT_X11_NO_MITSHM=1
ENV XAUTHORITY=/tmp/.docker.xauth

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh \
    && bash miniconda.sh -b -p /opt/conda \
    && rm miniconda.sh \
    && /opt/conda/bin/conda clean -ya

# Add conda to PATH
ENV PATH=/opt/conda/bin:$PATH

# Create conda environment
RUN conda create -n marl python=3.8 -y
ENV CONDA_DEFAULT_ENV=marl
ENV PATH=/opt/conda/envs/marl/bin:$PATH

# Install PyTorch for CUDA 12.4 (using compatible version)
RUN pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu118

# Set working directory
WORKDIR /workspace

# Copy the repository
COPY . /workspace/on-policy/

# Install the on-policy package
WORKDIR /workspace/on-policy
RUN pip install -e .

# Install additional dependencies
# RUN pip install \
#     numpy \
#     scipy \
#     tensorboard \
#     wandb \
#     gym \
#     seaborn \
#     cffi \
#     pygame \
#     imageio \
#     protobuf==3.20.3




# # Build Hanabi environment
# RUN cd /workspace/on-policy/onpolicy/envs/hanabi && \
#     mkdir -p build && \
#     cd build && \
#     cmake .. && \
#     make -j

# # Install SMAC
# RUN pip install pysc2 && \
#     pip install git+https://github.com/oxwhirl/smac.git

# # Install MPE
# RUN pip install git+https://github.com/openai/multiagent-particle-envs.git

# # Install GRF (Google Research Football)
# RUN apt-get update && apt-get install -y \
#     libgl1-mesa-dev \
#     libsdl2-dev \
#     libboost-all-dev \
#     && rm -rf /var/lib/apt/lists/*

# RUN pip install gfootball

# Set up permissions
RUN chmod +x /workspace/on-policy/onpolicy/scripts/*.sh

# Set the working directory to the scripts folder
WORKDIR /workspace/on-policy/onpolicy/scripts

# Expose port for TensorBoard (optional)
EXPOSE 6006


# Default command
CMD ["/bin/bash"]