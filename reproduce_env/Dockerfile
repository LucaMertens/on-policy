# Stage 1: Minimal StarCraft II downloader
FROM ubuntu:questing AS starcraft-downloader

# Install minimal dependencies for downloading
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
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


# ----------------------------------


FROM alpine:latest AS keyring_downloader
RUN apk add --no-cache wget
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-keyring_1.0-1_all.deb


# ----------------------------------


# Stage 2: Main application container
FROM pytorch/pytorch:1.5.1-cuda10.1-cudnn7-devel
# FROM pytorch/pytorch:1.13.1-cuda11.6-cudnn8-devel

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV SC2PATH=/opt/StarCraftII


# Import new GPG key for NVIDIA CUDA
RUN apt-key del 7fa2af80
COPY --from=keyring_downloader /cuda-keyring_1.0-1_all.deb /tmp/cuda-keyring_1.0-1_all.deb
RUN dpkg -i /tmp/cuda-keyring_1.0-1_all.deb
RUN sed -i '/developer\.download\.nvidia\.com\/compute\/cuda\/repos/d' /etc/apt/sources.list 
RUN sed -i '/developer\.download\.nvidia\.com\/compute\/cuda\/repos/d' /etc/apt/sources.list.d/*
RUN sed -i '/developer\.download\.nvidia\.com\/compute\/machine-learning\/repos/d' /etc/apt/sources.list.d/*



# Install system dependencies
RUN rm -rf /etc/apt/sources.d/cuda*.list  && \
    apt-get update && apt-get install -y \
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
    libjpeg-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy StarCraft II from the downloader stage
COPY --from=starcraft-downloader /opt/StarCraftII /opt/StarCraftII

# Add deadsnake's repository for Python 3.6
# RUN apt-get update && apt-get install -y software-properties-common && \
#     add-apt-repository ppa:deadsnakes/ppa && \
#     apt-get update && \
#     apt-get install -y \
#     python3.6 \
#     python3.6-dev \
#     && rm -rf /var/lib/apt/lists/*

# Install PyTorch for CUDA 12.4 (using compatible version)
# RUN pip install torch==1.5.1+cu101 torchvision==0.6.1+cu101 -f https://download.pytorch.org/whl/torch_stable.html


# ENV PYTHONPATH=/workspace/on-policy

# ENV DISPLAY=:0
ENV QT_X11_NO_MITSHM=1
# ENV XAUTHORITY=/tmp/.docker.xauth

RUN pip install git+https://github.com/oxwhirl/smacv2.git
RUN pip install wandb

# Copy the repository
COPY . /workspace/on-policy/


# Install the on-policy package
WORKDIR /workspace/on-policy
RUN pip install -e .

# RUN pip install -r requirements.txt


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

RUN pip install typing_extensions>=4.5 --upgrade

# RUN pip install \
#     packaging>=24 \
#     ordered-set>=3.1.1 \
#     more_itertools>=8.8 \
#     jaraco.text>=3.7 \
#     importlib_resources>=5.10.2 \
#     importlib_metadata>=6 \
#     tomli>=2.0.1 

RUN pip install tensorboardX protobuf==3.20



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

# RUN apt-get update
# RUN apt-get install -y gcc g++ gperf bison flex texinfo help2man make libncurses5-dev \
#     python3-dev autoconf automake libtool libtool-bin gawk wget bzip2 xz-utils unzip \
#     patch rsync meson ninja-build

# # Install crosstool-ng
# RUN wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.26.0.tar.bz2
# RUN tar -xjf crosstool-ng-1.26.0.tar.bz2
# RUN cd crosstool-ng-1.26.0 && ./configure --prefix=/crosstool-ng-1.26.0/out && make && make install
# ENV PATH=$PATH:/crosstool-ng-1.26.0/out/bin




# Set the working directory to the scripts folder

# Expose port for TensorBoard (optional)
EXPOSE 6006

LABEL container_owner="lmertens"
LABEL purpose="AuLearn Exam Paper"

# Default command
CMD ["/bin/bash"]