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

  reg [W_D-1:0] data_in;
  reg wen;
  reg ren;
  wire [W_D-1:0] data_out;

  assign LED = data_out[LED_WIDTH-1:0];
  
  always @(posedge CLK) begin
    if(RST) begin
      data_in <= 0;
      wen <= 0;
      ren <= 0;
    end else begin
      data_in <= data_in + 1;
      wen <= 1;
      ren <= 1;
    end
  end
  
  SyrupOutChannel #
    (
     .DOMAIN("domain"),
     .ID(0),
     .DATA_WIDTH(W_D)
     )
  inst_outchannel
    (
     .CLK(CLK),
     .D(data_in),
     .WE(wen)
     );
  
  SyrupInChannel #
    (
     .DOMAIN("domain"),
     .ID(0),
     .DATA_WIDTH(W_D)
     )
  inst_inchannel
    (
     .CLK(CLK),
     .Q(data_out),
     .RE(ren)
     );
  
endmodule
