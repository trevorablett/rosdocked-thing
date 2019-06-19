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
RUN apt-get install -y x11-apps build-essential
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py
RUN pip install --upgrade pip
RUN pip install catkin_tools

# there's an error with apt get for ros packages for some reason that wasn't
# happening before...probably needs more investigation
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F42ED6FBAB17C654
RUN apt-get update

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

# Mount anything that's mounted in media (e.g. other hard drives)
VOLUME "/media"

# Clone user into docker image and set up X11 sharing
RUN \
  echo "${user}:x:${uid}:${uid}:${user},,,:${home}:${shell}" >> /etc/passwd && \
  echo "${user}:x:${uid}:" >> /etc/group && \
  echo "${user} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${user}" && \
  chmod 0440 "/etc/sudoers.d/${user}"


# Install custom python modules -- if more are added, use a requirements.txt file instead
ADD /python-packages/liegroups /python-packages/liegroups
WORKDIR /python-packages/liegroups
RUN pip install -e .
ADD /python-packages/manipulator-learning /python-packages/manipulator-learning
WORKDIR /python-packages/manipulator-learning
RUN pip install -e . 


# libfreenect2 - see https://github.com/OpenKinect/libfreenect2
ADD dependencies/libfreenect2/ /dependencies/libfreenect2
WORKDIR /dependencies/libfreenect2/depends
RUN ./download_debs_trusty.sh
RUN apt-get install -y cmake pkg-config
RUN dpkg -i debs/libusb*deb
RUN apt-get install -y libturbojpeg libjpeg-turbo8-dev
RUN dpkg -i debs/libglfw3*deb; sudo apt-get install -f
WORKDIR /dependencies/libfreenect2
RUN mkdir build
WORKDIR /dependencies/libfreenect2/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/freenect2
RUN make
RUN make install

# Other kinect dependencies
RUN apt-get install -y \
	ros-indigo-visp-hand2eye-calibration ros-indigo-aruco-ros


# Switch to user
USER "${user}"
# This is required for sharing Xauthority
ENV QT_X11_NO_MITSHM=1
ENV CATKIN_TOPLEVEL_WS="${workspace}/devel"
# Switch to the workspace
WORKDIR ${workspace}

# For ROS, add in bashrc lines
# Removed, since now that we're using an existing user (and hence their .bashrc file as well),
# their own .bashrc file may already include this (and we shouldn't modify it anyways)
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
