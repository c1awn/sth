# 自建derp中继遇到的坑

  Google搜索“derp自建”，排名靠前的一般都是docker镜像部署，不过[官网](https://tailscale.com/kb/1118/custom-derp-servers/) 是通过go直接二进制部署。derp服务首选是域名模式，ip模式未尝试。

  derp服务涉及TCP(80/443)和UDP协议(3478)，所谓的坑主要来自这个协议问题。

## TCP协议的坑

  通常不会使用80端口，故略。如果使用443端口，则服务默认通过let's encrypt获取ssl证书，故不需手动指定cert。443可能出现的问题：1.端口冲突，本地其他web服务已使用443，需要代理等解决；2.国内443端口需要备案。如果不使用443端口，采用自定义端口如5443，需要手动指定cert。

  但是，不管是二进制还是docker部署，只要使用自定义ssl端口，总是出现以下报错：

```
# Health check:
#     - not connected to home DERP region 900  //region 900是自定义derp服务
```

  出现上述报错的一个矛盾点：tailscale netcheck检测到自定义的derp服务（排名第一个），说明udp正常；访问https://derpdomain:port 也正常，说明tcp也没问题。那还一个可能性就是客户端校验，但是不管我是否开启"-verify-clients"，依旧是"not connected to home DERP region"。

## UDP协议的坑

  本来udp的3478端口已经写死，没有可变空间。如果你的derp服务建在家宽缓解，运营商可能干扰甚至屏蔽udp，故尽量不要在家宽环境搭建derp服务。

## 总结

为了避免干扰，下面的测试采用香港服务器，自建derp的服务器已启动tailscale客户端并加入账号，docker-compose见最后，二进制：`go version go1.20`  和`go install tailscale.com/cmd/derper@main` 

1. 二进制部署，端口443+3478，一切正常

2. 二进制部署，端口5443+自定义cert+3478，无论是否开启客户端校验，报错"not connected to home DERP region"

3. docker部署，无论https端口是否自定义，无论是否开启客户端校验，报错"not connected to home DERP region" 

```
cat docker-compose.yml
version: '3.5'
services:
  derper:
    container_name: derper
    image: fredliang/derper
    restart: always
    volumes:
      - ./cert:/cert
      - /var/run/tailscale/tailscaled.sock:/var/run/tailscale/tailscaled.sock
      - /etc/localtime:/etc/localtime
    ports:
      - 3478:3478/udp
      - 443:443
    //network_mode: "host"
    environment:
      DERP_DOMAIN: derp.domain.com
      DERP_ADDR: ":443"
      DERP_CERT_MODE: manual
      DERP_CERT_DIR: /cert
      DERP_VERIFY_CLIENTS: "true"
```




