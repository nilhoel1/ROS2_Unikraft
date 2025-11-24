# Base image with Ubuntu 22.04 (Jammy) for ROS2 Humble support
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set locale
RUN apt-get update && apt-get install -y locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install essential build tools and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    sudo \
    vim \
    nano \
    python3 \
    python3-pip \
    python3-dev \
    pkg-config \
    libncurses-dev \
    libyaml-dev \
    flex \
    bison \
    bc \
    unzip \
    uuid-runtime \
    dh-autoreconf \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install ROS2 Humble dependencies
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository universe \
    && apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release

# Add ROS2 repository and install ROS2 Humble base
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null \
    && apt-get update && apt-get install -y \
    ros-humble-ros-base \
    ros-humble-rmw-fastrtps-cpp \
    ros-humble-rmw-cyclonedds-cpp \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-argcomplete \
    && rm -rf /var/lib/apt/lists/*

# Initialize rosdep
RUN rosdep init || true \
    && rosdep update

# Install Unikraft dependencies
RUN apt-get update && apt-get install -y \
    gcc-aarch64-linux-gnu \
    gcc-x86-64-linux-gnu \
    qemu-system-x86 \
    qemu-system-arm \
    qemu-kvm \
    libguestfs-tools \
    socat \
    && rm -rf /var/lib/apt/lists/*

# Install Kraft CLI (Unikraft build tool)
RUN pip3 install --upgrade pip \
    && pip3 install git+https://github.com/unikraft/pykraft.git

# Create a non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Setup ROS2 environment for the user
RUN echo "source /opt/ros/humble/setup.bash" >> /home/$USERNAME/.bashrc

# Set working directory
WORKDIR /workspace

# Change ownership
RUN chown -R $USERNAME:$USERNAME /workspace

# Switch to non-root user
USER $USERNAME

# Set default shell
SHELL ["/bin/bash", "-c"]

CMD ["/bin/bash"]
