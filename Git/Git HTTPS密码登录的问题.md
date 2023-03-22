# Git HTTPS密码登录的问题
- 现象：  
  Git地址配置的是https，修改密码后总是提示"fatal: could not read Username for 'https://gitlabcode.xx.com.cn': No such device or address"，手动输入用户名和密码可以正常登录  
- 尝试的解决办法：  
  `git config --global credential.helper store `配置存储校验信息，这个操作在普通用户和root下面都做了，无效。  
- 最终解决办法：  
  直接在URL配置用户名和密码`remote.origin.url=https://user:passwd@gitlabcode.xx.com.cn/xx.git`，密码的特殊字符可能需要转义
