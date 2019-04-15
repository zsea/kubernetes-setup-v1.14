# 快速部署

快速部署公共镜像仓库中的```apibus```镜像进行部署。

> 在一般情况下，部署公共镜像仓库中的镜像，你都需要安装加速器，请参考[准备工作](../setup/zhun-bei-gong-zuo.md)中的文档进行加速器的安装。

## 使用dashboard的创建应用进行部署

登录```kubernetes-dashboard```，点击右上角【创建】按钮，然后选择标签【创建应用】，根据提示进行填写，完成后，点击部署即可。

## 使用yaml文件进行部署

apibus是一个网络服务，在编写yaml时，需要编写```Deployment```与```Service```两部分。

1. Deployment部分

    ```yaml
    apiVersion: apps/v1beta1
    kind: Deployment
    metadata:
      name: apibus
      namespace: default
    spec:
      replicas: 2 #需要运行的实例个数
      template: # 运行pod的模板
        metadata:
          name: apibus
          labels:
            app: apibus
        spec:
          containers:
          - name: apibus
            image: zsea/apibus
            resources: #对pod进行资源限制
              limits:
                cpu: 50m
                memory: 1Gi
              requests:
                cpu: 5m
                memory: 50Mi
            env: #pod启动时的环境变量，请根据apibus文档进行设置
            - name: APIBUS_REDIS_HOST
              value: 
            - name: APIBUS_REDIS_PASSWORD
              value: 
            - name: APIBUS_REDIS_NUMBER
              value: "10"
            - name: APIBUS_CLUSTER_TOKEN
              value: 
            - name: APIBUS_CLUSTER_NODENAME
              value: 
            - name: APIBUS_ADMIN_APPKEY
              value: 
            - name: APIBUS_ADMIN_SECRET
              value:
            - name: APIBUS_PORT
              value: "3000"
            - name: APIBUS_RUN_LOG_LEVEL
              value: ERROR
            - name: FORWARD_MAX_TIMES
              value: "3"

    ```
    **在环境变量设置中，所有```value```的值必须是字符串，若为数字或布尔值，需要加引号。**

2. Service部分

    ```yaml
    kind: Service,
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

3. 部署应用

    > 很多时候，我们会将上面两个部分合并到一个文件进行部署。

    * 使用命令进行部署

        ```
        kubectl apply -f ./apibus.yaml
        ```

    * dashboard中部署

        如果已经部署好了kubernetes-dashboard，你可以在dashboard中粘贴或者上传上面的```yaml```文件进行部署。

    如果你的yaml编写没有问题，此时应该已经成功在命名空间```defalut```下添加了```apibus```的部署和服务。

4. 验证

    可以在```dashboard```中查看部署和服务，查看是否添加成功。

    我们使用命令```kubectl get deployment,svc```进行查看。

    ```
    # kubectl get deployment,svc
    NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.extensions/apibus   2/2     2            2           8m49s

    NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
    service/apibus       ClusterIP   172.16.0.168   <none>        80/TCP    6m24s
    service/kubernetes   ClusterIP   172.16.0.1     <none>        443/TCP   3d4h
    ```

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

5. 添加Ingress

    当前，我们的服务已经在集群中部署成功，也可以在集群节点上测试成功，但在互联网上还没能直接访问。

    可以使用```nodePort```将端口映射到节点主机上，也可以使用```Ingress```进行暴露。我们选择使用```Ingress```进行暴露。

    Ingress也是通过配置文件进行创建。

    ```yaml
    apiVersion: extensions/v1beta1
    kind: Ingress
    metadata:
      name: apibus
      namespace: default
    spec:
      rules:
      - host: apibus.***.com # 域名
        http:
          paths:
          - backend:
              serviceName: apibus #服务
              servicePort: 80  #端口
            path: /
    ```

    配置文件的说明请查看相关文档。

> ```apibus```部署成功后，可以使用官方测试工具进行测试。[https://zsea.github.io/apibus/build/index.html#/test](https://zsea.github.io/apibus/build/index.html#/test)