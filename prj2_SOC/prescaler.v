module prescaler(
  input wire inclk,
  input wire HRESETn,
  output reg outclk
    );

reg [3:0] counter;

always @(posedge inclk, negedge HRESETn)
begin
  if (!HRESETn)
    begin
      outclk <= 0;
      counter <= 0;
    end 
  else if(counter==4'b1111)
    outclk<=~outclk;
  else
    counter <= counter + 1'b1;
end
endmodule
