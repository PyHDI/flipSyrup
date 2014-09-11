//------------------------------------------------------------------------------
// Domain Controller
//------------------------------------------------------------------------------
module DOMAINCONTROLLER
 (CLK, RST,
{% for domain in domains %}
{%- for interface in domain.interfaces %}
  /* Connected to Logic {{ interface.name }} */
  {{ interface.name }}_ADDR, {% if interface.mode == 'readwrite' or interface.mode == 'read' %}{{ interface.name }}_RE, {{ interface.name }}_Q, {% endif %}{% if interface.mode == 'readwrite' or interface.mode == 'write' %}{{ interface.name }}_WE, {{ interface.name }}_D, {% endif %}{% if interface.mask %}{{ interface.name }}_MASK, {% endif %}
{%- endfor %}
{%- for interface in domain.interfaces %}
  /* Connected to Lower memory module for {{ interface.name }} */
  {{ interface.name }}_LADDR, {% if interface.mode == 'readwrite' or interface.mode == 'read' %}{{ interface.name }}_LRE, {{ interface.name }}_LQ, {% endif %}{% if interface.mode == 'readwrite' or interface.mode == 'write' %}{{ interface.name }}_LWE, {{ interface.name }}_LD, {% endif %}{% if interface.mask %}{{ interface.name }}_LMASK, {% endif %}{{ interface.name }}_LRDY, {{ interface.name }}_LINIT_DONE,
{%- endfor %}
  /* Drive signal for domain {{ domain.name }} */
  {{ domain.name }}_slave_drive_in,
  {{ domain.name }}_slave_drive_out,
  {{ domain.name }}_master_drive_in,
  {{ domain.name }}_master_drive_out,
  {{ domain.name }}_DRIVE{%- if loop.index < numdomains %}, {%- endif %}
{% endfor %}
 );

  parameter WITH_CHANNEL = 0;
  
  input CLK;
  input RST;

{% for domain in domains %}

{%- for interface in domain.interfaces %}
  input [{{ interface.addrlen-1 }}:0] {{ interface.name }}_ADDR;
{%- if interface.mode == 'readwrite' or interface.mode == 'read' %}
  input {{ interface.name }}_RE;
  output [{{ interface.datawidth-1 }}:0] {{ interface.name }}_Q;
{%- endif %}
{%- if interface.mode == 'readwrite' or interface.mode == 'write' %}
  input {{ interface.name }}_WE;
  input [{{ interface.datawidth-1 }}:0] {{ interface.name }}_D;
{%- endif %}
{%- if interface.mask %}
  input [{{ interface.maskwidth-1 }}:0] {{ interface.name }}_MASK;
{%- endif %}
{%- endfor %}

