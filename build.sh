#!/usr/bin/env bash

set -e

#
ALPINE_IMAGES_DIRECTORIES=( "alpine" "docker-registry" "mvnsite" "gogs" "java" "postgresql" "jenkins" "sonarqube" )
# "nexus3"
CENTOS_IMAGES_DIRECTORIES=( "nexus" )
#
DEBIAN_UBUNTU_IMAGES_DIRECTORIES=( "ldap" "mysql" "rabbitmq" "rancher" "ubuntu-scm" "jenkins-jnlp-slave" "jenkins-swarm-slave" "gitlab-runner" )

function build_images() {
    local directories=($(echo "$1"))
    for directory in "${directories[@]}"; do
        echo "directory '${directory}'"
        if [ -d ${directory} ]; then
            (cd ${directory} && docker-compose build)
        else
            echo "directory '${directory}' not found"
        fi
    done
}

function push_images() {
    local from="$1"
    local to="$2"
    local ifs_backup="${IFS}"
    IFS=$'\r\n'
    local images=($(docker images | grep ${from}))
    IFS="${ifs_backup}"
    for image in "${images[@]}"; do
        echo "image '${image}'"
        local id=$(echo "${image}" | awk '{print $3}')
        local prefix=$(echo "${image}" | awk '{print $1}' | sed "s#${from}#${to}#")
        local tag=$(echo "${image}" | awk '{print $2}')
        echo "tag ${id} to ${prefix}:${tag}"
        #docker tag ${id} ${prefix}:${tag}
        docker push ${prefix}:${tag}
    done
}

#build_images "$(echo "${ALPINE_IMAGES_DIRECTORIES[@]}")"
#build_images "$(echo "${CENTOS_IMAGES_DIRECTORIES[@]}")"
#build_images "$(echo "${DEBIAN_UBUNTU_IMAGES_DIRECTORIES[@]}")"

#push_images "registry.docker.local" "registry.docker.internal"
