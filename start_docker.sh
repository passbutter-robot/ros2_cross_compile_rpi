#!/bin/bash

if [ ! -d "./ros2_ws" ]; then
  echo "# create 'ros2_ws' folder "
  mkdir -p ./ros2_ws
  chmod 777 ./ros2_ws
fi

if [ ! -d "./rootfs" ]; then
  echo "# create 'rootfs' folder"
  mkdir -p ./rootfs
  chmod 777 ./rootfs
fi

echo "# building docker image..."



docker build -t rpi_cross_compile -f Dockerfile .

echo ""
echo "# volumes mounts:"
echo ""
echo "#  $(pwd)/rootfs  => synchronized / mounted with the filesystem of the rpi"
echo "#  $(pwd)/ros2_ws => cross-compiled ROS2 workspace that is transfered to the rpi"
echo ""
echo ""

echo "raspberry pi preparation:"

echo ""
echo "# install compilation dependencies"
echo "sudo apt install \""
echo "    liblog4cxx-dev \""
echo "    python3-dev"

echo "# runtime dependencies"
echo "sudo apt install \""
echo "    python3-numpy \""
echo "    python3-netifaces \""
echo "    python3-yaml"

echo "# optional tools"
echo "sudo apt install sshfs"
echo ""
echo ""

echo "ros2 cross-compilation:"

echo ""
echo "# 1. prepare rootfs"
echo "sshfs -o follow_symlinks,allow_other -o cache_timeout=115200 pi@[raspberry_pi_ip]:/ /home/develop/rootfs"

echo ""
echo "# 2. initialiize ros2 ws"
echo "cross-initialize"

echo ""
echo "# 3. a) compile ros2 code"
echo "cross-colcon-build --packages-up-to ros2topic"

echo ""
echo "# 3. b) custom ros2 packages"
echo "git clone --recurse-submodules https://github.com/passbutter-robot/passbutter_hw_ros.git src/passbutter_hw_ros"
echo "cross-colcon-build --packages-up-to passbutter_hw_ros"

echo ""
echo "# 4. transfer cross-compiled ros2 ws to rpi"
echo "scp -r install pi@[raspberry_pi_ip]:/home/pi/ros2"
echo ""
echo ""

echo "start docker container"
docker run -it \
  --device /dev/fuse \
  --cap-add SYS_ADMIN \
  --security-opt apparmor:unconfined \
  -v $PWD/rootfs:/home/develop/rootfs \
  -v $PWD/ros2_ws:/home/develop/ros2_ws \
  rpi_cross_compile \
  /bin/bash