`timescale 1ns / 1ps

`define xortest
// `define luitest



module top (
	input  wire clk,
	input  wire reset,
	output wire [31:0] WriteData,
	output wire [31:0] DataAdr,
	output wire MemWrite
);

	wire [31:0] PC;
	wire [31:0] Instr;
	wire [31:0] ReadData;

	riscvsingle rvsingle(
		.clk(clk),
		.reset(reset),
		.PC(PC),
		.Instr(Instr),
		.MemWrite(MemWrite),
		.ALUResult(DataAdr),
		.WriteData(WriteData),
		.ReadData(ReadData)
	);

	imem imem(
		.a(PC),
		.rd(Instr)
	);

	dmem dmem(
		.clk(clk),
		.we(MemWrite),
		.a(DataAdr),
		.wd(WriteData),
		.rd(ReadData)
	);
endmodule

module riscvsingle (
	input wire clk,
	input wire reset,
	output wire [31:0] PC,
	input wire [31:0] Instr,
	output wire MemWrite,
	output wire [31:0] ALUResult,
	output wire [31:0] WriteData,
	input wire [31:0] ReadData
);

	wire ALUSrc;
	wire RegWrite;
	wire Jump;
	wire Zero;
	wire [1:0] ResultSrc;
	wire [2:0] ImmSrc;
	wire [2:0] ALUControl;
	wire PCSrc;

	controller c(
		.op(Instr[6:0]),
		.funct3(Instr[14:12]),
		.funct7b5(Instr[30]),
		.Zero(Zero),
		.ResultSrc(ResultSrc),
		.MemWrite(MemWrite),
		.PCSrc(PCSrc),
		.ALUSrc(ALUSrc),
		.RegWrite(RegWrite),
		.Jump(Jump),
		.ImmSrc(ImmSrc),
		.ALUControl(ALUControl)
	);

	datapath dp(
		.clk(clk),
		.reset(reset),
		.ResultSrc(ResultSrc),
		.PCSrc(PCSrc),
		.ALUSrc(ALUSrc),
		.RegWrite(RegWrite),
		.ImmSrc(ImmSrc),
		.ALUControl(ALUControl),
		.Zero(Zero),
		.PC(PC),
		.Instr(Instr),
		.ALUResult(ALUResult),
		.WriteData(WriteData),
		.ReadData(ReadData)
	);
endmodule

module controller (
	input wire [6:0] op,
	input wire [2:0] funct3,
	input wire funct7b5,
	input wire Zero,
	output wire [1:0] ResultSrc,
	output wire MemWrite,
	output wire PCSrc,
	output wire ALUSrc,
	output wire RegWrite,
	output wire Jump,
	output wire [2:0] ImmSrc,
	output wire [2:0] ALUControl
);

	wire [1:0] ALUOp;
	wire Branch;

	maindec md(
		.op(op),
		.ResultSrc(ResultSrc),
		.MemWrite(MemWrite),
		.Branch(Branch),
		.ALUSrc(ALUSrc),
		.RegWrite(RegWrite),
		.Jump(Jump),
		.ImmSrc(ImmSrc),
		.ALUOp(ALUOp)
	);

	aludec ad(
		.opb5(op[5]),
		.funct3(funct3),
		.funct7b5(funct7b5),
		.ALUOp(ALUOp),
		.ALUControl(ALUControl)
	);

	assign PCSrc = (Branch & Zero) | Jump;
endmodule

module maindec (
	input wire [6:0] op,
	output wire [1:0] ResultSrc,
	output wire MemWrite,
	output wire Branch,
	output wire ALUSrc,
	output wire RegWrite,
	output wire Jump,
	output wire [2:0] ImmSrc,
	output wire [1:0] ALUOp
);

	reg [11:0] controls;
	assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;
	always @(*)
		case (op)
			7'b0000011: controls = 12'b100010010000;//lw
			7'b0100011: controls = 12'b001011000000;//sw
			7'b0110011: controls = 12'b1xxx00000100;//R-Type
			7'b1100011: controls = 12'b010000001010;//beq
			7'b0010011: controls = 12'b100010000100;//I-Type----ALUSrc=1?
			7'b1101111: controls = 12'b111000100001;//jal-------ResultSrc=10?
			7'b0110111: controls = 12'b111100110000;//lui-------------------------------------------------------------------------------
			default: controls = 11'bxxxxxxxxxxx;
		endcase