{%- for interface in domain.interfaces %}
  output [{{ interface.addrlen-1 }}:0] {{ interface.name }}_LADDR;
{%- if interface.mode == 'readwrite' or interface.mode == 'read' %}
  output {{ interface.name }}_LRE;
  input [{{ interface.datawidth-1 }}:0] {{ interface.name }}_LQ;
{%- endif %}
{%- if interface.mode == 'readwrite' or interface.mode == 'write' %}
  output {{ interface.name }}_LWE;
  output [{{ interface.datawidth-1 }}:0] {{ interface.name }}_LD;
{%- endif %}
{%- if interface.mask %}
  output [{{ interface.maskwidth-1 }}:0] {{ interface.name }}_LMASK;
{%- endif %}
  input {{ interface.name }}_LRDY;
  input {{ interface.name }}_LINIT_DONE;
{%- endfor %}

  input {{ domain.name }}_slave_drive_in;
  output {{ domain.name }}_slave_drive_out;
  input {{ domain.name }}_master_drive_in;
  output {{ domain.name }}_master_drive_out;
  output {{ domain.name }}_DRIVE;
{%- endfor %}  

  
{%- for domain in domains %}
{%- for interface in domain.interfaces %}
  reg access_wait_{{ domain.name }}_{{ interface.name }};
{%- if interface.mode == 'readwrite' or interface.mode == 'read' %}
  reg access_readwait_{{ domain.name }}_{{ interface.name }};
{%- endif %}
{%- if interface.mode == 'readwrite' or interface.mode == 'write' %}
  reg access_writewait_{{ domain.name }}_{{ interface.name }};
{%- endif %}
  reg access_done_{{ domain.name }}_{{ interface.name }};
  reg [{{ interface.addrlen-1 }}:0] access_addr_{{ domain.name }}_{{ interface.name }};
{%- if interface.mode == 'readwrite' or interface.mode == 'read' %}
  reg [{{ interface.datawidth-1 }}:0] access_q_{{ domain.name }}_{{ interface.name }};
{%- endif %}
{%- if interface.mode == 'readwrite' or interface.mode == 'write' %}
  reg [{{ interface.datawidth-1 }}:0] access_data_{{ domain.name }}_{{ interface.name }};
{%- endif %}
{%- if interface.mask %}
  reg [{{ interface.maskwidth-1 }}:0] access_mask_{{ domain.name }}_{{ interface.name }};
  {%- endif %}
{%- endfor %}
{%- endfor %}  

  
{%- for domain in domains %}
{%- for interface in domain.interfaces %}
  assign {{ interface.name }}_LADDR  = ({{ domain.name }}_DRIVE)? {{ interface.name }}_ADDR : access_addr_{{ domain.name }}_{{ interface.name }};
{%- if interface.mode == 'readwrite' or interface.mode == 'read' %}
  assign {{ interface.name }}_LRE    = ({{ domain.name }}_DRIVE)? {{ interface.name }}_RE : access_readwait_{{ domain.name }}_{{ interface.name }} && !access_done_{{ domain.name }}_{{ interface.name }} && !{{ interface.name }}_LRDY;
  assign {{ interface.name }}_Q      = (access_done_{{ domain.name }}_{{ interface.name }})? access_q_{{ domain.name }}_{{ interface.name }} : {{ interface.name }}_LQ;
{%- endif %}
{%- if interface.mode == 'readwrite' or interface.mode == 'write' %}
  assign {{ interface.name }}_LWE    = ({{ domain.name }}_DRIVE)? {{ interface.name }}_WE : access_writewait_{{ domain.name }}_{{ interface.name }} && !access_done_{{ domain.name }}_{{ interface.name }} && !{{ interface.name }}_LRDY;
  assign {{ interface.name }}_LD     = ({{ domain.name }}_DRIVE)? {{ interface.name }}_D : access_data_{{ domain.name }}_{{ interface.name }};
{%- endif %}
{%- if interface.mask %}
  assign {{ interface.name }}_LMASK  = ({{ domain.name }}_DRIVE)? {{ interface.name }}_MASK : access_mask_{{ domain.name }}_{{ interface.name }};
{%- endif %}
{%- endfor %}
{%- endfor %}  

  
{%- for domain in domains %}
  wire next_ready_{{ domain.name }};
  assign next_ready_{{ domain.name }} = 
    {% for interface in domain.interfaces %}{{ interface.name }}_LINIT_DONE && ((access_wait_{{ domain.name }}_{{ interface.name }} && (access_done_{{ domain.name }}_{{ interface.name }} || {{ interface.name }}_LRDY)) || !access_wait_{{ domain.name }}_{{ interface.name }}) &&
    {% endfor %}
    1'b1;
{%- endfor %}  


  always @(posedge CLK) begin
    if(RST) begin
      
{%- for domain in domains %}
{%- for interface in domain.interfaces %}
      access_wait_{{ domain.name }}_{{ interface.name }} <= 0;
{%- if interface.mode == 'readwrite' or interface.mode == 'read' %}
      access_readwait_{{ domain.name }}_{{ interface.name }} <= 0;
{%- endif %}
{%- if interface.mode == 'readwrite' or interface.mode == 'write' %}
      access_writewait_{{ domain.name }}_{{ interface.name }} <= 0;
{%- endif %}
      access_done_{{ domain.name }}_{{ interface.name }} <= 0;
      access_addr_{{ domain.name }}_{{ interface.name }} <= 0;
{%- if interface.mode == 'readwrite' or interface.mode == 'write' %}
      access_data_{{ domain.name }}_{{ interface.name }} <= 0;
{%- endif %}
{%- if interface.mask %}
      access_mask_{{ domain.name }}_{{ interface.name }} <= 0;
{%- endif %}
{%- if interface.mode == 'readwrite' or interface.mode == 'read' %}
      access_q_{{ domain.name }}_{{ interface.name }} <= 0;
{%- endif %}
{%- endfor %}
{%- endfor %}

    end else begin

