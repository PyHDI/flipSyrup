//------------------------------------------------------------------------------
// Single-port Cache
//------------------------------------------------------------------------------
module SyrupMemory1P #
  (
   parameter DOMAIN = "undefined",
   parameter ID = 0,
   parameter ADDR_WIDTH = 10,
   parameter DATA_WIDTH = 32,
   parameter WAY = 1,
   parameter LINEWIDTH = 128,
   parameter BYTE_ENABLE = 0
   )
  (
   input                     CLK,
   input [ADDR_WIDTH-1:0]    ADDR,
   input [DATA_WIDTH-1:0]    D,
   input                     WE,
   output [DATA_WIDTH-1:0]   Q,
   input                     RE,
   input [DATA_WIDTH/8-1:0]  BE,
   output [ADDR_WIDTH-1:0]   p0_syrup_addr,
   output [DATA_WIDTH-1:0]   p0_syrup_d,
   output                    p0_syrup_we,
   input [DATA_WIDTH-1:0]    p0_syrup_q,
   output                    p0_syrup_re,
   output [DATA_WIDTH/8-1:0] p0_syrup_be
   );
  assign p0_syrup_addr = ADDR;
  assign p0_syrup_d = D;
  assign p0_syrup_we = WE;
  assign p0_syrup_re = RE;
  assign p0_syrup_be = BYTE_ENABLE? BE : {(DATA_WIDTH/8){1'b1}};
  assign Q = p0_syrup_q;
endmodule

//------------------------------------------------------------------------------
// Dual-port Cache
//------------------------------------------------------------------------------
module SyrupMemory2P #
  (
   parameter DOMAIN = "undefined",
   parameter ID = 0,
   parameter ADDR_WIDTH = 10,
   parameter DATA_WIDTH = 32,
   parameter WAY = 1,
   parameter LINEWIDTH = 128,
   parameter BYTE_ENABLE = 0
   )
  (
   input                     CLK,
   input [ADDR_WIDTH-1:0]    ADDR0,
   input [DATA_WIDTH-1:0]    D0,
   input                     WE0,
   output [DATA_WIDTH-1:0]   Q0,
   input                     RE0,
   input [DATA_WIDTH/8-1:0]  BE0,
   input [ADDR_WIDTH-1:0]    ADDR1,
   input [DATA_WIDTH-1:0]    D1,
   input                     WE1,
   output [DATA_WIDTH-1:0]   Q1,
   input                     RE1,
   input [DATA_WIDTH/8-1:0]  BE1,
   output [ADDR_WIDTH-1:0]   p0_syrup_addr,
   output [DATA_WIDTH-1:0]   p0_syrup_d,
   output                    p0_syrup_we,
   input [DATA_WIDTH-1:0]    p0_syrup_q,
   output                    p0_syrup_re,
   output [DATA_WIDTH/8-1:0] p0_syrup_be,
   output [ADDR_WIDTH-1:0]   p1_syrup_addr,
   output [DATA_WIDTH-1:0]   p1_syrup_d,
   output                    p1_syrup_we,
   input [DATA_WIDTH-1:0]    p1_syrup_q,
   output                    p1_syrup_re,
   output [DATA_WIDTH/8-1:0] p1_syrup_be
   );
  assign p0_syrup_addr = ADDR0;
  assign p0_syrup_d = D0;
  assign p0_syrup_we = WE0;
  assign p0_syrup_re = RE0;
  assign p0_syrup_be = BYTE_ENABLE? BE0 : {(DATA_WIDTH/8){1'b1}};
  assign Q0 = p0_syrup_q;
  assign p1_syrup_addr = ADDR1;
  assign p1_syrup_d = D1;
  assign p1_syrup_we = WE1;
  assign p1_syrup_re = RE1;
  assign p1_syrup_be = BYTE_ENABLE? BE1 : {(DATA_WIDTH/8){1'b1}};
  assign Q1 = p1_syrup_q;
endmodule

//------------------------------------------------------------------------------
// Tri-port Cache
//------------------------------------------------------------------------------
module SyrupMemory3P #
  (
   parameter DOMAIN = "undefined",
   parameter ID = 0,
   parameter ADDR_WIDTH = 10,
   parameter DATA_WIDTH = 32,
   parameter WAY = 1,
   parameter LINEWIDTH = 128,
   parameter BYTE_ENABLE = 0
   )
  (
   input                     CLK,
   input [ADDR_WIDTH-1:0]    ADDR0,
   input [DATA_WIDTH-1:0]    D0,
   input                     WE0,
   output [DATA_WIDTH-1:0]   Q0,
   input                     RE0,
   input [DATA_WIDTH/8-1:0]  BE0,
   input [ADDR_WIDTH-1:0]    ADDR1,
   input [DATA_WIDTH-1:0]    D1,
   input                     WE1,
   output [DATA_WIDTH-1:0]   Q1,
   input                     RE1,
   input [DATA_WIDTH/8-1:0]  BE1,
   input [ADDR_WIDTH-1:0]    ADDR2,
   input [DATA_WIDTH-1:0]    D2,
   input                     WE2,
   output [DATA_WIDTH-1:0]   Q2,
   input                     RE2,
   input [DATA_WIDTH/8-1:0]  BE2,
   output [ADDR_WIDTH-1:0]   p0_syrup_addr,
   output [DATA_WIDTH-1:0]   p0_syrup_d,
   output                    p0_syrup_we,
   input [DATA_WIDTH-1:0]    p0_syrup_q,
   output                    p0_syrup_re,
   output [DATA_WIDTH/8-1:0] p0_syrup_be,
   output [ADDR_WIDTH-1:0]   p1_syrup_addr,
   output [DATA_WIDTH-1:0]   p1_syrup_d,
   output                    p1_syrup_we,
   input [DATA_WIDTH-1:0]    p1_syrup_q,
   output                    p1_syrup_re,
   output [DATA_WIDTH/8-1:0] p1_syrup_be,
   output [ADDR_WIDTH-1:0]   p2_syrup_addr,
   output [DATA_WIDTH-1:0]   p2_syrup_d,
   output                    p2_syrup_we,
   input [DATA_WIDTH-1:0]    p2_syrup_q,
   output                    p2_syrup_re,
   output [DATA_WIDTH/8-1:0] p2_syrup_be
   );
  assign p0_syrup_addr = ADDR0;
  assign p0_syrup_d = D0;
  assign p0_syrup_we = WE0;
  assign p0_syrup_re = RE0;
  assign p0_syrup_be = BYTE_ENABLE? BE0 : {(DATA_WIDTH/8){1'b1}};
  assign Q0 = p0_syrup_q;
  assign p1_syrup_addr = ADDR1;
  assign p1_syrup_d = D1;
  assign p1_syrup_we = WE1;
  assign p1_syrup_re = RE1;
  assign p1_syrup_be = BYTE_ENABLE? BE1 : {(DATA_WIDTH/8){1'b1}};
  assign Q1 = p1_syrup_q;
  assign p2_syrup_addr = ADDR2;
  assign p2_syrup_d = D2;
  assign p2_syrup_we = WE2;
  assign p2_syrup_re = RE2;
  assign p2_syrup_be = BYTE_ENABLE? BE2 : {(DATA_WIDTH/8){1'b1}};
  assign Q2 = p2_syrup_q;
endmodule

//------------------------------------------------------------------------------
// Quad-port Cache
//------------------------------------------------------------------------------
module SyrupMemory4P #
  (
   parameter DOMAIN = "undefined",
   parameter ID = 0,
   parameter ADDR_WIDTH = 10,
   parameter DATA_WIDTH = 32,
   parameter WAY = 1,
   parameter LINEWIDTH = 128,
   parameter BYTE_ENABLE = 0
   )
  (
   input                     CLK,
   input [ADDR_WIDTH-1:0]    ADDR0,
   input [DATA_WIDTH-1:0]    D0,
   input                     WE0,
   output [DATA_WIDTH-1:0]   Q0,
   input                     RE0,
   input [DATA_WIDTH/8-1:0]  BE0,
   input [ADDR_WIDTH-1:0]    ADDR1,
   input [DATA_WIDTH-1:0]    D1,
   input                     WE1,
   output [DATA_WIDTH-1:0]   Q1,
   input                     RE1,
   input [DATA_WIDTH/8-1:0]  BE1,
   input [ADDR_WIDTH-1:0]    ADDR2,
   input [DATA_WIDTH-1:0]    D2,
   input                     WE2,
   output [DATA_WIDTH-1:0]   Q2,
   input                     RE2,
   input [DATA_WIDTH/8-1:0]  BE2,
   input [ADDR_WIDTH-1:0]    ADDR3,
   input [DATA_WIDTH-1:0]    D3,
   input                     WE3,
   output [DATA_WIDTH-1:0]   Q3,
   input                     RE3,
   input [DATA_WIDTH/8-1:0]  BE3,
   output [ADDR_WIDTH-1:0]   p0_syrup_addr,
   output [DATA_WIDTH-1:0]   p0_syrup_d,
   output                    p0_syrup_we,
   input [DATA_WIDTH-1:0]    p0_syrup_q,
   output                    p0_syrup_re,
   output [DATA_WIDTH/8-1:0] p0_syrup_be,
   output [ADDR_WIDTH-1:0]   p1_syrup_addr,
   output [DATA_WIDTH-1:0]   p1_syrup_d,
   output                    p1_syrup_we,
   input [DATA_WIDTH-1:0]    p1_syrup_q,
   output                    p1_syrup_re,
   output [DATA_WIDTH/8-1:0] p1_syrup_be,
   output [ADDR_WIDTH-1:0]   p2_syrup_addr,
   output [DATA_WIDTH-1:0]   p2_syrup_d,
   output                    p2_syrup_we,
   input [DATA_WIDTH-1:0]    p2_syrup_q,
   output                    p2_syrup_re,
   output [DATA_WIDTH/8-1:0] p2_syrup_be,
   output [ADDR_WIDTH-1:0]   p3_syrup_addr,
   output [DATA_WIDTH-1:0]   p3_syrup_d,
   output                    p3_syrup_we,
   input [DATA_WIDTH-1:0]    p3_syrup_q,
   output                    p3_syrup_re,
   output [DATA_WIDTH/8-1:0] p3_syrup_be
   );
  assign p0_syrup_addr = ADDR0;
  assign p0_syrup_d = D0;
  assign p0_syrup_we = WE0;
  assign p0_syrup_re = RE0;
  assign p0_syrup_be = BYTE_ENABLE? BE0 : {(DATA_WIDTH/8){1'b1}};
  assign Q0 = p0_syrup_q;
  assign p1_syrup_addr = ADDR1;
  assign p1_syrup_d = D1;
  assign p1_syrup_we = WE1;
  assign p1_syrup_re = RE1;
  assign p1_syrup_be = BYTE_ENABLE? BE1 : {(DATA_WIDTH/8){1'b1}};
  assign Q1 = p1_syrup_q;
  assign p2_syrup_addr = ADDR2;
  assign p2_syrup_d = D2;
  assign p2_syrup_we = WE2;
  assign p2_syrup_re = RE2;
  assign p2_syrup_be = BYTE_ENABLE? BE2 : {(DATA_WIDTH/8){1'b1}};
  assign Q2 = p2_syrup_q;
  assign p3_syrup_addr = ADDR3;
  assign p3_syrup_d = D3;
  assign p3_syrup_we = WE3;
  assign p3_syrup_re = RE3;
  assign p3_syrup_be = BYTE_ENABLE? BE3 : {(DATA_WIDTH/8){1'b1}};
  assign Q3 = p3_syrup_q;
endmodule

//------------------------------------------------------------------------------
// Five-port Cache
//------------------------------------------------------------------------------
module SyrupMemory5P #
  (
   parameter DOMAIN = "undefined",
   parameter ID = 0,
   parameter ADDR_WIDTH = 10,
   parameter DATA_WIDTH = 32,
   parameter WAY = 1,
   parameter LINEWIDTH = 128,
   parameter BYTE_ENABLE = 0
   )
  (
   input                     CLK,
   input [ADDR_WIDTH-1:0]    ADDR0,
   input [DATA_WIDTH-1:0]    D0,
   input                     WE0,
   output [DATA_WIDTH-1:0]   Q0,
   input                     RE0,
   input [DATA_WIDTH/8-1:0]  BE0,
   input [ADDR_WIDTH-1:0]    ADDR1,
   input [DATA_WIDTH-1:0]    D1,
   input                     WE1,
   output [DATA_WIDTH-1:0]   Q1,
   input                     RE1,
   input [DATA_WIDTH/8-1:0]  BE1,
   input [ADDR_WIDTH-1:0]    ADDR2,
   input [DATA_WIDTH-1:0]    D2,
   input                     WE2,
   output [DATA_WIDTH-1:0]   Q2,
   input                     RE2,
   input [DATA_WIDTH/8-1:0]  BE2,
   input [ADDR_WIDTH-1:0]    ADDR3,
   input [DATA_WIDTH-1:0]    D3,
   input                     WE3,
   output [DATA_WIDTH-1:0]   Q3,
   input                     RE3,
   input [DATA_WIDTH/8-1:0]  BE3,
   input [ADDR_WIDTH-1:0]    ADDR4,
   input [DATA_WIDTH-1:0]    D4,
   input                     WE4,
   output [DATA_WIDTH-1:0]   Q4,
   input                     RE4,
   input [DATA_WIDTH/8-1:0]  BE4,
   output [ADDR_WIDTH-1:0]   p0_syrup_addr,
   output [DATA_WIDTH-1:0]   p0_syrup_d,
   output                    p0_syrup_we,
   input [DATA_WIDTH-1:0]    p0_syrup_q,
   output                    p0_syrup_re,
   output [DATA_WIDTH/8-1:0] p0_syrup_be,
   output [ADDR_WIDTH-1:0]   p1_syrup_addr,
   output [DATA_WIDTH-1:0]   p1_syrup_d,
   output                    p1_syrup_we,
   input [DATA_WIDTH-1:0]    p1_syrup_q,
   output                    p1_syrup_re,
   output [DATA_WIDTH/8-1:0] p1_syrup_be,
   output [ADDR_WIDTH-1:0]   p2_syrup_addr,
   output [DATA_WIDTH-1:0]   p2_syrup_d,
   output                    p2_syrup_we,
   input [DATA_WIDTH-1:0]    p2_syrup_q,
   output                    p2_syrup_re,
   output [DATA_WIDTH/8-1:0] p2_syrup_be,
   output [ADDR_WIDTH-1:0]   p3_syrup_addr,
   output [DATA_WIDTH-1:0]   p3_syrup_d,
   output                    p3_syrup_we,
   input [DATA_WIDTH-1:0]    p3_syrup_q,
   output                    p3_syrup_re,
   output [DATA_WIDTH/8-1:0] p3_syrup_be,
   output [ADDR_WIDTH-1:0]   p4_syrup_addr,
   output [DATA_WIDTH-1:0]   p4_syrup_d,
   output                    p4_syrup_we,
   input [DATA_WIDTH-1:0]    p4_syrup_q,
   output                    p4_syrup_re,
   output [DATA_WIDTH/8-1:0] p4_syrup_be
   );
  assign p0_syrup_addr = ADDR0;
  assign p0_syrup_d = D0;
  assign p0_syrup_we = WE0;
  assign p0_syrup_re = RE0;
  assign p0_syrup_be = BYTE_ENABLE? BE0 : {(DATA_WIDTH/8){1'b1}};
  assign Q0 = p0_syrup_q;
  assign p1_syrup_addr = ADDR1;
  assign p1_syrup_d = D1;
  assign p1_syrup_we = WE1;
  assign p1_syrup_re = RE1;
  assign p1_syrup_be = BYTE_ENABLE? BE1 : {(DATA_WIDTH/8){1'b1}};
  assign Q1 = p1_syrup_q;
  assign p2_syrup_addr = ADDR2;
  assign p2_syrup_d = D2;
  assign p2_syrup_we = WE2;
  assign p2_syrup_re = RE2;
  assign p2_syrup_be = BYTE_ENABLE? BE2 : {(DATA_WIDTH/8){1'b1}};
  assign Q2 = p2_syrup_q;
  assign p3_syrup_addr = ADDR3;
  assign p3_syrup_d = D3;
  assign p3_syrup_we = WE3;
  assign p3_syrup_re = RE3;
  assign p3_syrup_be = BYTE_ENABLE? BE3 : {(DATA_WIDTH/8){1'b1}};
  assign Q3 = p3_syrup_q;
  assign p4_syrup_addr = ADDR4;
  assign p4_syrup_d = D4;
  assign p4_syrup_we = WE4;
  assign p4_syrup_re = RE4;
  assign p4_syrup_be = BYTE_ENABLE? BE4 : {(DATA_WIDTH/8){1'b1}};
  assign Q4 = p4_syrup_q;
endmodule

//------------------------------------------------------------------------------
// Abstract Channel
//------------------------------------------------------------------------------
module SyrupOutChannel #
  (
   parameter DOMAIN = "undefined",
   parameter ID = 0,
   parameter DATA_WIDTH = 32,
   parameter ADDR_WIDTH = 4
   )
  (
   input                   CLK,
   input [DATA_WIDTH-1:0]  D,
   input                   WE,
   output [DATA_WIDTH-1:0] syrup_d,
   output                  syrup_we
   );
  assign syrup_d = D;
  assign syrup_we = WE;
endmodule

module SyrupInChannel #
  (
   parameter DOMAIN = "undefined",
   parameter ID = 0,
   parameter DATA_WIDTH = 32,
   parameter ADDR_WIDTH = 4
   )
  (
   input                   CLK,
   output [DATA_WIDTH-1:0] Q,
   input                   RE,
   input [DATA_WIDTH-1:0]  syrup_q,
   output                  syrup_re
   );
  assign Q = syrup_q;
  assign syrup_re = RE;
endmodule

