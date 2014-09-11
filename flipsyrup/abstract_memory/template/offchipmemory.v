//------------------------------------------------------------------------------
// Off-chip Memory Interface
//------------------------------------------------------------------------------
module {{ name }}
 (CLK, RST,
{%- for port in range(offchip_numports) %}
  ADDR{{ port }}, RE{{ port }}, WE{{ port }}, D{{ port }}, Q{{ port }}, RDY{{ port }},
{%- endfor %}
  MEM_ADDR, MEM_D, MEM_WE, MEM_RE, MEM_Q, MEM_RDY);

  parameter W_OFF_A = {{ offchip_addrlen }};
  parameter W_OFF_D = {{ offchip_datawidth }};

  input CLK;
  input RST;
  
{%- for port in range(offchip_numports) %}
  input [W_OFF_A-1:0]  ADDR{{ port }};
  input                RE{{ port }};
  input                WE{{ port }};
  input [W_OFF_D-1:0]  D{{ port }};
  output [W_OFF_D-1:0] Q{{ port }};
  output               RDY{{ port }};
{%- endfor %}
  
  output [W_OFF_A-1:0] MEM_ADDR;
  output               MEM_RE;
  output               MEM_WE;
  output [W_OFF_D-1:0] MEM_D;
  input [W_OFF_D-1:0]  MEM_Q;
  input                MEM_RDY;

  wire [W_OFF_A-1:0] lower_addr;
  wire [W_OFF_D-1:0] lower_d;
  wire               lower_we;
  wire               lower_re;
  wire [W_OFF_D-1:0] lower_q;
  wire               lower_ready;

{%- for port in range(offchip_numports) %}
  wire req{{ port }};
  assign req{{ port }} = (WE{{ port }} || RE{{ port }}) && !RDY{{ port }};
{%- endfor %}

  reg [7:0] locked;
  wire [7:0] next_locked;
  reg busy;
  wire next_busy;

  assign lower_addr = {%- for port in range(offchip_numports) %}
                      (next_locked == {{ port }})? ADDR{{ port }} :
                      {%- endfor %}
                      'hx;
  assign lower_d = {%- for port in range(offchip_numports) %}
                   (next_locked == {{ port }})? D{{ port }} :
                   {%- endfor %}
                   'hx;
  assign lower_we = (!next_busy)? 'b0:
                    {%- for port in range(offchip_numports) %}
                    (next_locked == {{ port }})? WE{{ port }} :
                    {%- endfor %}
                    0;
  assign lower_re = (!next_busy)? 'b0:
                    {%- for port in range(offchip_numports) %}
                    (next_locked == {{ port }})? RE{{ port }} :
                    {%- endfor %}
                    0;
{%- for port in range(offchip_numports) %}
  assign Q{{ port }} = lower_q;
{%- endfor %}
{%- for port in range(offchip_numports) %}
  assign RDY{{ port }} = busy && (locked == {{ port }}) && lower_ready;
{%- endfor %}

  function [7+1:0] roundrobbin;
{%- for port in range(offchip_numports) %}
    input req{{ port }};
{%- endfor %}
    input [7:0] locked;
    reg ret;
    reg [7:0] ret_locked;
    begin
      ret = 0;
      ret_locked = 0;
{%- for port in range(offchip_numports) %}
      if({{ port }} > locked && req{{ port }}) begin
        ret = 1;
        ret_locked = {{ port }};
      end else
{%- endfor %}
{%- for port in range(offchip_numports) %}
      if(req{{ port }}) begin
        ret = 1;
        ret_locked = {{ port }};
      end {%- if port < offchip_numports-1 %} else {% endif %}
{%- endfor %}
      if(ret) roundrobbin = {ret, ret_locked};
      else roundrobbin = {ret, locked};
    end
  endfunction

  assign {next_busy, next_locked} = (!busy || (busy && lower_ready))? roundrobbin({%- for port in range(offchip_numports) %}req{{ port }}, {%- endfor %}locked) : {busy, locked};
  
  always @(posedge CLK) begin
    if(RST) begin
      busy <= 0;
      locked <= 0;
    end else begin
      busy <= next_busy;
      locked <= next_locked;
    end
  end

  assign MEM_ADDR = lower_addr;
  assign MEM_RE = lower_re;
  assign MEM_WE = lower_we;
  assign MEM_D = lower_d;
  assign lower_q = MEM_Q;
  assign lower_ready = MEM_RDY;
  
endmodule



