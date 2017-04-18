
# Rancher测试集群

## 环境

  写文章时的环境:
  docker version is 17.03.0-ce, build 60ccb22
  docker-machine version is 0.10.0, build 76ed2a6
  VirtualBox from http://download.virtualbox.org/virtualbox/5.1.18/VirtualBox-5.1.18-114002-OSX.dmg

## 启动rancher server

    #docker-compose pull 或 build
    docker-compose up -d

    # 启动之后需要设置 高速docker-registry-mirror, 例如设置为: http://hub-mirror.c.163.com
    # sudo ros config set rancher.docker.extra_args "['--registry-mirror','<高速docker-registry-mirror>']"

    ./add_ros_host.sh ros-1
    docker-machine ssh ros-1 "sudo ros config set rancher.docker.extra_args \"['--registry-mirror','http://hub-mirror.c.163.com']\""
    docker-machine ssh ros-1 "sudo system-docker restart docker"

    ./add_ros_host.sh ros-2
    docker-machine ssh ros-2 "sudo ros config set rancher.docker.extra_args \"['--registry-mirror','http://hub-mirror.c.163.com']\""
    docker-machine ssh ros-2 "sudo system-docker restart docker"


### 设置Host Registration URL

  我们使用VirtualBox的虚机组成一个小集群,
  所以建议把Rancher的Host Registration URL设置为: http://192.168.99.1:18080

### 添加主机

  基础架构 -> 主机

  添加Rancher agent时, CATTLE_AGENT_IP 要设置成VirtualBox虚机内网段(192.168.99.0/24)的IP, 例如: 192.168.99.100,
  可使用`docker-machine ip ros-1`命令查看.

### 参考文档

[构建支持多编排引擎的容器基础设施服务](https://www.sdk.cn/news/6292)

### 制作Rancher OS启动U盘

On Mac:
Open the DiskUtility.app, and on your USB hard drive, unmount any of it's partitions. Do not eject the USB hard drive.
Right click on the hard drive in the DiskUtility and get it's Identifier from the Information tab.

    cp ${HOME}/.oss-cache/rancher/os/releases/download/v0.9.0/rancheros.iso ${HOME}/Desktop/ros-v090.iso
    sudo dd if=${HOME}/Desktop/ros-v090.iso of=/dev/<disk identifier>

### 安装Rancher OS到磁盘

准备数据盘, 使用FAT(MS-DOS)格式化

    docker pull rancher/os:v0.9.0
    #docker save rancher/os:v0.9.0 > ~/Desktop/ros-v090.tar
    docker tag rancher/os:v0.9.0 registry.docker.internal/rancheros:v0.9.0
    docker push registry.docker.internal/rancheros:v0.9.0

    touch ~/Desktop/ros-conf.yml
    echo -e "
    #hostname: ros-192-231
    ssh_authorized_keys:
    - $(cat ${HOME}/.ssh/internal-git.pub)
    rancher:
      docker:
        extra_args:
        - --insecure-registry
        - registry.docker.internal
        - --registry-mirror
        - http://hub-mirror.c.163.com
      network:
        dns:
          nameservers:
          - 10.141.7.50
          - 10.141.7.51
    #    interfaces:
    #      eth0:
    #        address: 10.106.192.231/24
    #        gateway: 10.106.192.1
    #        mtu: 1500
    #        dhcp: false
      system_docker:
        extra_args:
        - --insecure-registry
        - registry.docker.internal
        - --registry-mirror
        - http://hub-mirror.c.163.com
    " > ~/Desktop/ros-conf.yml

    sudo ros os list
    sudo ros service list

    sudo mkdir -p /mnt/sdc1
    sudo mount -t msdos /dev/sdc1 /mnt/sdc1
    cp /mnt/sdc1/ros-conf.yml ros-conf.yml
    cp /mnt/sdc1/ros-v090.tar ros-v090.tar
    sudo system-docker load < ros-v090.tar

    #sudo ros config set rancher.docker.extra_args "['--insecure-registry','registry.docker.internal','--registry-mirror','http://hub-mirror.c.163.com']"
    #sudo system-docker restart docker
    #sudo ros config set hostname ros-192-231
    #sudo ros config set rancher.network.dns.nameservers [10.141.7.50,10.141.7.51]
    #sudo ros config set rancher.network.interfaces.eth0.address 10.106.192.231/24
    #sudo ros config set rancher.network.interfaces.eth0.gateway 10.106.192.1
    #sudo ros config set rancher.network.interfaces.eth0.mtu 1500
    #sudo ros config set rancher.network.interfaces.eth0.dhcp false
    #sudo system-docker restart network
    #sudo ros config set rancher.system_docker.extra_args [--insecure-registry,registry.docker.internal,--registry-mirror,http://hub-mirror.c.163.com]

    #sudo ros install -c ros-conf.yml -d /dev/sda -i registry.docker.internal/rancheros:v0.9.0
    sudo ros install -c ros-conf.yml -d /dev/sda -i rancher/os:v0.9.0
