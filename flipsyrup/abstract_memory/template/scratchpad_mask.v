//------------------------------------------------------------------------------
// Scratchpad Memory with MASK
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
  localparam LEN = 2 ** W_WORD_A;
  
  input CLK, RST;
  
{% for port in range(numports) %}
  input [W_A-1:0]    ADDR{{ port }};
  input              RE{{ port }};
  input              WE{{ port }};
  input [W_MASK-1:0] MASK{{ port }};
  input [W_D-1:0]    D{{ port }};
  output [W_D-1:0]   Q{{ port }};
  output             READY{{ port }};
  output             INIT_DONE{{ port }};
{% endfor %}

{%- for port in range(numports) %}
  wire [W_WORD_A-1:0]     word_addr{{ port }};
  assign word_addr{{ port }} = ADDR{{ port }}[W_A-1:(W_A-W_WORD_A)];
{%- endfor %}
 
{% for port in range(numports) %}
{%- for offset in range(maskwidth) %}
  wire wen{{ port }}_{{ offset }};
  wire [7:0] wdata{{ port }}_{{ offset }};
  wire [7:0] rdata{{ port }}_{{ offset }};
{%- endfor %}
{% endfor %}    
  
{% for port in range(numports) %}
{%- for offset in range(maskwidth) %}
  assign wen{{ port }}_{{ offset }} = WE{{ port }} && MASK{{ port }}[{{ offset }}];
  assign wdata{{ port }}_{{ offset }} = D{{ port }}[{{ (offset+1)*8-1 }}:{{ offset*8 }}];
{%- endfor %}
  
  assign Q{{ port }} = { {%- for offset in range(maskwidth) %} rdata{{ port }}_{{ maskwidth - offset -1 }}{%- if offset < maskwidth-1 %},{%- endif %}{%- endfor %} };
  assign READY{{ port }} = 1'b1;
  assign INIT_DONE{{ port }} = 1'b1;
{% endfor %}    
  
{% for offset in range(maskwidth) %}
  mem_array_{{ name }} #(.W_WORD_A(W_WORD_A))
  array{{ offset }}
   (.CLK(CLK),
{%- for port in range(numports) %}  
    .ADDR{{ port }}(word_addr{{ port }}), .WE{{ port }}(wen{{ port }}_{{ offset }}), .D{{ port }}(wdata{{ port }}_{{ offset }}), .Q{{ port }}(rdata{{ port }}_{{ offset }})
{%- if port < numports-1 %},
{%- endif %}
{%- endfor %}  
    );
{% endfor %}

endmodule

module mem_array_{{ name }}
 (CLK,
{%- for port in range(numports) %}
  ADDR{{ port }}, WE{{ port }}, D{{ port }}, Q{{ port }}
{%- if port < numports-1 %},
{%- endif %}
{%- endfor %}
  );
  
  parameter W_WORD_A = {{ word_addrlen }};
  localparam LEN = 2 ** W_WORD_A;
  input CLK;

{%- for port in range(numports) %}  
  input [W_WORD_A-1:0] ADDR{{ port }};
  input                WE{{ port }};
  input [7:0]          D{{ port }};
  output [7:0]         Q{{ port }};
  reg [W_WORD_A-1:0]   d_ADDR{{ port }};
{%- endfor %}
  
  reg [7:0] mem [0:LEN-1];
  
  always @(posedge CLK) begin
{%- for port in range(numports) %}  
    d_ADDR{{ port }} <= ADDR{{ port }};
    if(WE{{ port }})
      mem[ADDR{{ port }}] <= D{{ port }};
{%- endfor %}
  end
{%- for port in range(numports) %}    
  assign Q{{ port }} = mem[d_ADDR{{ port }}];
{%- endfor %}
  
endmodule


