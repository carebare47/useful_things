FROM nvidia/cuda:11.4.2-cudnn8-devel-ubuntu20.04

ENV PULSE_SERVER /run/pulse/native
ENV GOSU_VERSION 1.10
ENV MY_USERNAME user

ENV remote_create_user_script="https://raw.githubusercontent.com/carebare47/useful_things/master/docker_ml/create_user.sh"
ENV remote_additional_bashrc_cmds="https://raw.githubusercontent.com/shadow-robot/sr-build-tools/master/docker/utils/additional_bashrc_cmds_noetic"


# Make sure that NVIDIA hardware is visible and can be used for different kind of operations
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute
ENV NO_AT_BRIDGE=1

# COPY entrypoint.sh /usr/local/bin/entrypoint.sh
# COPY terminator_config /tmp/terminator_config

ENV DEBIAN_FRONTEND="noninteractive" TZ="Europe/London"

# Layer 1
RUN set -x && \
    \
    echo "Installing wget" && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends ca-certificates wget sudo python3-pip lsb-release curl && \
    apt-get install -y bash-completion && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && \
    \
    echo "Running one-liner" && \
    wget -O /tmp/setup_user "$( echo "$remote_create_user_script" | sed 's/#/%23/g' )" && \
    chmod 755 /tmp/setup_user && \
    /tmp/setup_user 'user' 'user' && \
    \
    echo "Updating bash commands" && \
    wget -O /tmp/additional_bashrc_cmds "$( echo "$remote_additional_bashrc_cmds" | sed 's/#/%23/g' )" && \
    cat /tmp/additional_bashrc_cmds >> /home/user/.bashrc && \
    \
    echo "Setting default terminator config" && \
    mkdir -p /home/$MY_USERNAME/.config/terminator/
    # mv /tmp/terminator_config /home/$MY_USERNAME/.config/terminator/config && \
    # chown -R $MY_USERNAME:$MY_USERNAME /home/$MY_USERNAME/.config
# Layer 2 Rest of libraries
RUN set -x && \
    \
    apt-get install -y -qq --no-install-recommends build-essential unzip git python3 python3-dev python3-tk python3-pip python-opengl \
    libsm6 libxext6 libglib2.0-0 libxrender1 libglvnd0 libgl1 libglx0 libegl1 libxext6 libx11-6 libcanberra-gtk-module libcanberra-gtk3-module \
    gir1.2-keybinder-3.0 libgl1-mesa-glx libgl1-mesa-dri terminator && \
    pip3 install h5py matplotlib scipy scikit-learn pandas plotly tensorflow-gpu torch==1.10.0+cu113 torchvision==0.11.1+cu113 torchaudio==0.10.0+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html && \
    pip3 install numpy==1.20 && \
    mkdir -p /run/user/1000 && \
    chmod 0700 /run/user/1000 && \
    chown 1000:1000 /run/user/1000 && \
    export XDG_RUNTIME_DIR=/run/user/1000 && \
    echo "Removing cache" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /home/$MY_USERNAME/.ansible /home/$MY_USERNAME/.gitconfig /root/.cache && \
    chmod 755 /usr/local/bin/entrypoint.sh
WORKDIR /home/user
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/terminator"]
