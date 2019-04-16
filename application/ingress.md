# Ingress

```Ingress``` 是从Kubernetes集群外部访问集群内部服务的入口。

> 在此之前，你应该已经安装好了```Ingress controller```。


1. yaml编写

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

2. 安装

    > 假设你将上面的yaml文件保存为```apibus-ingress.yaml```的文件。

    ```
    kubectl create -f ./apibus-ingress.yaml
    ```

3. 验证

    当以上操作成功后，可以使用命令```kubectl get ingress -n <ns>```命令来查看刚才部署好的应用。

    ```
    # kubectl get ingress -n default
    NAME     HOSTS              ADDRESS   PORTS   AGE
    apibus   apibus.***.com             80      22h
    ```

    可以看到，apibus的```Ingress```已经创建成功。

    此时，你可能通过域名来进行访问。
