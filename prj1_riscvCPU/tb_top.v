`timescale 1ns / 1ps



module testbench;
	reg clk;
	reg reset;
	wire [31:0] WriteData;
	wire [31:0] DataAdr;
	wire MemWrite;
	top dut(
		.clk(clk),
		.reset(reset),
		.WriteData(WriteData),
		.DataAdr(DataAdr),
		.MemWrite(MemWrite)
	);
	initial begin
		clk <= 1;
		reset <= 1;
		#22
		reset <= 0;


        #200;
        $finish;
	end
	always #5 clk = ~clk;
	
	always @(negedge clk)
		if (MemWrite)
		//	if ((DataAdr === 100) & (WriteData === 25)) begin
			if ((DataAdr === 104) & (WriteData === 25)) begin
				$display("Simulation succeeded");
				$stop;
			end
		//	else if (DataAdr !== 96) begin
			else if (DataAdr !== 100) begin
				$display("Simulation failed");
				$stop;
			end

initial
begin            
	$dumpfile("wave.vcd");        //生成的vcd文件名称
	$dumpvars(0, testbench);    //tb模块名称
end
endmodule