endmodule

module aludec (
	input wire opb5,
	input wire [2:0] funct3,
	input wire funct7b5,
	input wire [1:0] ALUOp,
	output reg [2:0] ALUControl
);

	wire RtypeSub;
	assign RtypeSub = funct7b5 & opb5;
	always @(*)
		case (ALUOp)
			2'b00: ALUControl = 3'b000;
			2'b01: ALUControl = 3'b001;
			default:
				case (funct3)
					3'b000:
						if (RtypeSub)
							ALUControl = 3'b001;
						else
							ALUControl = 3'b000;
					3'b010: ALUControl = 3'b101;
					3'b110: ALUControl = 3'b011;
					3'b111: ALUControl = 3'b010;
					3'b100: ALUControl = 3'b100;// ALUOp add funct3 == 100-------------------------------------------------------------
					default: ALUControl = 3'bxxx;
				endcase
		endcase
endmodule

module datapath (
	input wire clk,
	input wire reset,
	input wire [1:0] ResultSrc,
	input wire PCSrc,
	input wire ALUSrc,
	input wire RegWrite,
	input wire [2:0] ImmSrc,
	input wire [2:0] ALUControl,
	output wire Zero,
	output wire [31:0] PC,
	input wire [31:0] Instr,
	output wire [31:0] ALUResult,
	output wire [31:0] WriteData,
	input wire [31:0] ReadData
);
	
	wire [31:0] PCNext;
	wire [31:0] PCPlus4;
	wire [31:0] PCTarget;
	wire [31:0] ImmExt;
	wire [31:0] SrcA;
	wire [31:0] SrcB;
	wire [31:0] Result;

	flopr #(.WIDTH(32)) pcreg(
		.clk(clk),
		.reset(reset),
		.d(PCNext),
		.q(PC)
	);

	adder pcadd4(
		.a(PC),
		.b(32'd4),
		.y(PCPlus4)
	);

	adder pcaddbranch(
		.a(PC),
		.b(ImmExt),
		.y(PCTarget)
	);

	mux2 #(.WIDTH(32)) pcmux(
		.d0(PCPlus4),
		.d1(PCTarget),
		.s(PCSrc),
		.y(PCNext)
	);

	regfile rf(
		.clk(clk),
		.we3(RegWrite),
		.a1(Instr[19:15]),
		.a2(Instr[24:20]),
		.a3(Instr[11:7]),
		.wd3(Result),
		.rd1(SrcA),
		.rd2(WriteData)
	);

	extend ext(
		.instr(Instr[31:7]),
		.immsrc(ImmSrc),
		.immext(ImmExt)
	);

	mux2 #(.WIDTH(32)) srcbmux(
		.d0(WriteData),
		.d1(ImmExt),
		.s(ALUSrc),
		.y(SrcB)
	);

	alu alu(
		.a(SrcA),
		.b(SrcB),
		.alucontrol(ALUControl),
		.result(ALUResult),
		.zero(Zero)
	);

	mux3 #(.WIDTH(32)) resultmux(
		.d0(ALUResult),
		.d1(ReadData),
		.d2(PCPlus4),
		.d3(ImmExt),// output mux add "11" == immext-------------------------------------------------------------------------------------
		.s(ResultSrc),
		.y(Result)
	);
endmodule

module regfile (
	input wire clk,
	input wire we3,
	input wire [4:0] a1,
	input wire [4:0] a2,
	input wire [4:0] a3,
	input wire [31:0] wd3,
	output wire [31:0] rd1,
	output wire [31:0] rd2
);

	reg [31:0] rf [31:0];

	always @(posedge clk)
		if (we3)
			rf[a3] <= wd3;
	assign rd1 = (a1 != 0 ? rf[a1] : 0);
	assign rd2 = (a2 != 0 ? rf[a2] : 0);
