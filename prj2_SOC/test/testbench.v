`include "config.vh"
module testbench;

  // Inputs
  reg CLK;
  reg RESET;
  reg rx;

  // Outputs
  wire [7:0] LED;
  wire [6:0] seg;
  wire [7:0] an;
  wire dp;
  wire tx;

  // Instantiate the Unit Under Test (UUT)
  AHBLITE_SYS uut (
    .CLK(CLK), 
    .RESET(RESET), 
    .rx(rx), 
    .LED(LED), 
    .seg(seg), 
    .an(an), 
    .dp(dp), 
    .tx(tx)
  );

  initial begin
    // Initialize Inputs
    CLK = 0;
    RESET = 1;
    rx = 0;

    // Wait 100 ns for global reset to finish
    #100;
    RESET = 0;

    // Add stimulus here
    #6000;
    $finish;
  end
  
  // Clock generation
  always #10 CLK = ~CLK;
  
  initial
  begin  
    `ifdef M0_LED
        $dumpfile("M0_LED_wave.vcd");        //生成的vcd文件名称
    `elsif M0_SEG7
        $dumpfile("M0_SEG7_wave.vcd");        //生成的vcd文件名称
    `elsif M0_TIMER
        $dumpfile("M0_TIMER_wave.vcd");        //生成的vcd文件名称
    `elsif M0_UART
        $dumpfile("M0_UART_wave.vcd");        //生成的vcd文件名称
    `else 
        $dumpfile("wave.vcd");        //生成的vcd文件名称
    `endif          
      $dumpvars(0, testbench);    //tb模块名称
  end
endmodule