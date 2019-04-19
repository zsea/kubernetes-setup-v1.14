# Service

> ```Service```是一个```Pod```的逻辑分组，一种可以访问它们的策略 —— 通常称为微服务。 这一组```Pod```能够被```Service```访问到，通常是通过```Label Selector```实现的。

> 举个例子，考虑一个图片处理 backend ，它运行了3个副本。这些副本是可互换的 —— frontend 不需要关心它们调用了哪个 backend 副本。 然而组成这一组 backend 程序的 ```Pod``` 实际上可能会发生变化，frontend 客户端不应该也没必要知道，而且也不需要跟踪这一组 backend 的状态。 ```Service``` 定义的抽象能够解耦这种关联。

1. yaml编写

    ```yaml
    kind: Service
    apiVersion: v1
    metadata: 
      name: apibus
      namespace: default
    spec:
      ports:
      - name: tcp-80-to-3000
        protocol: TCP
        port: 80  #服务所使用的端口
        targetPort: 3000 #pod启动的端口
      selector: #选择后端pod
        app: apibus
      type: ClusterIP
    ```

    **```port```和```targetPort```的数据类型为整型。**

2. 安装

    > 假设你将上面的yaml文件保存为```apibus-svc.yaml```的文件。

    ```
    kubectl create -f ./apibus-svc.yaml
    ```

3. 验证

    当以上操作成功后，可以使用命令```kubectl get svc -n <ns>```命令来查看刚才部署好的应用。

    ```
    # kubectl get svc -n default
    NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
    apibus       ClusterIP   172.16.0.168   <none>        80/TCP    22h
    kubernetes   ClusterIP   172.16.0.1     <none>        443/TCP   4d3h
    ```

    可以看到，apibus的```Service```已经创建成功。

    通过命令我们可以确认，已经部署了2个pod，且状态都为ready。同时，服务在集群内的地址是```172.16.0.168```。

    再使用命令确认一下响应是否正确
    ```
    # curl -I http://172.16.0.168
    HTTP/1.1 200 OK
    Content-Type: application/json; charset=utf-8
    Content-Length: 61
    Date: Mon, 15 Apr 2019 08:14:11 GMT
    Connection: keep-alive
    ```

    服务器返回200，部署成功。