# 应用部署

应用部署可以使用```kubectl```命令，也可以使用```dashboard```。

本章将描述```apibus```的部署。APIBus是系统所有api的入口，完成所有api的参数校验、权限控制、隐藏内部接口地址。

APIBUS在从云上部署时，仅需要redis，为了方便，我们将演示如何在从云上部署。

> ```apibus```部署成功后，可以使用官方测试工具进行测试。[https://zsea.github.io/apibus/build/index.html#/test](https://zsea.github.io/apibus/build/index.html#/test)