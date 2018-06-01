#!/bin/bash

# # Root check
if [[ ${EUID} -ne 0 ]] ; then
    echo "Please run this script as root."
    exit 0
fi


# # Arch check
ARCH=""
case $(uname -m) in
  x86_64) ARCH="amd64" ;;
  arm)    dpkg --print-architecture | grep -q "arm64" && ARCH="arm64" || ARCH="arm" ;;
esac


# # Updates and dependencies
apt-get update
apt-get -y dist-upgrade
apt-get -qq install curl git
apt-get -y autoremove
apt-get -y autoclean


# # https://github.com/mikefarah/yq
AVAILABLE_YQ=$(curl -s "https://api.github.com/repos/mikefarah/yq/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
if [[ ${ARCH} == "arm64" ]]; then
  curl -L "https://github.com/mikefarah/yq/releases/download/${AVAILABLE_YQ}/yq_linux_arm" -o /usr/local/bin/yq
fi
if [[ ${ARCH} == "arm" ]]; then
  curl -L "https://github.com/mikefarah/yq/releases/download/${AVAILABLE_YQ}/yq_linux_arm" -o /usr/local/bin/yq
fi
if [[ ${ARCH} == "amd64" ]]; then
  curl -L "https://github.com/mikefarah/yq/releases/download/${AVAILABLE_YQ}/yq_linux_amd64" -o /usr/local/bin/yq
fi
chmod +x /usr/local/bin/yq


# # https://github.com/docker/docker-install
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh


# # https://docs.docker.com/compose/install/#install-compose
AVAILABLE_COMPOSE=$(curl -s "https://api.github.com/repos/docker/compose/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
curl -L "https://github.com/docker/compose/releases/download/${AVAILABLE_COMPOSE}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


# # https://docs.docker.com/install/linux/linux-postinstall/
groupadd docker
usermod -aG docker ${USER}
systemctl enable docker
echo "Don't forget to log out and log back in so that your group membership is re-evaluated"
