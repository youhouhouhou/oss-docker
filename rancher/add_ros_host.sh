#!/usr/bin/env bash

# Usage: ./add_ros_host.sh ros-1

ROS_ISO_LOCAL_URL="http://local-fileserver/rancher/os/releases/download/v0.7.1/rancheros.iso"
#ROS_ISO_LOCAL_URL="http://local-fileserver/rancher/os/releases/download/v0.8.0-rc9/rancheros.iso"

ROS_CPU_COUNT=2
#ROS_MEMORY=2048
ROS_MEMORY=3072
docker-machine create -d virtualbox \
    --virtualbox-boot2docker-url ${ROS_ISO_LOCAL_URL} \
    --virtualbox-cpu-count ${ROS_CPU_COUNT} \
    --virtualbox-memory ${ROS_MEMORY} \
    $1
docker-machine ls
