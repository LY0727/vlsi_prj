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
	end
	always #5 clk = ~clk;
	
	always @(negedge clk)
		if (MemWrite)
			if ((DataAdr === 100) & (WriteData === 25)) begin
				$display("Simulation succeeded");
				$stop;
			end
			else if (DataAdr !== 96) begin
				$display("Simulation failed");
				$stop;
			end
endmodule