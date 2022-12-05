# ML dockerfile

## Install docker
```bash
bash <(curl -Ls bit.ly/run-aurora) install_software software=['docker']
```

## Build and run image

```bash
mkdir /tmp/dockerfile && wget -O /tmp/dockerfile/Dockerfile "https://raw.githubusercontent.com/carebare47/useful_things/master/docker_ml/Dockerfile" && cd /tmp/dockerfile && docker build . -t test_ml_image && docker create --privileged --net=host -it --gpus all -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY -e QT_X11_NO_MITSHM=1 -e XDG_RUNTIME_DIR=/run/user/1000 -e LOCAL_USER_ID=$(id -u) --name test_ml_cont test_ml_image:latest
```
