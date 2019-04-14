# ETCD集群安装

> 在大多数的教程中，都是使用的docker镜像安装etcd集群。我们为了以后将集群独立到其它服务器上，将直接在CentOS上安装etcd集群。

**1\. ETCD软件安装**

在我们规划的3台ETCD集群机器上执行以下命令：
```
yum install -y etcd
chkconfig etcd on
```

**2\. 集群配置**

集群配置文件位于```/etc/etcd/etcd.conf```。

> 打开配置文件后，能发现很多配置项（其中很多配置项已经被注释掉），我们需要根据我们的环境进行配置。此处仅描述这里使用到的配置项，请根据每个节点的不同环境进行配置。

|配置项|示例值|备注|
|---|---|---|
|ETCD_DATA_DIR|/var/lib/etcd/default.etcd|ETCD数据的存储目录，此处使用的默认值。|
|ETCD_LISTEN_PEER_URLS|http://192.168.0.77:2380|伙伴（集群节点）通信地址。|
|ETCD_LISTEN_CLIENT_URLS|http://192.168.0.77:2379|客户端连接地址。|
|ETCD_NAME|etcd1|节点名称，请注意每一台机器的节点名不要重复。|
|ETCD_INITIAL_ADVERTISE_PEER_URLS|http://192.168.0.77:2380|集群初始化时的伙伴通信地址。|
|ETCD_ADVERTISE_CLIENT_URLS|http://192.168.0.77:2379|客户端连接地址。|
|ETCD_INITIAL_CLUSTER|etcd1=http://192.168.0.77:2380|集群成员，多个成员间用英文逗号(```,```)分隔。|
|ETCD_INITIAL_CLUSTER_TOKEN|k8s|如果在你的网络内有多个集群，请设置不同的值。|

**3\. 集群启动**

在配置完成后，在所有节点上执行```service etcd start```启动集群。

> 在启动过程中可能会出现卡的情况，此时，只需要把其它节点的上服务启动即可正常。
