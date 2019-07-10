#!/bin/bash 
sudo apt-get install -y curl ca-certificates lib32gcc1 binutils xdg-utils software-properties-common sudo libvulkan1 usbutils libcap2-bin
sudo apt-get update
cd /tmp
wget http://mirrors.kernel.org/ubuntu/pool/main/u/udev/libudev0_175-0ubuntu9_amd64.deb
sudo dpkg -i libudev0_175-0ubuntu9_amd64.deb
mkdir ~/steamcmd
cd ~/steamcmd
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzvf steamcmd_linux.tar.gz
./steamcmd.sh +login anonymous +quit
cd ..
mkdir -p ~/.steam/sdk32 ~/.steam/sdk64
cp steamcmd/linux32/steamclient.so .steam/sdk32
cp steamcmd/linux64/steamclient.so .steam/sdk64
cd ~/steamcmd
./steamcmd.sh +login shadow_software_1 shadow_software +force_install_dir ~/.steam +app_update 250820 -beta beta validate +quit
sudo setcap CAP_SYS_NICE=eip ~/.steam/bin/linux64/vrcompositor-launcher




