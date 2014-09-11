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

  reg [W_A-1:0] addr0;
  reg [W_D-1:0] data_in0;
  reg wen0;
  reg ren0;
  wire [W_D-1:0] data_out0;
  reg [W_A-1:0] addr1;
  reg [W_D-1:0] data_in1;
  reg wen1;
  reg ren1;
  wire [W_D-1:0] data_out1;

  assign LED = data_out0[LED_WIDTH-1:0];
  
  always @(posedge CLK) begin
    if(RST) begin
      addr0 <= 0;
      wen0 <= 0;
      ren0 <= 0;
      data_in0 <= 0;
      addr1 <= 0;
      wen1 <= 0;
      ren1 <= 0;
      data_in1 <= 0;
    end else begin
      addr0 <= addr0 + 4;
      addr1 <= addr0 + 4;
      data_in1 <= data_in1 + 1;
      ren0 <= 1;
      wen1 <= 1;
    end
  end
  
  SyrupMemory2P #
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
     .ADDR0(addr0),
     .D0(data_in0),
     .WE0(wen0),
     .Q0(data_out0),
     .RE0(ren0),
     .BE0(),
     .ADDR1(addr1),
     .D1(data_in1),
     .WE1(wen1),
     .Q1(data_out1),
     .RE1(ren1),
     .BE1()
     );
  
endmodule
