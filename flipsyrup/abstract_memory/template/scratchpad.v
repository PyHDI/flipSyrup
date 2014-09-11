//------------------------------------------------------------------------------
// Scratchpad Memory without MASK
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

{%- for port in range(numports) %}
  input [W_A-1:0]    ADDR{{ port }};
  input              RE{{ port }};
  input              WE{{ port }};
  input [W_MASK-1:0] MASK{{ port }};
  input [W_D-1:0]    D{{ port }};
  output [W_D-1:0]   Q{{ port }};
  output             READY{{ port }};
  output             INIT_DONE{{ port }};
{%- endfor %}

{%- for port in range(numports) %}
  wire [W_WORD_A-1:0] word_addr{{ port }};
  reg [W_WORD_A-1:0] d_word_addr{{ port }};
  assign word_addr{{ port }} = ADDR{{ port }}[W_A-1:(W_A-W_WORD_A)];
{%- endfor %}
  
  reg [W_D-1:0] mem [0:LEN-1];

  always @(posedge CLK) begin
{%- for port in range(numports) %}
    d_word_addr{{ port }} <= word_addr{{ port }};
    if(WE{{ port }})
      mem[word_addr{{ port }}] <= D{{ port }};
{%- endfor %}
  end

{%- for port in range(numports) %}
  assign Q{{ port }} = mem[d_word_addr{{ port }}];
  assign READY{{ port }} = 1'b1;
  assign INIT_DONE{{ port }} = 1'b1;
{%- endfor %}
  
endmodule


