# 准备工作

## 硬件准备

当然，你需要先准备好服务器，我这里准备了6台服务器，3台做为Master节点（同时也用于ETCD集群的安装），3台做为Worker节点。

|hostname|IP     |备注    |
|---|---|---|
|k8s-master001|192.168.0.77|Master+ETCD|
|k8s-master002|192.168.0.75|Master+ETCD|
|k8s-master003|192.168.0.76|Master+ETCD|
|k8s-node001|192.168.0.74| |
|k8s-node002|192.168.0.73| |
|k8s-node003|192.168.0.72| |
| |192.168.31.250|Master负载均衡地址 |

> 我这里的服务器来自于阿里云的VPC网络，本来Master的负载均衡是计划使用阿里云的私网负载均衡，但是阿里云的私网负载均衡限制发起访问的地址不能是负载均衡的后端服务器（即如果```192.168.0.77```发起对负载均衡的访问，这时负载均衡的后端服务器不能是```192.168.0.77```），所以这里的```192.168.31.250```是手动在服务器上配置的另一个网段的私网地址，再在路由VPC的路由表中添加到```192.168.31.250```的路由）。如果```192.168.0.77```服务器出现故障，需要手动进行迁移```192.168.31.250```到另一台服务器。

> 如果你的网络允许，你也可以使用Keepalived来管理vip。

### CentOS绑定多个IP地址

1. 查看网卡信息

    使用命令```ip addr```查看当前的网卡与IP信息，确定新的IP需要绑定的网卡。比如```eth0```。

2. 添加IP

    复制配置文件```/etc/sysconfig/network-scripts/ifcfg-eth0```为```ifcfg-eth0:0```。

    ```
    cd /etc/sysconfig/network-scripts/
    cp ifcfg-eth0 ifcfg-eth0:0
    ```

    编辑文件```ifcfg-eth0:0```，找到```DEVICE=eth0```这一行，将其改为```DEVICE=eth0:0```，找到```IPADDR=xxx.xxx.xxx.xxx```这一行，替换成新的IP即可！

    ```
    DEVICE=eth0:0
    IPADDR=192.168.31.250
    PREFIX=24
    GATEWAY=192.168.0.253
    ```
3. 重启网络配置

    ```
    service network restart
    ```

    重启后，用```ip addr```查看IP地址是否生效。

    ```
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
        inet 127.0.0.1/8 scope host lo
        valid_lft forever preferred_lft forever
    2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
        link/ether 00:16:3e:02:84:bf brd ff:ff:ff:ff:ff:ff
        inet 192.168.0.77/24 brd 192.168.0.255 scope global dynamic eth0
        valid_lft 315146392sec preferred_lft 315146392sec
        inet 192.168.31.250/24 brd 192.168.31.255 scope global eth0:0
        valid_lft forever preferred_lft forever

    ```

    在```eth0```下，可以看到新增加的IP地址已经生效。

## 系统准备

> 我这里所有系统增多安装的```CentOS7.4```，内核版本为```3.10.0-693.2.2.el7.x86_64```。我没有见到强制的内核版本要求文档，不过建议使用高于以上版本的内核。

**以下所有操作，需要在所有机器上进行操作。**

### 操作系统设置

1. 关闭selinux,firewall
    ```
    setenforce 0 
    sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config 
    systemctl stop firewalld 
    systemctl disable firewalld
    ```

2. 关闭swap
    ```
    swapoff -a
    ```
    > 这是1.8版本后的要求，目的是不让swap干扰pod可使用的内存limit。

3. 内核修改

    ```
    cat <<EOF >  /etc/sysctl.d/k8s.conf
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
    EOF
    sysctl --system
    ```

    > 若不对这两项进行修改，请求数据经过iptables的路由可能有问题。

4. hosts设置

    编辑```/etc/hosts```文件，将所有机器的hostname与IP地址追加上去。若不在此处设置，则需要保证其上游DNS服务器能正确解析所有节点机器的hostname。

    > 最好能在第一次安装前确定好hostname。我由于安装时的一些问题，重新初始化集群的时候修改了hostname，但在系统里面显示的还是原来的hostname，最后只得在安装的时候强制指定hostname才行。

**阿里云服务器默认已经关闭了```selinux```与```swap```。**

### 软件安装

集群的初始化以及节点的加入都使用kubeadm进行设置，目前kubeadm已经可以用于生产环境的部署。

每一台机器需要安装以软件：

* docker-ce，版本：18.09.4
* kubeadm    版本：v1.14.1
* kubelet    版本：v1.14.1
* kubectl    版本：v1.14.1

> 以上的版本是我本次使用的软件版本，你也可以使用其它版本号。

1. 安装源修改
    由于我们的网络环境，将安装源修改为阿里云的镜像。

    * Kubernetes安装源修改
        ```
        cat << EOF > /etc/yum.repos.d/kubernetes.repo
        [kubernetes]
        name=Kubernetes
        baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
        enabled=1
        gpgcheck=1
        repo_gpgcheck=1
        gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
        EOF
        ```

    * docker-ce安装源修改

        ```
        wget -O /etc/yum.repos.d/docker-ce.repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
        ```
2. 软件安装

    ```
    yum install -y docker-ce
    yum install -y kubelet kubeadm kubectl
    ```

3. 设置启动

    由于软件安装好后，并没有自动开始运行，所以我们需要启动软件，并设置为开机自动启动。

    ```
    chkconfig docker on
    service docker start
    ```

> 以上所有操作，可以设置为一个脚本文件，方便在每一台机器上进行设置。你可以使用以下命令初始化每一台机器：

```
curl -fsSL "https://raw.githubusercontent.com/zsea/kubernetes-setup-v1.14/master/attachments/init.sh" | bash
```