{%- for domain in domains %}

      if({{ domain.name }}_DRIVE) begin

{%- for interface in domain.interfaces %}
        access_wait_{{ domain.name }}_{{ interface.name }} <= 0;
{%- if interface.mode == 'readwrite' or interface.mode == 'read' %}
        access_readwait_{{ domain.name }}_{{ interface.name }} <= 0;
{%- endif %}
{%- if interface.mode == 'readwrite' or interface.mode == 'write' %}
        access_writewait_{{ domain.name }}_{{ interface.name }} <= 0;
{%- endif %}
        access_done_{{ domain.name }}_{{ interface.name }} <= 0;
{%- endfor %}
        
{%- for interface in domain.interfaces %}
        if({%- if interface.mode == 'readwrite' -%}{{ interface.name }}_RE || {{ interface.name }}_WE
           {%- elif interface.mode == 'read' -%}{{ interface.name }}_RE
           {%- elif interface.mode == 'write' -%}{{ interface.name }}_WE{%- endif -%}) begin
          access_wait_{{ domain.name }}_{{ interface.name }} <= 1;
{%- if interface.mode == 'readwrite' or interface.mode == 'read' %}
          access_readwait_{{ domain.name }}_{{ interface.name }} <= {{ interface.name }}_RE;
{%- endif %}
{%- if interface.mode == 'readwrite' or interface.mode == 'write' %}
          access_writewait_{{ domain.name }}_{{ interface.name }} <= {{ interface.name }}_WE;
          access_data_{{ domain.name }}_{{ interface.name }} <= {{ interface.name }}_D;
{%- endif %}
          access_done_{{ domain.name }}_{{ interface.name }} <= 0;
          access_addr_{{ domain.name }}_{{ interface.name }} <= {{ interface.name }}_ADDR;
{%- if interface.mask %}
          access_mask_{{ domain.name }}_{{ interface.name }} <= {{ interface.name }}_MASK;
{%- endif %}
        end
{%- endfor %}

      end 

{%- for interface in domain.interfaces %}
      if(!{{ domain.name }}_DRIVE && access_wait_{{ domain.name }}_{{ interface.name }} && !access_done_{{ domain.name }}_{{ interface.name }} && {{ interface.name }}_LRDY) begin
        access_done_{{ domain.name }}_{{ interface.name }} <= 1;
{%- if interface.mode == 'readwrite' or interface.mode == 'read' %}
        access_q_{{ domain.name }}_{{ interface.name }} <= {{ interface.name }}_LQ;
{%- endif %}
      end
{%- endfor %}

{%- endfor %}  

    end
  end

{%- for domain in domains %}
  generate if(WITH_CHANNEL) begin
    assign {{ domain.name }}_slave_drive_out = next_ready_{{ domain.name }} && {{ domain.name }}_master_drive_in;  
    assign {{ domain.name }}_master_drive_out = next_ready_{{ domain.name }} && {{ domain.name }}_slave_drive_in;
    assign {{ domain.name }}_DRIVE = next_ready_{{ domain.name }} && {{ domain.name }}_master_drive_in && {{ domain.name }}_slave_drive_in;
  end else begin
    assign {{ domain.name }}_slave_drive_out = next_ready_{{ domain.name }};
    assign {{ domain.name }}_master_drive_out = next_ready_{{ domain.name }};
    assign {{ domain.name }}_DRIVE = next_ready_{{ domain.name }};
  end endgenerate
{%- endfor %}    
  
endmodule 



