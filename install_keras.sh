sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt-get install -y python3.8 python3.8-distutils

sudo apt remove -y python3-pip
sudo python3.8 -m easy_install pip
sudo python3.5 -m easy_install pip


sudo apt-get install -y build-essential cmake unzip pkg-config
sudo apt-get install -y libxmu-dev libxi-dev libglu1-mesa libglu1-mesa-dev
sudo apt-get install -y libjpeg-dev libpng-dev libtiff-dev
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
sudo apt-get install -y libxvidcore-dev libx264-dev
sudo apt-get install -y libgtk-3-dev
sudo apt-get install -y libopenblas-dev libatlas-base-dev liblapack-dev gfortran
sudo apt-get install -y libhdf5-serial-dev
sudo apt-get install -y python3-dev python3-tk python-imaging-tk
sudo apt-get install -y python3.8-dev python3.8-tk python-imaging-tk


python3.8 -m pip install --upgrade pip

python3.8 -m pip install numpy
python3.8 -m pip install scipy matplotlib pillow
python3.8 -m pip install imutils h5py requests progressbar2
python3.8 -m pip install scikit-learn scikit-image
python3.8 -m pip install tensorflow
python3.8 -m pip install keras
python3.8 -m pip install empy
