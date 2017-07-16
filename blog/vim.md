<! --
   - The structure of this passage:
   -     1.vim基本操作
   -     2.搜索与正则表达式
   -     3.插件
   -     4.黑科技
   -->

#  *vim使用手册*

## vim basic operation
        
#### 翻页操作

1.   向下翻页 ctrl + f，向上翻页 ctrl + b
2.   向下翻半页 ctrl + d，向上翻半页 ctrl + u

#### 移动操作

1.  移动到词尾 e
2.  移动到行尾 $，移动到行首 0
3.  移动光标到屏幕顶端H，到中间 M，到尾部 L
4.  回到之前所在位置 ctrl + 

#### 插入操作
1.  a,o,i : 
2.  c,d,r : c直接进插入模式,d纯删除,r不进入插入模式修改1个字符

#### 撤销操作

1.  u撤销
2.  ctrl + r反撤销

#### 多行编辑

1. ctrl + v
2. 跳到目的行 (jjj 或者 <C-d> 或者 /patternor%等等…)
3. $跳到行末尾,0跳到行首
4. 写入一些文本，[按] ESC 键

#### 定位删除/更改(比如删除括号里的内容)

1. caw  :  删除包括范围符在内的内容 
2. ciw  :  删除不包括范围符在内的内容 

### 数字自增自减

1.  ctrl + a:   数字自增1
2.  ctrl + x:   数字自减1

3.  num + ctrl + a: 数字自增num
4.  num + ctrl + x: 数字自减num

#### 其他小操作

1.  xp: 交换2个字符的位置

## 搜索与正则表达式

####    全局替换

    :%s old/new/g

####    高亮搜索
*   `*`  : 读取当前pattern，并移动到本屏幕内下一次出现的地方
*   `#`  : 读取当前pattern，并移动到本屏幕内上一次出现的地方
*   `gd` : 读取当前pattern，并移动到文件首次出现该pattern的地方

####    转义操作符 \
*   将 `/a/b/c`    替换为 `/abc`

    
    :s/\/a\/b\/c\/abc/

####    :g命令   `:g/pattern/cmd` 
`:g`命令表示在文中查找`pattern`，然后对找到的这些行执行`cmd`命令
* 注：`cmd`应用的范围是找到行

*   在文中查找包含`test`的行，并且把该行中的`aaa`替换成`bbb`,也可以把`aaa`省略

    :g/test/s/aaa/bbb/ 

*   在文中查找包含`test`的行，把`test`替换成`bbb`指令


    :g/test/s//bbb/

## 4.黑科技
####    使用vim比较两个文件的异同
*   启动diff功能：\
    如果已经打开了文件file1，再打开另一个文件file2进行比较：


    :vert diffsplit file2
![](http://op43wyuhf.bkt.clouddn.com/17-7-16/84069944.jpg)
*   定位到不同点 \
    `[c` :  跳到前一个不同点 \
    `]c` :  跳到下一个不同点

####    vi查看二进制文件
*   打开文件

        vim -b file
*   命令模式下输入

        %!xxd
![](http://op43wyuhf.bkt.clouddn.com/17-7-16/26465744.jpg)
####    vim python2,3切换
*   安装`vim-gtk3`和`vim-gtk3-py2`后，在终端下输入

        sudo update-alternatives --config vim
