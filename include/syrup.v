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
   input                    CLK,
   input [ADDR_WIDTH-1:0]   ADDR,
   input [DATA_WIDTH-1:0]   D,
   input                    WE,
   output [DATA_WIDTH-1:0]  Q,
   input                    RE,
   input [DATA_WIDTH/8-1:0] BE
   );
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
   input                    CLK,
   input [ADDR_WIDTH-1:0]   ADDR0,
   input [DATA_WIDTH-1:0]   D0,
   input                    WE0,
   output [DATA_WIDTH-1:0]  Q0,
   input                    RE0,
   input [DATA_WIDTH/8-1:0] BE0,
   input [ADDR_WIDTH-1:0]   ADDR1,
   input [DATA_WIDTH-1:0]   D1,
   input                    WE1,
   output [DATA_WIDTH-1:0]  Q1,
   input                    RE1,
   input [DATA_WIDTH/8-1:0] BE1
   );
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
   input                    CLK,
   input [ADDR_WIDTH-1:0]   ADDR0,
   input [DATA_WIDTH-1:0]   D0,
   input                    WE0,
   output [DATA_WIDTH-1:0]  Q0,
   input                    RE0,
   input [DATA_WIDTH/8-1:0] BE0,
   input [ADDR_WIDTH-1:0]   ADDR1,
   input [DATA_WIDTH-1:0]   D1,
   input                    WE1,
   output [DATA_WIDTH-1:0]  Q1,
   input                    RE1,
   input [DATA_WIDTH/8-1:0] BE1,
   input [ADDR_WIDTH-1:0]   ADDR2,
   input [DATA_WIDTH-1:0]   D2,
   input                    WE2,
   output [DATA_WIDTH-1:0]  Q2,
   input                    RE2,
   input [DATA_WIDTH/8-1:0] BE2
   );
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
   input                    CLK,
   input [ADDR_WIDTH-1:0]   ADDR0,
   input [DATA_WIDTH-1:0]   D0,
   input                    WE0,
   output [DATA_WIDTH-1:0]  Q0,
   input                    RE0,
   input [DATA_WIDTH/8-1:0] BE0,
   input [ADDR_WIDTH-1:0]   ADDR1,
   input [DATA_WIDTH-1:0]   D1,
   input                    WE1,
   output [DATA_WIDTH-1:0]  Q1,
   input                    RE1,
   input [DATA_WIDTH/8-1:0] BE1,
   input [ADDR_WIDTH-1:0]   ADDR2,
   input [DATA_WIDTH-1:0]   D2,
   input                    WE2,
   output [DATA_WIDTH-1:0]  Q2,
   input                    RE2,
   input [DATA_WIDTH/8-1:0] BE2,
   input [ADDR_WIDTH-1:0]   ADDR3,
   input [DATA_WIDTH-1:0]   D3,
   input                    WE3,
   output [DATA_WIDTH-1:0]  Q3,
   input                    RE3,
   input [DATA_WIDTH/8-1:0] BE3
   );
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
   input                    CLK,
   input [ADDR_WIDTH-1:0]   ADDR0,
   input [DATA_WIDTH-1:0]   D0,
   input                    WE0,
   output [DATA_WIDTH-1:0]  Q0,
   input                    RE0,
   input [DATA_WIDTH/8-1:0] BE0,
   input [ADDR_WIDTH-1:0]   ADDR1,
   input [DATA_WIDTH-1:0]   D1,
   input                    WE1,
   output [DATA_WIDTH-1:0]  Q1,
   input                    RE1,
   input [DATA_WIDTH/8-1:0] BE1,
   input [ADDR_WIDTH-1:0]   ADDR2,
   input [DATA_WIDTH-1:0]   D2,
   input                    WE2,
   output [DATA_WIDTH-1:0]  Q2,
   input                    RE2,
   input [DATA_WIDTH/8-1:0] BE2,
   input [ADDR_WIDTH-1:0]   ADDR3,
   input [DATA_WIDTH-1:0]   D3,
   input                    WE3,
   output [DATA_WIDTH-1:0]  Q3,
   input                    RE3,
   input [DATA_WIDTH/8-1:0] BE3,
   input [ADDR_WIDTH-1:0]   ADDR4,
   input [DATA_WIDTH-1:0]   D4,
   input                    WE4,
   output [DATA_WIDTH-1:0]  Q4,
   input                    RE4,
   input [DATA_WIDTH/8-1:0] BE4
   );
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
   input                   WE
   );
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
   input                   RE
   );
endmodule

