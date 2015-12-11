`include "syrup.v"

module userlogic #
  (
   parameter LED_WIDTH = 8,
   parameter W_A = 24,
   parameter W_D = 32
   )
  (
   input CLK,
   input RST,
   output [LED_WIDTH-1:0] LED
   );

  reg [W_A-1:0] addr;
  reg [W_D-1:0] data_in;
  reg wen;
  reg ren;
  wire [W_D-1:0] data_out;

  assign LED = data_out[LED_WIDTH-1:0];
  
  always @(posedge CLK) begin
    if(RST) begin
      addr <= 0;
      wen <= 0;
      ren <= 0;
      data_in <= 0;
    end else begin
      addr <= addr + 4;
      ren <= 1;
    end
  end
  
  SyrupMemory1P #
    (
     .DOMAIN("domain"),
     .ID(0),
     .ADDR_WIDTH(W_A),
     .DATA_WIDTH(W_D),
     .WAY(1),
     .LINEWIDTH(128),
     .BYTE_ENABLE(0)
     )
  inst_mem0
    (
     .CLK(CLK),
     .ADDR(addr),
     .D(data_in),
     .WE(wen),
     .Q(data_out),
     .RE(ren),
     .BE()
     );
  
endmodule
