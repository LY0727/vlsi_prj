
iverilog:
	iverilog  -Wall -o  top  tb_top.v  top.v 
	vvp top
	gtkwave wave.vcd

iverilog-vscode:
	iverilog  -Wall -o  top  tb_top.v  top.v 
	vvp top
#	gtkwave wave.vcd

clean:
	rm -rf obj_dir top *.vcd