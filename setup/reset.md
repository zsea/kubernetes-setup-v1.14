# 重置环境

我们在安装的过程中，难免会出现各种各样的问题，这时我们需要重置环境进行重新安装。

kubeadm提供了命令```kubeadm reset```对环境进行重置。

通过该命令重置后，我们仍然需要手动清理一些目录和文件。

此处提供了脚本```reset.sh```对环境进行清理。

```
curl -fsSL "https://raw.githubusercontent.com/zsea/kubernetes-setup-v1.14/master/attachments/reset.sh" | bash
```