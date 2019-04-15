# 命名空间

命名空间（Namespace）是kubernetes系统中的一个重要的概念，通过将系统内部的对象“分配”到不同的Namespace中，形成逻辑上分组的不同项目、小组或用户组，便于不同的分组在共享使用整个集群的资源的同时还能被分别管理。

在集群创建成功后，默认会创建```default```，```kube-system```和```kube-public```三个命名空间。但我们在部署应用前，一般会创建自己的命名空间。

1. 查询
    
    在Master节点上使用命令```kubectl get namespaces```，可以查看集群的命令空间。

    ```
    # kubectl get namespaces
    NAME              STATUS   AGE
    default           Active   2d22h
    kube-public       Active   2d22h
    kube-system       Active   2d22h

    ```
2. 创建

    命名空间的创建可以使用```命令```和```yaml```文件两种方式创建。

    * 命令方式

        ```
        kubectl create namespace tao11-services
        ```

    * yaml方式

        ```yaml
        apiVersion: v1
        kind: Namespace
        metadata:
            name: tao11-services
            labels:
                name: tao11-services
        ```