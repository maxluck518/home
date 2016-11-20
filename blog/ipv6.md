### ubuntu 校园网pppoe方式开启ipv6

####    1.问题描述

```
~$ifconfig

ppp0Linkencap:点对点协议

inet地址:10.170.54.27点对点:10.170.72.254掩码:255.255.255.255

inet6地址:fe80::956d:3bb8:a317:3b0b/10Scope:Link

inet6地址:2001:250:1006:dff0:956d:3bb8:a317:3b0b/64Scope:Global

inet6地址:2001:250:1006:dff0:1900:bda1:842c:718d/64Scope:Global

UPPOINTOPOINTRUNNINGNOARPMULTICASTMTU:1492跃点数:1

发现这里有两个ipv6的地址：

我的理解是，一方面，学校给我们动态的分配地址，每次拨号登陆后都会得到一个不一样的新的ipv6地址，而另一方面，ubuntu使用临时地址，这个临时地址不会立刻改变，可能一天或一周后才会改变；这时候ubuntu就不能正确得到学校分配的地址，那么我们也就不能正常使用ipv6上网了。

```
####    2.解决方案

```
    1. modify /etc/sysctl.d/10-ipv6-privacy.conf,将net.ipv6.conf.default.use_tempaddr改为0
    2. 其余过程：
        ~$sudosysctl--system#加载所有的配置文件
        重新拨号连接校园网
    3. 结果
    这时候查看网络信息：

    ~$ifconfig

    ppp0Linkencap:点对点协议

    inet地址:10.170.12.59点对点:10.170.72.254掩码:255.255.255.255

    inet6地址:fe80::a923:8a75:4dc9:ead1/10Scope:Link

    inet6地址:2001:250:1006:dff0:a923:8a75:4dc9:ead1/64Scope:Global

    UPPOINTOPOINTRUNNINGNOARPMULTICASTMTU:1492跃点数:1

    接收数据包:2396错误:0丢弃:0过载:0帧数:0

    发送数据包:2362错误:0丢弃:0过载:0载波:0

    碰撞:0发送队列长度:3

    接收字节:2164847(2.1MB)发送字节:326909(326.9KB)

    这时候会发现只有一个Global地址，设置完成。

```


### 禁用ipv6

```

修改 /etc/sysctl.conf 文件
添加
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv6.conf.eth0.disable_ipv6 = 1
如果是 OpenVZ 环境，请把最后一条的 eth0 改成 venet0 ，同理如果网卡是 eth1 或者其他的名字，也要相应修改。
然后运行
sudo sysctl -p
接着就可以用 ifconfig 或 ip a 命令看看是否已经没有 IPv6 地址了。

```
