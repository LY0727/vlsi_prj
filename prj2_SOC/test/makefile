# 定义路径变量
SRC_DIR = /mnt/ssd2/lao/vlsi_prj/prj2_SOC
TEST_DIR = $(SRC_DIR)/test
HEX_DIR = $(SRC_DIR)/hex_s_code

iverilog:
	iverilog  -Wall -o  M0_soc  $(TEST_DIR)/testbench.v  $(SRC_DIR)/*.v
	vvp M0_soc

clean:
	rm -rf obj_dir M0_soc *.vcd