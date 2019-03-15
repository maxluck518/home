## dpdk-pktgen 环境搭建

### verison

- dpdk：      17.5.1


- pktgen：    3.4.0

### steps

- BIOS以及NIC支持
- hugepage的配置
- Get code
- 修改cfg配置文件

#### 1.  BIOS 以及NIC支持

查看HUGE TLB功能是否开启

```
$ grep -i huge /boot/config-4.10.0-33-generic
```

![](http://op43wyuhf.bkt.clouddn.com/17-9-4/25144174.jpg)
查看hugepage分配信息

```
$ grep -i huge /proc/meminfo
```

![](http://op43wyuhf.bkt.clouddn.com/17-9-4/97912776.jpg)

#### 2.  hugepage的配置

You will need to edit the `/etc/sysctl.conf` file to setup the hugepages size:

```
$ sudo vi /etc/sysctl.conf
```

Add to the bottom of the file:

```
vm.nr_hugepages=256
```

You will also need to edit the `/etc/fstab` file to mount the hugepages at startup:

```
$ sudo vi /etc/fstab
```

Add to the bottom of the file

```
huge /mnt/huge hugetlbfs defaults 0 0
```

Then create the folder to be mounted on:

```
$ sudo mkdir /mnt/huge
$ sudo chmod 777 /mnt/huge
```

#### 3.  Build DPDK and Pktgen

Set up the environmental variables required by DPDK:

```
export RTE_SDK=<DPDKInstallDir>
export RTE_TARGET=x86_64-native-linuxapp-gcc

# or use clang if you have it installed:
export RTE_TARGET=x86_64-native-linuxapp-clang
```

Create the DPDK build tree:

```
$ cd $RTE_SDK
$ make install T=x86_64-native-linuxapp-gcc
```

Pktgen can then be built as follows:

```
$ cd <PktgenInstallDir>
$ make
```

#### 4.  修改cfg配置文件

查看网卡port信息：

```
$ lspci | grep Ethernet
```

![](http://op43wyuhf.bkt.clouddn.com/17-9-4/95667550.jpg)

为了运行pktgen app：

```
$ cd <PktgenInstallDir>/tools
$ ls
```

目前版本中，setup和run由dpdk-run.py分两步实现，\
setup 阶段：

```
$ ./dpdk-run.py -s -v default  # setup system using the cfg/default.cfg file
```

run 阶段：

```
$ ./run.py default
```

cfg示例：

```
description = 'A Pktgen default simple configuration'

# Setup configuration
setup = {
    'exec': (
        'sudo',
        '-E'
        ),

	'devices': (
		'04:00.0 04:00.1'
		),
		
	'opts': (
		'-b igb_uio'
		)
	}

# Run command and options
run = {
    'exec': (
        'sudo',
        '-E'
        ),

    # Application name and use app_path to help locate the app
    'app_name': 'pktgen',
    'target': 'x86_64-native-linuxapp-gcc',


    # using (sdk) or (target) for specific variables
    # add (app_name) of the application
    # Each path is tested for the application
    'app_path': (
        './app/%(target)s/%(app_name)s',
        '%(sdk)s/%(target)s/app/%(app_name)s',
        '../app/%(target)s/%(app_name)s',
        ),

	'dpdk': (
		'-c 0xf',
		'-n 4',
		'-m 512',  # must be 256??
		'--proc-type auto',
		'--log-level 7',
		# '--socket-mem 64',
		'--file-prefix pg'
		),
	
	'blacklist': (
        '-b 00:19.0',
		# '-b 04:00.0 -b 04:00.1',
		),
		
	'app': (
		'-T',
		'-P',
		'--crc-strip',
		'-m [1:3].0',
		'-m [2:4].1',
		),
	
	'misc': (
		'-f',
		'themes/black-yellow.theme'
		)
	}
```

其中: 

-  00:19.0被加入blacklist，不被pktgen使用；

-  00:04.0和00:04.1为2个10g网口，被pkt调用；

  详细参数信息参考:	[EAL Commandline Options](http://pktgen-dpdk.readthedocs.io/en/latest/usage_eal.html)

  ​

