# vlsi_prj

西安交通大学微电子学院，超大规模集成电路设计，课程大作业，共三小题。

仿真验证环境为：iverilog + gtkwave

```
sudo apt-get install iverilog
sudo apt-get install gtkwave
```

## prj1

仿真有三个.txt作为机器码输入； 在top.v文件中 启用对应宏定义；  直接make。

```
make iverilog
```

## prj2

**简介：**

1. hex_s_code/  ： 在keil工具中编写编译得到的程序代码，主要使用hex文件载入 AHB2MEM.v 中进行仿真。
2. test/  ：仿真相关，要求4个小项，config.vh中启用相关的宏，直接make。   如果在vivado中建立工程进行仿真，需要启用宏定义 VIVADO。   TIMER和UART的好像有点问题，时间太长了，可能复制的文件有错误，暂时没时间看。

   ```
   cd test/
   make iverilog
   ```

## prj3

直接make

```
make iverilog
```
