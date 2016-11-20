### git 使用帮助

####    设置代理

```

    My ubuntu server was blocked to git clone some github repo,

    Do as @itolfh said,

        git config --global http.proxy 'socks5://127.0.0.1:1080'

        git config --global https.proxy 'socks5://127.0.0.1:1080'

    my git works!

```
####    子模块已经被管理

```

因为在其他的themes下已经被git管理了,我rm -rf .git 移除了其他themes下的.git和根目录下的.git 然后git init什么的重做了次就成功过了 

```
