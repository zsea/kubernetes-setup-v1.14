# Master安装

kubeadm有很多参数可以对集群进行各种设置。我们将使用```kubeadm init --config kubeadm-config.yaml --experimental-upload-certs```进行集群的初始化。

1. 配置文件

    ```yaml
    apiVersion: kubeadm.k8s.io/v1beta1
    bootstrapTokens:
    - groups:
        - system:bootstrappers:kubeadm:default-node-token
        token: lnjoc2.zcy1aqim08z7ihbu
        ttl: 24m0h0s
        usages:
        - signing
        - authentication
    kind: InitConfiguration
    localAPIEndpoint:
        advertiseAddress: 192.168.0.77
        bindPort: 6443
    nodeRegistration:
        criSocket: /var/run/dockershim.sock
        name: iZ8vbgg9sjhaqseztmokb4Z
        taints:
            - effect: NoSchedule
                key: node-role.kubernetes.io/master
    ---
    apiVersion: kubeadm.k8s.io/v1beta1
    kind: ClusterConfiguration
    kubernetesVersion: v1.14.0
    controlPlaneEndpoint: 192.168.31.250:6443
    imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers
    apiServer:
        certSANs:
        - k8s-master001
        - k8s-master002
        - k8s-master003
        - 192.168.0.77
        - 192.168.0.75
        - 192.168.0.76
        - 192.168.0.78
        - 192.168.31.250
        - 127.0.0.1
    etcd:
        external:
            endpoints:
            - http://192.168.0.77:2379
            - http://192.168.0.75:2379
            - http://192.168.0.76:2379
    networking:
        serviceSubnet: 172.16.0.0/24
        podSubnet: 172.16.0.0/16
    ```

2. 配置项说明
    > 仅对需要注意的配置项进行说明，其它配置项请参考官方文档。

    * bootstrapTokens.groups.token
        
        集群的token值，可能过命令```kubeadm token generate```生成。

    * bootstrapTokens.groups.ttl

        token的有效时长，在有效期内，其它节点可以使用该token加入集群，若超出有效期，则需要重新生成token才能加入。

    * localAPIEndpoint.advertiseAddress

        在本节点所侦听的IP地址，若有多个网卡或IP请指定。
    
    * localAPIEndpoint.bindPort

        在本节点所侦听的端口，默认情况下都使用```6443```。

    * kubernetesVersion

        所要拉取的Kubernetes系统镜像的版本号。

    * controlPlaneEndpoint

        集群的负载均衡地址，若不设置该参数，则其它Master节点不能用参数```--experimental-control-plane```加入。

    * imageRepository

        系统镜像地址的前缀，可以解决国内不能直接pull谷歌镜像的问题。

    * apiServer.certSANs

        apiServer中需要使用的https证书的域名。一般需要填写各master节点的hostname、IP，还有master集群（负载均衡）的IP（也可以是域名）地址。

    * etcd.external.endpoints

        外部ETCD集群的地址。

    * networking.serviceSubnet

        k8s中service使用的地址段。

    * networking.podSubnet

        k8s中pod使用的地址段。

3. Master初始化

    在第一个Master机器上```kubeadm-config.yaml```所在目录执行命令```kubeadm init --config kubeadm-config.yaml --experimental-upload-certs```。

    *由于我的机器修改过hostname，在安装的时候老是读取不到正确的hostname，所以在kubeadm参数中添加了```--node-name=k8s-master001```，所以我的完整命令是```kubeadm init --config kubeadm-config.yaml --experimental-upload-certs --node-name=k8s-master001```。*

    在初始化的过程中，kubeadm将生成需要的证书，并启动静态pod。

    初始化成功后，会有如下提示：

    ```
    You can now join any number of the control-plane node running the following command on each as root:

    kubeadm join 192.168.31.250:6443 --token lnjoc2.zcy1aqim08z7ihbu \
        --discovery-token-ca-cert-hash sha256:957d2dc29f0a240d1a6af45bd0afd09a092030cb8c280c7737874bcc14b903fb \
        --experimental-control-plane --certificate-key f30d8705ace48b6721584d02065f43cb5458fca0dc7f4f4ff7e359c0538d8c90

    Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
    As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
    "kubeadm init phase upload-certs --experimental-upload-certs" to reload certs afterward.

    Then you can join any number of worker nodes by running the following on each as root:

    kubeadm join 192.168.31.250:6443 --token lnjoc2.zcy1aqim08z7ihbu \
        --discovery-token-ca-cert-hash sha256:957d2dc29f0a240d1a6af45bd0afd09a092030cb8c280c7737874bcc14b903fb

    ```

4. 其它Master节点加入

    在其它Master节点加入前，需要将第一台服务器上生成的证书信息导入到其它节点，可以使用scp进行复制。

    ```
    scp -r root@192.168.0.77:/etc/kubernetes/pki /etc/kubernetes/
    ```

    然后根据第一个Master的成功提示，将Master加入节点。

    ```
    kubeadm join 192.168.31.250:6443 --token lnjoc2.zcy1aqim08z7ihbu --discovery-token-ca-cert-hash sha256:957d2dc29f0a240d1a6af45bd0afd09a092030cb8c280c7737874bcc14b903fb --experimental-control-plane --certificate-key f30d8705ace48b6721584d02065f43cb5458fca0dc7f4f4ff7e359c0538d8c90
    ```

现在，在任何一个Master节点上执行```kubectl get node```都可以看到以下信息。

```
# kubectl get node
NAME       STATUS     ROLES    AGE     VERSION
k8s-master001   NotReady   master   34m     v1.14.0
k8s-master002   NotReady   master   4m52s   v1.14.0
k8s-master003   NotReady   master   4m52s   v1.14.0
```

**提示：**在节点上执行kubectl命令前，需要将节点的配置信息存储到```$HOME/.kube```目录。

```
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```