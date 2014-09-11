`ifdef ENABLE_PERFORMANCECOUNTER
//------------------------------------------------------------------------------
// Performance Counter
//------------------------------------------------------------------------------
module PERFORMANCECOUNTER
  (CLK, RST,
{%- for domain in domains %}
   // Domain {{ domain.name }}
   {{ domain.name }}_DRIVE,
{%- for interface in domain.interfaces %}
   {{ interface.name }}_LRE,
   {{ interface.name }}_LWE,
   {{ interface.name }}_LRDY,
{%- endfor %}
{%- for space in domain.spaces %}
   // Performance Counter Output {{ space }}
   {{ domain.name }}_{{ space }}_cycle_idle,
   {{ domain.name }}_{{ space }}_cycle_hit,
   {{ domain.name }}_{{ space }}_cycle_miss,
   {{ domain.name }}_{{ space }}_cycle_conflict,
   {{ domain.name }}_{{ space }}_cycle_wait,
   {{ domain.name }}_{{ space }}_num_miss,
{%- endfor %}
{%- endfor %}
   reset_count
   );

  input CLK;
  input RST;
  input reset_count;

{%- for domain in domains %}
  input {{ domain.name }}_DRIVE;
{%- for interface in domain.interfaces %}
  input {{ interface.name }}_LRE;
  input {{ interface.name }}_LWE;
  input {{ interface.name }}_LRDY;
{%- endfor %}
{%- for space in domain.spaces %}
  output [63:0] {{ domain.name }}_{{ space }}_cycle_idle;
  output [63:0] {{ domain.name }}_{{ space }}_cycle_hit;
  output [63:0] {{ domain.name }}_{{ space }}_cycle_miss;
  output [63:0] {{ domain.name }}_{{ space }}_cycle_conflict;
  output [63:0] {{ domain.name }}_{{ space }}_cycle_wait;
  output [63:0] {{ domain.name }}_{{ space }}_num_miss;
{%- endfor %}
{%- endfor %}

  reg d_reset_count;
{%- for domain in domains %}
  reg d_{{ domain.name }}_DRIVE;
{%- for interface in domain.interfaces %}
  reg d_{{ interface.name }}_LRE;
  reg d_{{ interface.name }}_LWE;
  reg d_{{ interface.name }}_LRDY;
{%- endfor %}
{%- endfor %}

  always @(posedge CLK) begin
    if(RST) begin
      d_reset_count <= 0;
{%- for domain in domains %}
      d_{{ domain.name }}_DRIVE <= 0;
{%- for interface in domain.interfaces %}
      d_{{ interface.name }}_LRE <= 0;
      d_{{ interface.name }}_LWE <= 0;
      d_{{ interface.name }}_LRDY <= 0;
{%- endfor %}
{%- endfor %}
    end else begin
      d_reset_count <= reset_count;
{%- for domain in domains %}
      d_{{ domain.name }}_DRIVE <= {{ domain.name }}_DRIVE;
{%- for interface in domain.interfaces %}
      d_{{ interface.name }}_LRE <= {{ interface.name }}_LRE;
      d_{{ interface.name }}_LWE <= {{ interface.name }}_LWE;
      d_{{ interface.name }}_LRDY <= {{ interface.name }}_LRDY;
{%- endfor %}
{%- endfor %}
    end
  end

{% for domain in domains %}
  //------------------------------------------------------------------------------
  // Domain {{ domain.name }}
  //------------------------------------------------------------------------------
{%- for space in domain.spaces %}
  wire {{ domain.name }}_{{ space }}_req;
  wire {{ domain.name }}_{{ space }}_rdy;
  assign {{ domain.name }}_{{ space }}_req =
{%- for interface in domain.interfaces %}
{%- if interface.space == space %}   
          (d_{{ interface.name }}_LRE || d_{{ interface.name }}_LWE) || 
{%- endif %}
{%- endfor %}
          1'b0;
  assign {{ domain.name }}_{{ space }}_rdy =
{%- for interface in domain.interfaces %}
{%- if interface.space == space %}   
          d_{{ interface.name }}_LRDY ||
{%- endif %}
{%- endfor %}
          1'b0;

  COUNTERS
  inst_counters_{{ domain.name }}_{{ space }}
   (.CLK(CLK), .RST(RST),
    .reset_count(d_reset_count),
    .drive_in(d_{{ domain.name }}_DRIVE),
    .req_in({{ domain.name }}_{{ space }}_req),
    .rdy_in({{ domain.name }}_{{ space }}_rdy),
    .cycle_idle({{ domain.name }}_{{ space }}_cycle_idle),
    .cycle_hit({{ domain.name }}_{{ space }}_cycle_hit),
    .cycle_miss({{ domain.name }}_{{ space }}_cycle_miss),
    .cycle_conflict({{ domain.name }}_{{ space }}_cycle_conflict),
    .cycle_wait({{ domain.name }}_{{ space }}_cycle_wait),
    .num_miss({{ domain.name }}_{{ space }}_num_miss)
    );
{%- endfor %}
{% endfor %}

endmodule

module COUNTERS
  (CLK, RST,
   reset_count,
   drive_in, req_in, rdy_in,
   cycle_idle, cycle_hit, cycle_miss, cycle_conflict, cycle_wait, num_miss
   );
  input CLK;
  input RST;
  input reset_count;
  input drive_in;
  input req_in;
  input rdy_in;
  output reg [63:0] cycle_idle;
  output reg [63:0] cycle_hit;
  output reg [63:0] cycle_miss; 
  output reg [63:0] cycle_conflict;
  output reg [63:0] cycle_wait;
  output reg [63:0] num_miss;
  
  wire inc_idle;
  wire inc_hit;
  wire inc_miss;
  wire inc_conflict;
  wire inc_wait;
  wire inc_num_miss;
  reg d_inc_miss;
  
  assign inc_idle     = (drive_in == 1) && (req_in == 0);
  assign inc_hit      = (drive_in == 1) && (req_in == 1);
  assign inc_miss     = (drive_in == 0) && (req_in == 1) && (rdy_in == 0);
  assign inc_conflict = (drive_in == 0) && (req_in == 1) && (rdy_in == 1);
  assign inc_wait     = (drive_in == 0) && (req_in == 0);
  assign inc_num_miss = (drive_in == 0) && (req_in == 1) && (rdy_in == 0) && (d_inc_miss == 0);
  
  always @(posedge CLK) begin
    if(RST) begin
      d_inc_miss <= 0;
    end else begin
      d_inc_miss <= inc_miss;
    end
  end
  
  always @(posedge CLK) begin
    if(RST) begin
      cycle_idle <= 0;
      cycle_hit <= 0;
      cycle_miss <= 0;
      cycle_conflict <= 0;
      cycle_wait <= 0;
      cycle_miss <= 0;
      num_miss <= 0;
    end else if(reset_count) begin
      cycle_idle <= 0;
      cycle_hit <= 0;
      cycle_miss <= 0;
      cycle_conflict <= 0;
      cycle_wait <= 0;
      cycle_miss <= 0;
      num_miss <= 0;
    end else begin
      if(inc_idle) cycle_idle <= cycle_idle + 1;
      if(inc_hit) cycle_hit <= cycle_hit + 1;
      if(inc_miss) cycle_miss <= cycle_miss + 1;
      if(inc_conflict) cycle_conflict <= cycle_conflict + 1;
      if(inc_wait) cycle_wait <= cycle_wait + 1;
      if(inc_num_miss) num_miss <= num_miss + 1;
    end
  end
 
endmodule
  
`endif

