from ubuntu:bionic

#useradd -s /bin/bash -m -G sudo user


RUN apt-get update && apt-get install -y apt-utils sudo gosu wget git

# Create new user `docker` and disable 
# password and gecos for later
# --gecos explained well here:
# https://askubuntu.com/a/1195288/635348
RUN adduser --disabled-password --gecos '' user

#  Add new user docker to sudo group
RUN adduser user sudo

# Ensure sudo group users are not 
# asked for a password when using 
# sudo command by ammending sudoers file
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# now we can set USER to the 
# user we just created
USER user

# we can now run sudo commands 
# as non-root user `docker` without
# password prompt
RUN sudo apt-get update 

WORKDIR /home/user/src

RUN wget -O /tmp/tom_setup "$( echo "bit.ly/tom_setup" | sed 's/#/%23/g' )" && \
    chmod +x /tmp/tom_setup && \
    bash -c "/tmp/tom_setup -c true -b true"
    
RUN sudo apt-get update && sudo apt-get install -y g++ swig3.0 python3-dev libpython3-dev make libsdl2-dev

RUN cd /home/user && git clone https://github.com/BlackLight/leap-sdk-python3 && cd leap-sdk-python3 && sed -i 's/^SWIG=swig/SWIG=swig3.0/g' build.sh && make && sudo make install

RUN cd /home/user && git clone http://github.com/shadow-robot/sr_teleop_devices && cd sr_teleop_devices/sr_leap_motion/scripts && sed -i 's/install/install -y/g' install_sdk.sh && ./install_sdk.sh

COPY . .
