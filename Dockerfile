FROM ubuntu:20.04

# install dependencies
RUN apt update
RUN DEBIAN_FRONTEND="noninteractive" apt -y install tzdata
RUN apt install -y \
    wget \
    tar \
    python3-pip \
    git \
    cmake \
    qemu-user-static \
    python3-numpy \
    sshfs \
    rsync
RUN echo user_allow_other >> /etc/fuse.conf

# add 'develop' user
RUN useradd -m develop
RUN echo "develop:develop" | chpasswd
RUN usermod -aG sudo develop

# ros2 development dependencies
USER develop
RUN pip3 install \
    rosinstall_generator \
    colcon-common-extensions \
    vcstool \
    lark-parser
ENV PATH=/home/develop/.local/bin/:$PATH

# install compiler
USER root
WORKDIR /tmp
RUN wget https://github.com/Pro/raspi-toolchain/releases/latest/download/raspi-toolchain.tar.gz
RUN tar xfz raspi-toolchain.tar.gz --strip-components=1 -C /opt

# prepare ws
USER develop
WORKDIR /home/develop
COPY toolchain.cmake toolchain.cmake
COPY bashrc.sh bashrc.sh
RUN cat bashrc.sh >> $HOME/.bashrc
WORKDIR /home/develop/ros2_ws