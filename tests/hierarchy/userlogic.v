`include "syrup.v"

module userlogic
  (
   input CLK,
   input RST,
   output [7:0] LED
   );

  wire [31:0] sum;
  assign LED = ~sum[7:0];
  
  sub #
    (
     .W_A(20)
     )
  inst_sub
    (
     .CLK(CLK),
     .RST(RST),
     .sum(sum)
     );
  
endmodule

module sub #
  (
   parameter W_A = 20
   )
  (
   input CLK,
   input RST,
   output reg [31:0] sum
   );

  reg [W_A-1:0] addr;
  reg ren, d_ren;
  wire [31:0] data_out;

  always @(posedge CLK) begin
    if(RST) begin
      addr <= 0;
      ren <= 0;
      d_ren <= 0;
      sum <= 0;
    end else begin
      addr <= addr + 4;
      ren <= 1;
      d_ren <= ren;
      if(d_ren) sum <= sum + data_out;
    end
  end
  
  SyrupMemory1P #
    (
     .DOMAIN("domain"),
     .ID(0),
     .ADDR_WIDTH(W_A),
     .DATA_WIDTH(32),
     .WAY(1),
     .LINEWIDTH(128),
     .BYTE_ENABLE(0)
     )
  inst_mem0
    (
     .CLK(CLK),
     .ADDR(addr),
     .D(0),
     .WE(1'b0),
     .Q(data_out),
     .RE(ren),
     .BE()
     );

  SyrupOutChannel #
    (
     .DOMAIN("domain"),
     .ID(0),
     .DATA_WIDTH(32)
     )
  inst_outchannel
    (
     .CLK(CLK),
     .D(sum),
     .WE(1'b1)
     );
  
endmodule
