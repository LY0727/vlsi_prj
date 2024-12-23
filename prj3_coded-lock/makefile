iverilog:
	iverilog -o  tb_lock tb_lock.v  lock.v 
	vvp tb_lock
	gtkwave wave.vcd

iverilog-vscode:
	iverilog -o  tb_lock tb_lock.v  lock.v 
	vvp tb_lock
#	gtkwave wave.vcd

clean:
	rm -rf obj_dir tb_lock *.vcd