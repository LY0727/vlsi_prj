module AHBTOUCH(
	//AHBLITE INTERFACE
		//Slave Select Signals
			input wire HSEL,
		//Global Signal
			input wire HCLK,
			input wire HRESETn,
		//Address, Control & Write Data
			input wire HREADY,
			input wire [31:0] HADDR,
			input wire [1:0] HTRANS,
			input wire HWRITE,
			input wire [2:0] HSIZE,
			
			input wire [31:0] HWDATA,
			
		    input wire  touch_dout,
		// Transfer Response & Read Data
			output wire HREADYOUT,
			output wire [31:0] HRDATA,
		//touch TFT Output
			output reg tft_rs,
            output reg tft_rd,
            output reg tft_wr,
            output reg tft_rst,
            output reg tft_cs,
            output reg  [7:0] tft_db,
            output reg touch_dclk,
            output reg touch_cs,
            output reg touch_din
);

//Address Phase Sampling Registers
  reg rHSEL;
  reg [31:0] rHADDR;
  reg [1:0] rHTRANS;
  reg rHWRITE;
  reg [2:0] rHSIZE;
  
 //Address Phase Sampling
  always @(posedge HCLK or negedge HRESETn)
  begin
	 if(!HRESETn)
	 begin
		rHSEL   <= 1'b0;
		rHADDR	<= 32'h0;
		rHTRANS	<= 2'b00;
		rHWRITE	<= 1'b0;
		rHSIZE	<= 3'b000;
	 end
    else if(HREADY)
    begin
        rHSEL	<= HSEL;
		rHADDR	<= HADDR;
		rHTRANS	<= HTRANS;
		rHWRITE	<= HWRITE;
		rHSIZE	<= HSIZE;
    end
  end

//Data Phase data transfer
  always @(posedge HCLK or negedge HRESETn)
  begin
    if(!HRESETn)
      begin
           tft_db<=8'h00;
           tft_cs<=1'b1;
           tft_rs<=1'b1;
           tft_rd<=1'b1;
           tft_wr<=1'b1;
           tft_rst<=1'b1;
           touch_dclk<=1'b0;
           touch_cs<=1'b1;
           touch_din<=1'b0;
      end
    else if(rHSEL & rHWRITE & rHTRANS[1])
      if(rHADDR[7:0]==8'h00)         //data  signal
            tft_db<=HWDATA[7:0];
      else if(rHADDR[7:0]==8'h04)    //cs signal
            tft_cs<=HWDATA[0];
      else if(rHADDR[7:0]==8'h08)    //rs signal 
            tft_rs<=HWDATA[0];
      else if(rHADDR[7:0]==8'h0c)    //rd signal
            tft_rd<=HWDATA[0];
      else if(rHADDR[7:0]==8'h10)    //wr signal 
            tft_wr<=HWDATA[0];
      else if(rHADDR[7:0]==8'h14)    //rst signal
            tft_rst<=HWDATA[0];
      else if(rHADDR[7:0]==8'h18)   //touch clk signal
            touch_dclk<=HWDATA[0];   
      else if(rHADDR[7:0]==8'h1c)   //touch cs signal
            touch_cs<=HWDATA[0];
      else if(rHADDR[7:0]==8'h20)   //touch din signal
            touch_din<=HWDATA[0];
  end

//Transfer Response
  assign HREADYOUT = 1'b1; //Single cycle Write & Read. Zero Wait state operations

//Read Data  
assign HRDATA ={28'h0000000,3'b000,touch_dout};
 
endmodule