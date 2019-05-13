FROM lindwaltz/ros-indigo-desktop-full-nvidia

# Arguments
ARG user
ARG uid
ARG home
ARG workspace
ARG shell

# Basic Utilities
RUN apt-get -y update
RUN apt-get install -y zsh curl screen tree sudo ssh synaptic vim

# Additional development tools
RUN apt-get install -y x11-apps python-pip build-essential
RUN pip install catkin_tools

# Thing dependencies.
RUN apt-get install -y \
  ros-indigo-soem ros-indigo-ros-control ros-indigo-socketcan-interface \
  ros-indigo-moveit ros-indigo-ur-modern-driver ros-indigo-geometry2 \
  ros-indigo-robot-localization ros-indigo-hector-gazebo \
  ros-indigo-gazebo-ros-control ros-indigo-navigation libeigen3-dev \
  python-h5py

# Make symlinks to find header files.
RUN ln -s /usr/include/eigen3/Eigen /usr/include/Eigen
RUN ln -s /usr/include/gazebo-2.2/gazebo /usr/include/gazebo
RUN ln -s /usr/include/sdformat-1.4/sdf /usr/include/sdf

# Make SSH available
EXPOSE 22

# Mount the user's home directory
VOLUME "${home}"

# Clone user into docker image and set up X11 sharing
RUN \
  echo "${user}:x:${uid}:${uid}:${user},,,:${home}:${shell}" >> /etc/passwd && \
  echo "${user}:x:${uid}:" >> /etc/group && \
  echo "${user} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${user}" && \
  chmod 0440 "/etc/sudoers.d/${user}"

# Switch to user
USER "${user}"
# This is required for sharing Xauthority
ENV QT_X11_NO_MITSHM=1
ENV CATKIN_TOPLEVEL_WS="${workspace}/devel"
# Switch to the workspace
WORKDIR ${workspace}

# For ROS, add in bashrc lines
# RUN echo "\n#ROS\nsource /opt/ros/indigo/setup.bash" >> /root/.bashrc

# TEMP MORE STUFF TO ADD, DELETE THESE LINES AFTER
# somehow set HOME to be the same as the current users home, NOT root (i.e. the home of sudo)
# LD_LIBRARY_PATH=/home/tablett/.local/share/Steam/steamapps/common/SteamVR/bin/linux64:.
# libegl1-mesa-dev, libsdl2-dev

# Lines for testing VR through docker, but this basically didn't work
# VR dependencies
# pip dependencies
# RUN pip install openvr transforms3d

# linux dependencies
# RUN apt-get install -y software-properties-common
# RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y
# RUN apt-get update
# RUN apt-get install -y libstdc++6