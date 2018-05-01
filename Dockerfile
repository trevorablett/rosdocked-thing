FROM ros:indigo

# Arguments
ARG user
ARG uid
ARG home
ARG workspace
ARG shell

# Basic Utilities
RUN apt-get -y update
RUN apt-get install -y zsh curl screen tree sudo ssh synaptic vim

# Python.
RUN apt-get install -y python-dev python-pip python3-dev python3-pip
RUN pip install --upgrade pip
RUN pip3 install --upgrade pip

# Neovim
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:neovim-ppa/unstable
RUN apt-get -y update
RUN apt-get install -y neovim
RUN pip install neovim
RUN pip3 install neovim

# Latest X11 / mesa GL
RUN apt-get install -y\
  xserver-xorg-dev-lts-trusty\
  libegl1-mesa-dev-lts-trusty\
  libgl1-mesa-dev-lts-trusty\
  libgbm-dev-lts-trusty\
  mesa-common-dev-lts-trusty\
  libgles2-mesa-lts-trusty\
  libwayland-egl1-mesa-lts-trusty\
  libopenvg1-mesa

# Dependencies required to build rviz
RUN apt-get install -y\
  qt4-dev-tools\
  libqt5core5a libqt5dbus5 libqt5gui5 libwayland-client0\
  libwayland-server0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1\
  libxcb-render-util0 libxcb-util0 libxcb-xkb1 libxkbcommon-x11-0\
  libxkbcommon0

# The rest of ROS-desktop
RUN apt-get install -y ros-indigo-desktop-full

# Additional development tools
RUN apt-get install -y x11-apps python-pip build-essential
RUN pip install catkin_tools

# Thing dependencies.
RUN apt-get install -y \
  ros-indigo-soem ros-indigo-ros-control ros-indigo-socketcan-interface \
  ros-indigo-moveit ros-indigo-ur-modern-driver ros-indigo-geometry2 \
  ros-indigo-robot-localization ros-indigo-hector-gazebo \
  ros-indigo-gazebo-ros-control libeigen3-dev

# Make symlinks to find header files.
RUN ln -s /usr/include/eigen3/Eigen /usr/include/Eigen
RUN ln -s /usr/include/gazebo-2.2/gazebo /usr/include/gazebo
RUN ln -s /usr/include/sdformat-1.4/sdf /usr/include/sdf

# Gaussian process package.
RUN pip install GPy

# Set up for networking with the Thing.
# RUN echo 191.168.131.1 cpr-tor11-01 >> /etc/hosts

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
