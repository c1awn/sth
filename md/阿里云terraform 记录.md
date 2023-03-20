# 阿里云terraform 记录

> 写在前面
> 
> 1. 国内网络对terraform不友好，在第一步init就会hang住，直到超时，damn it。不过terraform是通过https请求官网，故可以搭建https proxy，在使用terraform前声明这个proxy即可
> 
> 2. 阿里云的[Cloud Shell (aliyun.com)](https://shell.aliyun.com/)  可以直接使用terraform，猜官方走了代理。但其存活时间只有1小时，到期自动销毁，如果要持久化，需要挂载nas，需另外付费
> 
> 3. 网上搜“terraform加速“基本上都是在第一次init请求官网后做本地缓存，并没有解决第一次init的加速问题
> 
> 4. 体验阿里云的ECS等资源创建需要账户余额大于等于100RMB，否则会提示"Message: code: 403, Your account does not have enough balance"
> 
> 5. 阿里云的modules本身存在缺陷，故如果自查实在查不到问题，可能要看阿里云的源码：[警告！不要使用任何阿里云官方提供的Terraform模块 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/404400583) 

本文涉及产品的版本：

```
 terraform -version
Terraform v1.4.0
on linux_amd64  

 $home/.terraform.d/terraform-plugin-cache/registry.terraform.io/aliyun/alicloud/1.201.1/
└── linux_amd64
    └── terraform-provider-alicloud_v1.201.1
```

## 1. 安装terraform

[Install | Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/downloads)  

## 2. 配置阿里云鉴权AK

调用阿里云通过ram账户，开通ram账户不细说，关键是terraform如何使用这个ram账户？下面是官方的说明：通过profile参数调用，profile的type是string。

```
variable "profile" {
  description = "(Deprecated from version 2.8.0) The profile name as set in the shared credentials file. If not set, it will be sourced from the ALICLOUD_PROFILE environment variable."
  type        = string
  default     = ""
}
```

怎么声明这个profile？

1. 阿里云cli
   
   ```shell
   # 安装阿里云cli，假设下载文件在 ~/Download 目录下
   cd  $HOME/Download
   tar xfz aliyun-cli-linux-3.0.30-amd64.tgz
   sudo mv aliyun /usr/local/bin  
   
   #配置profile
   aliyun configure set \
     --profile terraform \   //这个地方指定了profile的名字是terraform，后续调用需要使用名字terraform
     --mode AK \
     --region cn-hangzhou \
     --access-key-id AccessKeyId \
     --access-key-secret AccessKeySecret
   ```

2. export 环境变量，"If not set,it will be sourced from the ALICLOUD_PROFILE environment variabl"，即如果上述cli没有设定profile，则读取环境变量。
   
   ```
   #1.明文vars，非常不安全
   provider "alicloud" {
     access_key = "your_access_key"
     secret_key = "your_access_secret"
     region     = "cn-hangzhou"
   }
   #2.export下面三个  
   export ALICLOUD_ACCESS_KEY="your_access_key"
   export ALICLOUD_SECRET_KEY="your_access_secret"
   export ALICLOUD_REGION="cn-hangzhou"
   ```

如果是第一种生成profile文件，怎么使用这个profile？

```shell
terraform {
  backend "oss" {
    profile             = "terraform"  //用profile参数指定"terraform"名字
    bucket              = "terraform-oss-backend-1024"
    key                 = "prod/terraform.tfstate"
    tablestore_endpoint = "https://tf-oss-backend.cn-hangzhou.Tablestore.aliyuncs.com"
    tablestore_table    = "terraform-oss-backend-1024"
    acl                 = "private"
    encrypt             = true
    ...
  }
}
```

## 3. 调试demo的main.tf

前提条件：阿里云账户大于等于100RMB，ram账户已配置，profile已配置（或用env引用）

1. 新建工作目录demo

2. 创建main.tf

3. 注意ECS实例的规格、数量、带宽等，尽量选最便宜的
   
   ```
   provider "alicloud" {}
   
   resource "alicloud_vpc" "vpc" {
     name       = "tf_test_foo"
     cidr_block = "172.16.0.0/12"
   }
   
   resource "alicloud_vswitch" "vsw" {
     vpc_id            = "${alicloud_vpc.vpc.id}"
     cidr_block        = "172.16.0.0/21"
     availability_zone = "cn-beijing-b"
   }
   resource "alicloud_security_group" "default" {
    name = "default"
    vpc_id = "${alicloud_vpc.vpc.id}"
   }
   
   resource "alicloud_instance" "instance" {
   
   # cn-beijing
   
   availability_zone = "cn-beijing-b"
    security_groups = ["${alicloud_security_group.default.*.id}"]
   
   # series III
   
   instance_type = "ecs.n2.small"
    system_disk_category = "cloud_efficiency"
    image_id = "ubuntu_140405_64_40G_cloudinit_20161115.vhd"
    instance_name = "test_foo"
    vswitch_id = "${alicloud_vswitch.vsw.id}"
    internet_max_bandwidth_out = 10
   
   }
   
   resource "alicloud_security_group_rule" "allow_all_tcp" {
    type = "ingress"
    ip_protocol = "tcp"
    nic_type = "intranet"
    policy = "accept"
    port_range = "1/65535"
    priority = 1
    security_group_id = "${alicloud_security_group.default.id}"
    cidr_ip = "0.0.0.0/0"
   }
   ```

## 4. 参考

1. proxy配置

```
cat /etc/profile
 ***略
 export proxy="http://192.168.1.10:7890"
 export http_proxy=$proxy
 export https_proxy=$proxy
 export no_proxy="localhost,127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
```
