# Deployment 是什么？

Deployment为Pod和Replica Set（下一代Replication Controller）提供声明式更新。

您只需要在 Deployment 中描述您想要的目标状态是什么，Deployment controller 就会帮您将 Pod 和ReplicaSet 的实际状态改变到您的目标状态。您可以定义一个全新的 Deployment 来创建 ReplicaSet 或者删除已有的 Deployment 并创建一个新的来替换。

**注意：** 您不该手动管理由 Deployment 创建的 ReplicaSet，否则您就篡越了 Deployment controller 的职责！下文罗列了 Deployment 对象中已经覆盖了所有的用例。

典型的用例如下：

* 使用Deployment来创建ReplicaSet。ReplicaSet在后台创建pod。检查启动状态，看它是成功还是失败。
* 通过更新Deployment的PodTemplateSpec字段来声明Pod的新状态。这会创建一个新的ReplicaSet，Deployment会按照控制的速率将pod从旧的ReplicaSet移动到新的ReplicaSet中。
* 如果当前状态不稳定，回滚到之前的Deployment revision。每次回滚都会更新Deployment的revision。
* 伸缩Deployment以满足不同的负载。
* 暂停Deployment来应用PodTemplateSpec的多个修复，然后恢复上线。
* 根据Deployment 的状态判断上线是否hang住了。
* 清除旧的不必要的 ReplicaSet。

当你编写好一个```yaml```文件后，使用```kubectl create -f ```命令进行安装。

1. yaml编写

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

2. 安装

    > 假设你将上面的yaml文件保存为```apibus.yaml```的文件。

    ```
    kubectl create -f ./apibus.yaml
    ```

3. 验证

    当以上操作成功后，可以使用命令```kubectl get deployment -n <ns>```命令来查看刚才部署好的应用。

    ```
    # kubectl get deployment -n default
    NAME     READY   UP-TO-DATE   AVAILABLE   AGE
    apibus   2/2     2            2           19h
    ```
    > 此时，当你的```pod```异常中止时，会被自动重启，自动重启后，IP地址也会发生变化。如果你的应用仅仅是一个后台服务或者不用对外提供服务，可以不用进行后面步骤。