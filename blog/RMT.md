### Key note of RMT

```

Paper:Forwarding Metamorphosis: Fast Programmable Match-Action Processing in
Hardware for SDN

```

#### 1. basic idea of RMT

```

    First, field definitions can be altered and new fields added;

    second, the number, topology, widths, and depths of match tables can be
    specified, subject only to an overall resource limit on the number of
    matched bits;

    third, new actions may be defined, such as writing new congestion fields;

    fourth, arbitrarily modified packets can be placed in specified queue(s),
    for output at any subset of ports, with a queuing discipline specified for
    each queue.  

``` 
#### 2. RMT Architecture 

    1. VLIW : very long instruction word.  for reconfigration of the parser
       and lookup table
    2. Add action field in each table.  Tell the lookup engine what to do.
    3. Add control field in each table.  Tell the lookup engine what to do
       next!
    4. A reconbination block in the end of the pipeline.
        
        A packet’s fate is controlled by updating a set of destination ports
        and queues; this can be used to drop a packet, implement multicast, or
        apply specified QoS such as a token bucket.

    Conclusion: Able to:
        1. add new field
        2. add new action
        3. add new action engine Restriction:
        1. fixed num. of physical stage
        2. pakect header is limited
        3. the size of each match stage is identical
        4. excute one instruction per field

#### 3. chip design

##### 3.1 Configurable Parser 
    
        Paring is directed by a user-supplied parse graph,and the configurable
        infor is stored in the TCAM(seprate from the lookup table) eg: in the
        paper,the TCAM is set by 256x40b,whitch contains 32b of incoming data
        and 8b of parser state.
        
        Notice:The method in this paper create a mechanism of looping
        parser,whitch include the pipline in the parser.

    如何确定数据包包头是片面的协议无关，parser的reconfigurion是基于查表实现的
    ，需要事先定义好parser action list

##### 3.2 Configurable Match Memories

    **  Similar to the paper of Gong's  **
    1. Physical match stage may not bind with the phsical match table.  
    eg: stage can carry a LPM tbl and a TCM tbl independently on the chip.
    2. Inside the table,Gong's method is reasonable to split the field block
       and reshape them for restoring resources.

##### 3.3 Configurable action engine
    1. A separate processing unit is provided for each packet header field
       (see Figure 1c), so that all may be modified concurrently.
    2. Store the action list in the SRAM.Once the action set from the lookup
       engine matches 1 of the entry in the SRAM,the micro controller can
       create the ctrl info to modify the status of the all action Unit.
       (just like ALU && micro controller)

##### 4. Evaluation

##### 5. tips 
    1. The system contains 2 action SRAM logically,1 for config the parser and
       1 for config the action Units.
    2. Each stage contains 2 steps,match tables and VLIW action.
