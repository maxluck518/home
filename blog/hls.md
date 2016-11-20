<!--
   - 文章结构：
   -     1. hls 原理 && verilog的关系
   -     2. hls 预编译指令以及优化方向
   -     3. hls 支持库的使用
   -            shift-regeister.h
   -            ap_int.h
   -            hls_stream.h
   -     4. hls 实例分析
   -         shift register
   -         xapp1209
   -     5. hls 开发的特色
   -         c simulation
   -         流水线设计
   -         所写模块有着明确的时钟约束
   -     6. 关注的核心点
   -         存储器的操作
   -    
   -         将cpu部分核心功能下方到fpga进行加速
   -            cpu和FPGA间的数据流动是通过dma来实现的
   -            考虑通过设置状态字来决定是某一模块是走cpu路线还是fpga路线
   -         作为sdnet的user模块协同进行数据平面的编程
   -            合理利用tuple
   -->

   ### 1. hls 原理 && verilog的关系
   
   #### 高层综合过程
        * Scheduling
        * Binding
        * Control logic extraction

![image](/home/mjw/Desktop/hls/pictures/hls_basis.PNG)


#### hls 开发模式的特点

         给定确定的目标对计算进行加速处理
         适合做数据处理，不适合做控制
            无法像verilog一样方便地操作控制信号(fifo,axi-stream)
         设计流水线比较直观方便(控制流水线的interval)

#### hls 优化的目标
        实现：
            最优并行化调度
            最优流水线实现

#### hls与verilog之间的联系
    dataflow:
        每个hls的函数都可以看做是verilog编写的一个功能模块
        hls函数的顶层函数就相当于verilog编写的顶层设计
        hls中每个函数之间的数据流动都是基于fifo来实现的，带来了部分资源浪费
    pipeline:
        局部流水：hls同样可以设计复杂的状态机
        全局流水：明显提高吞吐量


### 2. hls 预编译指令介绍

#### 预编译指令的作用
    由于hls实质上是语言的开发,c语言的顺序执行的特点与fpga的并行化处理原则相悖，预编译指令相当于是对hls程序的并行化的指导，地位类似于编译优化

#### 常用的预编译指令
    1. Dataflow 
        允许并发代码块,以消耗资源为代价，不同模块间的衔接需要存储器缓冲区或者fifo
    2. pipeline
        II的设置,流水线的间隔
        气泡的处理
    3. 数组和循环的处理
        array partation && unrool
        双端口存储器
    4. inline
        允许跨越函数层次进行优化


