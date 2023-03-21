## 版本说明
Ubuntu 20.04
containerd 1.6.6
>Ubuntu 20.04自带的containerd是1.5.9，存在bug，故不要dpk安装，而是使用官网的二进制安装。貌似containerd 1.6.6 支持k8s 1.24+版本，不必特意匹配最新版的k8s，此结论未验证

kubelet kubeadm kubectl v1.24.3(理论可以选择更高版本，未测试)
## 安装步骤说明
- 1. pre check
     Ubuntu 默认无selinux，无需特意关闭  
     Ubuntu 默认关闭ufw防火墙，无需特意关闭  
     其他准备工作参见官网，如关闭swap，开启ipv4转发等等
- 2. 基础组件安装
1. containerd使用二进制安装，且需修改/etc/containerd/config.toml两处：sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.6"和SystemdCgroup = true，SystemdCgroup是启用Systemd管理cgroup。注意改的是SystemdCgroup = false，而不是systemd_cgroup = false
2. apt-get install -y kubelet kubeadm kubectl之前通常指定了如阿里云源，指定版本安装使用apt-get install -y kubelet=1.24.3-00 kubeadm=1.24.3-00 kubectl=1.24.3-00，版本号来自查询apt-cache madison kubeadm|grep 1.24.3
- 3. control-plane初始化/node加入集群
1. 初始化： kubeadm init --image-repository registry.aliyuncs.com/google_containers --apiserver-advertise-address=${masterip} --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint=${masterhostname}
2. 加入节点前先安装cni插件，kubectl apply -f kube-flannel.yml--https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml   无cni插件的话，pod不能正常running。先下载，修改 kube-flannel.yml，在约第 200 行左右增加指定网卡的配置（"- --kube-subnet-mgr"所在行下面）:"- --iface=ens33"，写死指定网卡是为了避免多个网卡出现意外。
3. 切换IPVS，检查是否支持、install ipvsadm、edit kube-proxy后删除kube-proxy pod 生效

[参考1](https://blog.abreaking.com/article/171)  
[参考2](https://www.jianshu.com/p/88d29d96337e)
[切换ipvs](https://www.luyouli.com/?p=558)