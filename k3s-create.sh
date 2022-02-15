#!/bin/bash

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

usage() {
    cat << EOD

Usage: `basename $0` [options]

  Available options:
    -h           This message

  Creates a Kubernetes cluster based on k3s.

EOD
}

K3S_BIN="/usr/local/bin/k3s"
K3S_VERSION="v1.23.3+k3s1"
K3S_VERSION_STR="k3s version $K3S_VERSION (5fb370e5)"

# If kind exists, compare current version to desired one: kind version | awk '{print $2}'
if [ -e $K3S_BIN ]; then
    CURRENT_K3S_VERSION="v$(kind --version | head -n 1)"
    if [ "$CURRENT_K3S_VERSION" != "$K3S_VERSION_STR" ]; then
      sudo rm "$K3S_BIN"
    fi
fi

if [ ! -e $K3S_BIN ]; then
    curl -Lo /tmp/k3s https://github.com/k3s-io/k3s/releases/download/"$K3S_VERSION"/k3s
    chmod +x /tmp/k3s
    sudo mv /tmp/k3s "$K3S_BIN"
fi

K3S_CONFIG_FILE="$DIR/config.yaml"

# get the options
while getopts c:n:sp c ; do
    case $c in
        \?) usage ; exit 2 ;;
    esac
done
shift $(($OPTIND - 1))

if [ $# -ne 0 ] ; then
    usage
    exit 2
fi

sudo k3s server

# TODO
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/
sudo chown
export KUBECONFIG="$HOME/.kube/k3s.yaml"
