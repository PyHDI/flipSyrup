//------------------------------------------------------------------------------
// Scratchpad Memory with Multiplexer
//------------------------------------------------------------------------------
module {{ name }}
 (CLK, RST,
{%- for port in range(numports) %}
  ADDR{{ port }}, RE{{ port }}, WE{{ port }}, MASK{{ port }}, D{{ port }}, Q{{ port }}, READY{{ port }}, INIT_DONE{{ port }}{% if port < numports-1 %},{% endif %}
{%- endfor %}
  );

  parameter W_D = {{ datawidth }};
  parameter W_A = {{ addrlen }};
  parameter W_MASK = {{ maskwidth }};
  parameter W_WORD_A = {{ word_addrlen }};
  parameter W_OFFSET = {{ addroffset }};
  parameter NUMPORTS = {{ numports }};

  input CLK, RST;
  
{%- for port in range(numports) %}
  input  [W_A-1:0]               ADDR{{ port }};
  input                          RE{{ port }};
  input                          WE{{ port }};
  input  [W_MASK-1:0]            MASK{{ port }};
  input  [W_D-1:0]               D{{ port }};
  output [W_D-1:0]               Q{{ port }};
  output                         READY{{ port }};
  output                         INIT_DONE{{ port }};
{%- endfor %}

  wire [W_A-1:0]                 lower_addr;
  wire [W_D-1:0]                 lower_d;
  wire                           lower_we;
  wire                           lower_re;
  wire [W_MASK-1:0]              lower_mask;
  wire [W_D-1:0]                 lower_q;
  wire                           lower_ready;

{%- for port in range(numports) %}
  wire req{{ port }};
  assign req{{ port }} = (WE{{ port }} || RE{{ port }}) && !READY{{ port }};
{%- endfor %}

  reg [7:0] locked;
  wire [7:0] next_locked;
  reg busy;
  wire next_busy;

  assign lower_addr = {%- for port in range(numports) %}
                      (next_locked == {{ port }})? ADDR{{ port }} :
                      {%- endfor %}
                      0;
  assign lower_d = {%- for port in range(numports) %}
                   (next_locked == {{ port }})? D{{ port }} :
                   {%- endfor %}
                   0;
  assign lower_we = {%- for port in range(numports) %}
                    (next_locked == {{ port }})? WE{{ port }} :
                    {%- endfor %}
                    0;
  assign lower_re = {%- for port in range(numports) %}
                    (next_locked == {{ port }})? RE{{ port }} :
                    {%- endfor %}
                    0;
  assign lower_mask = {%- for port in range(numports) %}
                      (next_locked == {{ port }})? MASK{{ port }} :
                      {%- endfor %}
                      0;
{%- for port in range(numports) %}
  assign Q{{ port }} = lower_q;
{%- endfor %}
{%- for port in range(numports) %}
  assign READY{{ port }} = (locked == {{ port }}) && lower_ready;
  assign INIT_DONE{{ port }} = 1'b1;
{%- endfor %}
  
  function [7+1:0] roundrobbin;
{%- for port in range(numports) %}
    input req{{ port }};
{%- endfor %}
    input [7:0] locked;
    reg ret;
    reg [7:0] ret_locked;
    begin
      ret = 0;
      ret_locked = 0;
{%- for port in range(numports) %}
      if({{ port }} > locked && req{{ port }}) begin
        ret = 1;
        ret_locked = {{ port }};
      end else
{%- endfor %}
{%- for port in range(numports) %}
      if(req{{ port }}) begin
        ret = 1;
        ret_locked = {{ port }};
      end {%- if port < numports-1 %} else {% endif %}
{%- endfor %}
      if(ret) roundrobbin = {ret, ret_locked};
      else roundrobbin = {ret, locked};
    end
  endfunction

  assign {next_busy, next_locked} = (!busy || (busy && lower_ready))? roundrobbin({%- for port in range(numports) %}req{{ port }}, {%- endfor %}locked) : {busy, locked};

  always @(posedge CLK) begin
    if(RST) begin
      busy <= 0;
      locked <= 0;
    end else begin
      busy <= next_busy;
      locked <= next_locked;
    end
  end

  SCRATCHPAD_{{ name }} #(.W_D(W_D), .W_A(W_A), .W_MASK(W_MASK), .W_WORD_A(W_WORD_A))
  scratchpad (.CLK(CLK), .RST(RST),
              .ADDR(lower_addr), .D(lower_d), .WE(lower_we), .RE(lower_re), 
              .MASK(lower_mask), .Q(lower_q), .READY(lower_ready));

endmodule
 
module SCRATCHPAD_{{ name }}
 (CLK, RST,
  ADDR, RE, WE, MASK, D, Q, READY
  );
  
  parameter W_D = {{ datawidth }};
  parameter W_A = {{ addrlen }};
  parameter W_MASK = {{ maskwidth }};
  parameter W_WORD_A = {{ word_addrlen }};
  localparam LEN = 2 ** W_WORD_A;
  
  input CLK, RST;
  
  input [W_A-1:0]    ADDR;
  input              RE;
  input              WE;
  input [W_MASK-1:0] MASK;
  input [W_D-1:0]    D;
  output [W_D-1:0]   Q;
  output             READY;

  wire [W_WORD_A-1:0]     word_addr;
  assign word_addr = ADDR[W_A-1:(W_A-W_WORD_A)];
 
{%- for offset in range(maskwidth) %}
  wire wen_{{ offset }};
  wire [7:0] wdata_{{ offset }};
  wire [7:0] rdata_{{ offset }};
{%- endfor %}
  
{%- for offset in range(maskwidth) %}
  assign wen_{{ offset }} = WE && MASK[{{ offset }}];
  assign wdata_{{ offset }} = D[{{ (offset+1)*8-1 }}:{{ offset*8 }}];
{%- endfor %}
  
  assign Q = { {%- for offset in range(maskwidth) %} rdata_{{ maskwidth - offset -1 }}{%- if offset < maskwidth-1 %},{%- endif %}{%- endfor %} };
  assign READY = 1'b1;
  
{% for offset in range(maskwidth) %}
  mem_array_{{ name }} #(.W_WORD_A(W_WORD_A))
  array{{ offset }}
   (.CLK(CLK),
    .ADDR(word_addr), .WE(wen_{{ offset }}), .D(wdata_{{ offset }}), .Q(rdata_{{ offset }})
    );
{% endfor %}

endmodule

module mem_array_{{ name }}
 (CLK,
  ADDR, WE, D, Q
  );
  
  parameter W_WORD_A = {{ word_addrlen }};
  localparam LEN = 2 ** W_WORD_A;
  input CLK;

  input [W_WORD_A-1:0] ADDR;
  input                WE;
  input [7:0]          D;
  output [7:0]         Q;
  reg [W_WORD_A-1:0]   d_ADDR;
  
  reg [7:0] mem [0:LEN-1];
  
  always @(posedge CLK) begin
    d_ADDR <= ADDR;
    if(WE)
      mem[ADDR] <= D;
  end
  assign Q = mem[d_ADDR];
  
endmodule


