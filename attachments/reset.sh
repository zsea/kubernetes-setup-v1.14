#!/bin/bash
# reset.sh
kubeadm reset
systemctl stop docker kubelet etcd
docker rm -f $(sudo docker ps -qa)
for m in $(sudo tac /proc/mounts | sudo awk '{print $2}'|sudo grep /var/lib/kubelet);do
 sudo umount $m||true
done
rm -rf /var/lib/kubelet/
for m in $(sudo tac /proc/mounts | sudo awk '{print $2}'|sudo grep /var/lib/rancher);do
 sudo umount $m||true
done
rm -rf /var/lib/rancher/
rm -rf /run/kubernetes/
docker volume rm $(sudo docker volume ls -q)
docker ps -a
docker volume ls
yum remove -y docker* kubelet kubectl
rm -rf /var/lib/docker
rm -rf /var/lib/etcd
rm -rf /var/lib/kubelet
rm -rf /var/lib/calico
rm -rf /opt/cni
rm -rf /var/etcd/calico-data
rm -rf /usr/local/bin/Documentation
rm -rf /root/.kube
iptables -F
iptables -X
iptables -L
find / -type f -name docker*
find / -type f -name calico*
find / -type f -name etcd*
reboot
