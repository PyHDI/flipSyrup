module ADDRMAP_{{ name }}
 (UP_ADDR, DOWN_ADDR);
  parameter W_UP_A = {{ addrlen }};
  parameter W_DOWN_A = {{ offchip_addrlen }};
  parameter MAP_START = {{ addrmap_start }};
  input [W_UP_A-1:0] UP_ADDR;
  output [W_DOWN_A-1:0] DOWN_ADDR;
  wire [W_DOWN_A-1:0] extended_UP_ADDR;
  assign extended_UP_ADDR = UP_ADDR;
  assign DOWN_ADDR = MAP_START + extended_UP_ADDR;
endmodule  


