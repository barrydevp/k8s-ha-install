#!/usr/bin/env bash

# Copyright 2021 hybfkuf
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

stage_three() {
    MSG1 "========================= Stage 3: Install Docker =============================";

    mkdir -p "$KUBE_DEPLOY_LOG_PATH/logs/stage-three"
    case $linuxID in
    centos)
        # Linux: centos
        source centos/3_install_docker.sh
        for node in "${ALL_NODE[@]}"; do
            MSG3 "*** $node *** is Installing Docker"
            ssh root@$node \
                "export TIMEZONE=$TIMEZONE
                 export KUBE_VERSION=$KUBE_VERSION
                 $(typeset -f 1_install_docker)
                 $(typeset -f 2_configure_docker)
                 $(typeset -f 3_configure_containerd)
                 1_install_docker
                 2_configure_docker
                 3_configure_containerd" \
                 &>> "$KUBE_DEPLOY_LOG_PATH/logs/stage-three/$node.log" &
        done
        MSG3 "please wait... (multitail -s 3 -f $KUBE_DEPLOY_LOG_PATH/logs/stage-three/*.log)"
        wait
        ;;
    rocky)
        # Linux: rocky
        source rocky/3_install_docker.sh
        for node in "${ALL_NODE[@]}"; do
            MSG3 "*** $node *** is Installing Docker"
            ssh root@$node \
                "export TIMEZONE=$TIMEZONE
                 export KUBE_VERSION=$KUBE_VERSION
                 $(typeset -f 1_install_docker)
                 $(typeset -f 2_configure_docker)
                 $(typeset -f 3_configure_containerd)
                 1_install_docker
                 2_configure_docker
                 3_configure_containerd" \
                 &>> "$KUBE_DEPLOY_LOG_PATH/logs/stage-three/$node.log" &
        done
        MSG3 "please wait... (multitail -s 3 -f $KUBE_DEPLOY_LOG_PATH/logs/stage-three/*.log)"
        wait
        ;;
    ubuntu)
        # Linux: ubuntu
        source ubuntu/3_install_docker.sh
        for node in "${ALL_NODE[@]}"; do
            MSG3 "*** $node *** is Installing Docker"
            ssh root@$node \
                "export TIMEZONE=$TIMEZONE
                 export KUBE_VERSION=$KUBE_VERSION
                 $(typeset -f _apt_wait)
                 $(typeset -f 1_install_docker)
                 $(typeset -f 2_configure_docker)
                 $(typeset -f 3_configure_containerd)
                 _apt_wait
                 1_install_docker
                 2_configure_docker
                 3_configure_containerd" \
                 &>> "$KUBE_DEPLOY_LOG_PATH/logs/stage-three/$node.log" &
        done
        MSG3 "please wait... (multitail -s 3 -f $KUBE_DEPLOY_LOG_PATH/logs/stage-three/*.log)"
        wait
        ;;
    debian)
        # Linux: debian
        source debian/3_install_docker.sh
        for node in "${ALL_NODE[@]}"; do
            MSG3 "*** $node *** is Installing Docker"
            ssh root@$node \
                "export TIMEZONE=$TIMEZONE
                 export KUBE_VERSION=$KUBE_VERSION
                 $(typeset -f _apt_wait)
                 $(typeset -f 1_install_docker)
                 $(typeset -f 2_configure_docker)
                 $(typeset -f 3_configure_containerd)
                 _apt_wait
                 1_install_docker
                 2_configure_docker
                 3_configure_containerd" \
                 &>> "$KUBE_DEPLOY_LOG_PATH/logs/stage-three/$node.log" &
        done
        MSG3 "please wait... (multitail -s 3 -f $KUBE_DEPLOY_LOG_PATH/logs/stage-three/*.log)"
        wait
        ;;
    *)
        ERR "Not Support Linux !" && exit $EXIT_FAILURE ;;
    esac
}