endmodule

module adder (
	input [31:0] a,
	input [31:0] b,
	output wire [31:0] y
);

	assign y = a + b;
endmodule

module extend (
	input wire [31:7] instr,
	input wire [2:0] immsrc,
	output reg [31:0] immext
);

	always @(*)
		case (immsrc)
			3'b000: immext = {{20 {instr[31]}}, instr[31:20]};
			3'b010: immext = {{20 {instr[31]}}, instr[31:25], instr[11:7]};
			3'b100: immext = {{20 {instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
			3'b110: immext = {{12 {instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
			3'b111: immext = {instr[31:12], 12'b0};// add code "111" == lui------------------------------------------------------------
			default: immext = 32'bx;
		endcase
endmodule

module flopr (
	input wire clk,
	input wire reset,
	input wire [WIDTH - 1:0] d,
	output reg [WIDTH - 1:0] q
);
	parameter WIDTH = 8;

	always @(posedge clk or posedge reset)
		if (reset)
			q <= 0;
		else
			q <= d;
endmodule

module mux2 (

	input wire [WIDTH - 1:0] d0,
	input wire [WIDTH - 1:0] d1,
	input wire s,
	output wire [WIDTH - 1:0] y
);
	parameter WIDTH = 8;
	assign y = (s ? d1 : d0);
endmodule

module mux3 (
	input wire [WIDTH - 1:0] d0,
	input wire [WIDTH - 1:0] d1,
	input wire [WIDTH - 1:0] d2,
	input wire [WIDTH - 1:0] d3,//add d3-------------------------------------------------------------------------------------------------
	input wire [1:0] s,
	output wire [WIDTH - 1:0] y
);
	parameter WIDTH = 8;

	assign y = (s[1] ? (s[0] ? d3:d2) : (s[0] ? d1:d0));//四项判断-----------------------------------------------------------------------
endmodule

module imem (
	input wire [31:0] a,
	output wire [31:0] rd
);

	reg [31:0] RAM [63:0];

`ifdef xortest
	initial $readmemh("/mnt/ssd2/lao/vlsi_prj/prj1_riscvCPU/xortest.txt", RAM);
`elsif luitest
	initial $readmemh("/mnt/ssd2/lao/vlsi_prj/prj1_riscvCPU/luitest.txt", RAM);
`else 
	initial $readmemh("/mnt/ssd2/lao/vlsi_prj/prj1_riscvCPU/riscvtest.txt", RAM);
`endif
	assign rd = RAM[a[31:2]];
endmodule

module dmem (
	input wire clk,
	input wire we,
	input wire [31:0] a,
	input wire [31:0] wd,
	output wire [31:0] rd
);

	reg [31:0] RAM [63:0];
	assign rd = RAM[a[31:2]];
	always @(posedge clk)
		if (we)
			RAM[a[31:2]] <= wd;
endmodule

module alu (
	input wire [31:0] a,
	input wire [31:0] b,
	input wire [2:0] alucontrol,
	output reg [31:0] result,
	output wire zero
);

	wire [31:0] condinvb;
	wire [31:0] sum;
	wire v;
	wire isAddSub;
	assign condinvb = (alucontrol[0] ? ~b : b);
	assign sum = (a + condinvb) + alucontrol[0];
	assign isAddSub = (~alucontrol[2] & ~alucontrol[1]) | (~alucontrol[1] & alucontrol[0]);
	always @(*)
		case (alucontrol)
			3'b000: result = sum;
			3'b001: result = sum;
			3'b010: result = a & b;
			3'b011: result = a | b;
			3'b100: result = a ^ b;
			3'b101: result = sum[31] ^ v;
			3'b110: result = a << b[4:0];
			3'b111: result = a >> b[4:0];
			default: result = 32'bx;
		endcase
	assign zero = result == 32'b0;
	assign v = (~((alucontrol[0] ^ a[31]) ^ b[31]) & (a[31] ^ sum[31])) & isAddSub;
endmodule
