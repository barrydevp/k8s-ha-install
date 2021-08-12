#!/usr/bin/env bash

#url :https://github.com/chadoe/docker-cleanup-volumes/blob/master/docker-cleanup-volumes.sh

function 1_drain_and_delete_k8s_node {
    MSG1 "1. drain and delete k8s node"
    kubectl drain ${DEL_WORKER} --force --ignore-daemonsets --delete-emptydir-data --delete-local-data
    kubectl delete node ${DEL_WORKER}
}


function 2_delete_k8s_service_and_file {
    MSG1 "2. delete k8s service and file"
    # k8s service list
    local K8S_SERVICE_LIST=(
        kube-apiserver
        kube-controller-manager
        kube-scheduler
        kube-proxy
        kubelet)
    # k8s file list
    local K8S_FILE_LIST=(
        /root/.kube/
        /etc/kubernetes/
        /etc/systemd/system/kubelet.service.d/
        /etc/etcd/
        /etc/cni/
        /opt/cni/
        /var/lib/kubelet/
        /var/lib/kube-proxy/
        /var/lib/etcd/
        /var/lib/calico/
        /lib/systemd/system/kube-apiserver.service
        /lib/systemd/system/kube-controller-manager.service
        /lib/systemd/system/kube-scheduler.service
        /lib/systemd/system/kube-proxy.service
        /lib/systemd/system/kubelet.service
        /lib/systemd/system/etcd.service
        /usr/local/bin/kube-apiserver
        /usr/local/bin/kube-controller-manager
        /usr/local/bin/kube-scheduler
        /usr/local/bin/kube-proxy
        /usr/local/bin/kubelet
        /usr/local/bin/kubectl
        /usr/local/bin/helm
        /usr/local/bin/etcd
        /usr/local/bin/etcdctl
        /usr/local/bin/cfssl
        /usr/local/bin/cfssl-json
        /usr/local/bin/cfssl-certinfo
        /var/log/kubernetes/
        /var/log/calico/
        /var/log/containers/
        /var/log/pods/)

    # stop k8s service
    for SERVICE in "${K8S_SERVICE_LIST[@]}"; do
        ssh root@${DEL_WORKER} "systemctl disable --now ${SERVICE}"
    done

    # delete k8s file
    for FILE in "${K8S_FILE_LIST[@]}"; do
        ssh root@${DEL_WORKER} "rm -rf ${FILE}"
    done
}


function 3_remove_docker_and_file {
    MSG1 "3. remove docker-ce containerd"

    DOCKER_CONTAINERD_FILE_LIST=(
        /var/lib/docker/
        /etc/docker/
        /run/docker/
        /run/docker.sock
        /var/lib/containerd/
        /etc/containerd/
        /run/containerd/
        /var/lib/dockershim/
        /run/dockershim.sock)

    # remove docker-ce containerd
    scp root@${DEL_WORKER}:/etc/os-release /tmp/
    source /tmp/os-release
    rm -rf /tmp/os-release
    case $ID in
        "ubuntu")
            ssh root@${DEL_WORKER} "systemctl disable --now containerd docker"
            ssh root@${DEL_WORKER} "apt-mark unhold docker-ce docker-ce-cli"
            ssh root@${DEL_WORKER} "apt-get purge -y docker-ce docker-ce-cli containerd.io; apt-get autoremove -y"
            ssh root@${DEL_WORKER} "groupdel docker"
            for FILE in "${DOCKER_CONTAINERD_FILE_LIST[@]}"; do
                ssh root@${DEL_WORKER} "rm -rf ${FILE}"
            done
            ssh root@${DEL_WORKER} reboot
            return
            ;;
        "centos"|"rhel")
            ssh root@${DEL_WORKER} "systemctl disable --now containerd docker"
            ssh root@${DEL_WORKER} "yum remove -y docker-ce docker-ce-cli containerd.io"
            ssh root@${DEL_WORKER} "groupdel docker"
            for FILE in "${DOCKER_CONTAINERD_FILE_LIST[@]}"; do
                ssh root@${DEL_WORKER} "rm -rf ${FILE}"
            done
            ssh root@${DEL_WORKER} reboot
            return
            ;;
    esac
}


function del_k8s_node {
    MSG1 "Deleting k8s worker node ..."
    1_drain_and_delete_k8s_node
    2_delete_k8s_service_and_file
    3_remove_docker_and_file
}

# 确认是否是 k8s 管理员
# 确认是否包含该主机
# 确认是否能 ssh 过去