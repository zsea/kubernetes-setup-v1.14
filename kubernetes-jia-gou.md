# Kubernetes架构

说实话，这一节其实没必要写什么，网友们写的比我理解的更清晰、更合理。但是不写的话，总觉得缺少点什么，那还是按我理解的写一点吧。

## 核心组件

Kubernetes 主要由以下几个核心组件组成：

* etcd 保存了整个集群的状态
* kube-apiserver 提供了资源操作的唯一入口，并提供认证、授权、访问控制、API 注册和发现等机制
* kube-controller-manager 负责维护集群的状态，比如故障检测、自动扩展、滚动更新等
* kube-scheduler 负责资源的调度，按照预定的调度策略将 Pod 调度到相应的机器上
* kubelet 负责维持容器的生命周期，同时也负责 Volume（CVI）和网络（CNI）的管理
* Container runtime 负责镜像管理以及 Pod 和容器的真正运行（CRI），默认的容器运行时为 Docker
* kube-proxy 负责为 Service 提供 cluster 内部的服务发现和负载均衡

## 常用插件

除了核心组件，还有一些推荐的插件：

* kube-dns 负责为整个集群提供 DNS 服务 
* Ingress Controller 为服务提供外网入口 
* Heapster 提供资源监控 
* Dashboard 提供 GUI 
* Federation 提供跨可用区的集群 
* Fluentd-elasticsearch 提供集群日志采集、存储与查询

> 在本手记中，不包括Federation和Fluentd-elasticsearch的部分。