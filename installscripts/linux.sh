##!/bin/bash
if [[ -n "$(command -v yum)" ]]
then
if [[ ! -n "$(command -v npm)" ]]
  then
  sudo yum -y install nodejs
  sudo yum install gcc-c++ make
fi
sudo rpm --import https://rpm.packager.io/key
echo "[collector]
name=Repository for founderbliss/collector application.
baseurl=https://rpm.packager.io/gh/founderbliss/collector/centos6/master
enabled=1" | sudo tee /etc/yum.repos.d/collector.repo
sudo yum install collector
elif [[ -n "$(command -v apt-get)" ]]
  sudo apt-get install nodejs
then
if [[ ! -n "$(command -v npm)" ]]
  then
  sudo yum -y install nodejs npm
  sudo yum install gcc-c++ make
fi
wget -qO - https://deb.packager.io/key | sudo apt-key add -
echo "deb https://deb.packager.io/gh/founderbliss/collector wheezy master" | sudo tee /etc/apt/sources.list.d/collector.list
sudo apt-get update
sudo apt-get install collector
fi
