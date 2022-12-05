#!/usr/bin/env bash

set -e

export aurora_folder="$HOME/aurora"

sudo apt-get update

sudo apt-get install -y python3-dev libxml2-dev libxslt-dev python3-pip lcov wget git libssl-dev libffi-dev libyaml-dev
sudo pip3 install --upgrade pip setuptools==51.1.1 gcovr
sudo pip3 install PyYAML==5.4.1 --ignore-installed

# Clean up useful_things
rm -rf $aurora_folder
git clone --depth 1 git@github.com:shadow-robot/aurora/ $aurora_folder
cd $aurora_folder/ansible

sudo pip3 install -r data/requirements.txt

PYTHONUNBUFFERED=1 ansible-playbook -v -i "localhost," -c local docker_site.yml --tags "installation/docker"
