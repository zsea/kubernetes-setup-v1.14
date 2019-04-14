# Worker安装

worker的安装与第二、第三个master节点的安装基本相同，但是不需要复制```kubeadm```的证书。

根据第一个Master的成功提示，使用以下命令进行安装：

```
kubeadm join 192.168.31.250:6443 --token lnjoc2.zcy1aqim08z7ihbu --discovery-token-ca-cert-hash sha256:957d2dc29f0a240d1a6af45bd0afd09a092030cb8c280c7737874bcc14b903fb
```

此时，所有节点的安装已经完成。但你若是用```kubectl get node```进行查看，会发现所有的状态均为**NotReady**，这是因为我们没有安装网络插件。