module SYRUP_MEMORYSYSTEM
  (CLK, RST,
{%- for domain in domains %}
   //----------------------------------------------------------------------------
   // Domain {{ domain.name }}
   //----------------------------------------------------------------------------
{%- for interface in domain.interfaces %}
   // Connected to Logic {{ interface.name }}
   {{ interface.name }}_ADDR, {% if interface.mode == 'readwrite' or interface.mode == 'read' %}{{ interface.name }}_RE, {{ interface.name }}_Q, {% endif %}{% if interface.mode == 'readwrite' or interface.mode == 'write' %}{{ interface.name }}_WE, {{ interface.name }}_D, {% endif %}{% if interface.mask %}{{ interface.name }}_MASK, {% endif %}
{%- endfor %}
   // Drive signal for domain {{ domain.name }}
   {{ domain.name }}_DRIVE,
   {{ domain.name }}_slave_drive_in,
   {{ domain.name }}_slave_drive_out,
   {{ domain.name }}_master_drive_in,
   {{ domain.name }}_master_drive_out,
{%- for space in domain.spaces %}
   // Performance Counter output {{ space }}
   {{ domain.name }}_{{ space }}_cycle_idle,
   {{ domain.name }}_{{ space }}_cycle_hit,
   {{ domain.name }}_{{ space }}_cycle_miss,
   {{ domain.name }}_{{ space }}_cycle_conflict,
   {{ domain.name }}_{{ space }}_cycle_wait,
   {{ domain.name }}_{{ space }}_num_miss,
{%- endfor %}
{%- endfor %}
   reset_performance_count,
   //----------------------------------------------------------------------------
   // Off-chip Memory Interface
   //----------------------------------------------------------------------------
   MEM_ADDR, MEM_RE, MEM_WE, MEM_D, MEM_Q, MEM_RDY
   );

  parameter WITH_CHANNEL = 0;
  parameter ASYNC = 1;
  
  input CLK;
  input RST;

{%- for domain in domains %}
  //----------------------------------------------------------------------------
  // Domain {{ domain.name }}
  //----------------------------------------------------------------------------
{%- for interface in domain.interfaces %}
  // Connected to Logic {{ interface.name }}
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
  // Drive signal for domain {{ domain.name }}
  output {{ domain.name }}_DRIVE;
  input {{ domain.name }}_slave_drive_in;
  output {{ domain.name }}_slave_drive_out;
  input {{ domain.name }}_master_drive_in;
  output {{ domain.name }}_master_drive_out;
{%- for space in domain.spaces %}
  // Performance Counter output {{ space }}
  output [63:0] {{ domain.name }}_{{ space }}_cycle_idle;
  output [63:0] {{ domain.name }}_{{ space }}_cycle_hit;
  output [63:0] {{ domain.name }}_{{ space }}_cycle_miss;
  output [63:0] {{ domain.name }}_{{ space }}_cycle_conflict;
  output [63:0] {{ domain.name }}_{{ space }}_cycle_wait;
  output [63:0] {{ domain.name }}_{{ space }}_num_miss;
{%- endfor %}
{%- endfor %}
  input reset_performance_count;

  //----------------------------------------------------------------------------
  // Off-chip Memory Interface
  //----------------------------------------------------------------------------
  output [{{ offchipmemory.addrlen-1 }}:0] MEM_ADDR;
  output MEM_RE;
  output MEM_WE;
  output [{{ offchipmemory.datawidth-1 }}:0] MEM_D;
  input  [{{ offchipmemory.datawidth-1 }}:0] MEM_Q;
  input MEM_RDY;

  //---------------------------------------------------------------------------
  // Domain Controller
  //---------------------------------------------------------------------------
{% for domain in domains %}
{%- for interface in domain.interfaces %}
  wire [{{ interface.addrlen-1 }}:0] {{ interface.name }}_LADDR;
  wire {{ interface.name }}_LRE;
  wire [{{ interface.datawidth-1 }}:0] {{ interface.name }}_LQ;
  wire {{ interface.name }}_LWE;
  wire [{{ interface.datawidth-1 }}:0] {{ interface.name }}_LD;
  wire [{{ interface.maskwidth-1 }}:0] {{ interface.name }}_LMASK;
  wire {{ interface.name }}_LRDY;
  wire {{ interface.name }}_LINIT_DONE;
{%- endfor %}
{%- endfor %}  

  DOMAINCONTROLLER #
    (
     .WITH_CHANNEL(WITH_CHANNEL)
    )
  inst_domaincontroller
    (.CLK(CLK), .RST(RST),
{%- for domain in domains %}
{%- for interface in domain.interfaces %}
     .{{ interface.name }}_ADDR({{ interface.name }}_ADDR),
{%- if interface.mode == 'readwrite' or interface.mode == 'read' %}
     .{{ interface.name }}_RE({{ interface.name }}_RE),
     .{{ interface.name }}_Q({{ interface.name }}_Q),
{%- endif %}
{%- if interface.mode == 'readwrite' or interface.mode == 'write' %}
     .{{ interface.name }}_WE({{ interface.name }}_WE),
     .{{ interface.name }}_D({{ interface.name }}_D),
{%- endif %}
{%- if interface.mask %}
     .{{ interface.name }}_MASK({{ interface.name }}_MASK),
{%- endif %}
{%- endfor %}
{%- for interface in domain.interfaces %}
     .{{ interface.name }}_LADDR({{ interface.name }}_LADDR),
{%- if interface.mode == 'readwrite' or interface.mode == 'read' %}
     .{{ interface.name }}_LRE({{ interface.name }}_LRE),
     .{{ interface.name }}_LQ({{ interface.name }}_LQ),
{%- endif %}
{%- if interface.mode == 'readwrite' or interface.mode == 'write' %}
     .{{ interface.name }}_LWE({{ interface.name }}_LWE),
     .{{ interface.name }}_LD({{ interface.name }}_LD),
{%- endif %}
{%- if interface.mask %}
     .{{ interface.name }}_LMASK({{ interface.name }}_LMASK),
{%- endif %}
     .{{ interface.name }}_LRDY({{ interface.name }}_LRDY),
     .{{ interface.name }}_LINIT_DONE({{ interface.name }}_LINIT_DONE),
{%- endfor %}
     .{{ domain.name }}_slave_drive_in({{ domain.name }}_slave_drive_in),
     .{{ domain.name }}_slave_drive_out({{ domain.name }}_slave_drive_out),
     .{{ domain.name }}_master_drive_in({{ domain.name }}_master_drive_in),
     .{{ domain.name }}_master_drive_out({{ domain.name }}_master_drive_out),
     .{{ domain.name }}_DRIVE({{ domain.name }}_DRIVE){%- if loop.index < numdomains %}, {%- endif %}
{%- endfor %}
     );

{%- for domain in domains %}
{%- for interface in domain.interfaces %}
{%- if interface.mode == 'write' %}
  assign {{ interface.name }}_LRE = 1'b0;
{%- endif %}
{%- if interface.mode == 'read' %}
  assign {{ interface.name }}_LWE = 1'b0;
  assign {{ interface.name }}_LD = 0;
{%- endif %}
{%- if not interface.mask %}
  assign {{ interface.name }}_LMASK = ~0;
{%- endif %}
{%- endfor %}
{%- endfor %}

  //---------------------------------------------------------------------------
  // Performance Counter
  //---------------------------------------------------------------------------
`ifdef ENABLE_PERFORMANCECOUNTER
  PERFORMANCECOUNTER inst_performancecounter
   (.CLK(CLK), .RST(RST),
{%- for domain in domains %}
    .{{ domain.name }}_DRIVE({{ domain.name }}_DRIVE),
{%- for interface in domain.interfaces %}
    .{{ interface.name }}_LRE({{ interface.name }}_LRE),
    .{{ interface.name }}_LWE({{ interface.name }}_LWE),
    .{{ interface.name }}_LRDY({{ interface.name }}_LRDY),
{%- endfor %}
{%- for space in domain.spaces %}
    .{{ domain.name }}_{{ space }}_cycle_idle({{ domain.name }}_{{ space }}_cycle_idle),
    .{{ domain.name }}_{{ space }}_cycle_hit({{ domain.name }}_{{ space }}_cycle_hit),
    .{{ domain.name }}_{{ space }}_cycle_miss({{ domain.name }}_{{ space }}_cycle_miss),
    .{{ domain.name }}_{{ space }}_cycle_conflict({{ domain.name }}_{{ space }}_cycle_conflict),
    .{{ domain.name }}_{{ space }}_cycle_wait({{ domain.name }}_{{ space }}_cycle_wait),
    .{{ domain.name }}_{{ space }}_num_miss({{ domain.name }}_{{ space }}_num_miss),
{%- endfor %}
{%- endfor %}
    .reset_count(reset_performance_count)
   );
`endif

  //---------------------------------------------------------------------------
  // Scratchpad / Cache
  //---------------------------------------------------------------------------
{%- for memoryspace in memoryspacelist %}
{%- for port in range(memoryspace.numports) %}
  wire [{{ memoryspace.addrlen-1 }}:0] {{ memoryspace.name }}_ADDR{{ port }};
  wire {{ memoryspace.name }}_RE{{ port }};
  wire [{{ memoryspace.datawidth-1 }}:0] {{ memoryspace.name }}_Q{{ port }};
  wire {{ memoryspace.name }}_WE{{ port }};
  wire [{{ memoryspace.datawidth-1 }}:0] {{ memoryspace.name }}_D{{ port }};
  wire [{{ memoryspace.maskwidth-1 }}:0] {{ memoryspace.name }}_MASK{{ port }};
  wire {{ memoryspace.name }}_READY{{ port }};
  wire {{ memoryspace.name }}_INIT_DONE{{ port }};
  wire {{ memoryspace.name }}_WBACK{{ port }};
  wire [{{ memoryspace.addrlen-1 }}:0] {{ memoryspace.name }}_WBADDR{{ port }};
{%- endfor %}

{%- if memoryspace.memtype == 'cache' %}
  wire {{ memoryspace.name }}_EN;
  wire {{ memoryspace.name }}_FLUSH;
  assign {{ memoryspace.name }}_EN = 1'b1;
  assign {{ memoryspace.name }}_FLUSH = 1'b0;
  wire [{{ memoryspace.addrlen-1 }}:0] {{ memoryspace.name }}_CACHE_ADDR;
  wire {{ memoryspace.name }}_CACHE_RE;
  wire [{{ memoryspace.cache_linewidth-1 }}:0] {{ memoryspace.name }}_CACHE_Q;
  wire {{ memoryspace.name }}_CACHE_WE;
  wire [{{ memoryspace.cache_linewidth-1 }}:0] {{ memoryspace.name }}_CACHE_D;
  wire {{ memoryspace.name }}_CACHE_RDY;
{%- endif %}

  {{ memoryspace.name }}
    #(.W_D({{ memoryspace.datawidth }}), .W_A({{ memoryspace.addrlen }}),
      .W_MASK({{ memoryspace.maskwidth }}), .W_WORD_A({{ memoryspace.word_addrlen }}))
  inst_{{ memoryspace.name }}
    (.CLK(CLK), .RST(RST),
{%- for port in range(memoryspace.numports) %}
     .ADDR{{ port }}({{ memoryspace.name }}_ADDR{{ port }}),
     .RE{{ port }}({{ memoryspace.name }}_RE{{ port }}),
     .Q{{ port }}({{ memoryspace.name }}_Q{{ port }}),
     .WE{{ port }}({{ memoryspace.name }}_WE{{ port }}),
     .D{{ port }}({{ memoryspace.name }}_D{{ port }}),
     .MASK{{ port }}({{ memoryspace.name }}_MASK{{ port }}),
{%- if memoryspace.memtype == 'cache' %}
     .WBACK{{ port }}({{ memoryspace.name }}_WBACK{{ port }}),
     .WBADDR{{ port }}({{ memoryspace.name }}_WBADDR{{ port }}),
{%- endif %}
     .INIT_DONE{{ port }}({{ memoryspace.name }}_INIT_DONE{{ port }}),
     .READY{{ port }}({{ memoryspace.name }}_READY{{ port }}){% if port < memoryspace.numports-1 or memoryspace.memtype == 'cache' %},{% endif %}
{%- endfor %}
{%- if memoryspace.memtype == 'cache' %}
     .EN({{ memoryspace.name }}_EN),
     .FLUSH({{ memoryspace.name }}_FLUSH),
     .MEM_ADDR({{ memoryspace.name }}_CACHE_ADDR),
     .MEM_RE({{ memoryspace.name }}_CACHE_RE),
     .MEM_Q({{ memoryspace.name }}_CACHE_Q),
     .MEM_WE({{ memoryspace.name }}_CACHE_WE),
     .MEM_D({{ memoryspace.name }}_CACHE_D),
     .MEM_RDY({{ memoryspace.name }}_CACHE_RDY)
{%- endif %}
     );


{%- for accessor in memoryspace.accessors %}
  assign {{ memoryspace.name }}_ADDR{{ loop.index0 }} = {{ accessor }}_LADDR;
  assign {{ memoryspace.name }}_RE{{ loop.index0 }} = {{ accessor }}_LRE;
  assign {{ accessor }}_LQ = {{ memoryspace.name }}_Q{{ loop.index0 }};
  assign {{ memoryspace.name }}_WE{{ loop.index0 }} = {{ accessor }}_LWE;
  assign {{ memoryspace.name }}_D{{ loop.index0 }} = {{ accessor }}_LD;
  assign {{ memoryspace.name }}_MASK{{ loop.index0 }} = {{ accessor }}_LMASK;
  assign {{ accessor }}_LRDY = {{ memoryspace.name }}_READY{{ loop.index0 }};
  assign {{ accessor }}_LINIT_DONE = {{ memoryspace.name }}_INIT_DONE{{ loop.index0 }};
  assign {{ memoryspace.name }}_WBACK{{ loop.index0 }} = 1'b0;
  assign {{ memoryspace.name }}_WBADDR{{ loop.index0 }} = 0;
{%- endfor %}  
{%- endfor %}  


{%- if offchipmemory.numports > 0 %}
  //---------------------------------------------------------------------------
  // Marshaller
  //---------------------------------------------------------------------------

{%- for memoryspace in memoryspacelist %}
  wire [{{ memoryspace.addrlen-1 }}:0] {{ memoryspace.name }}_MARSHAL_ADDR;
  wire {{ memoryspace.name }}_MARSHAL_RE;
  wire [{{ offchipmemory.datawidth-1 }}:0] {{ memoryspace.name }}_MARSHAL_Q;
  wire {{ memoryspace.name }}_MARSHAL_WE;
  wire [{{ offchipmemory.datawidth-1 }}:0] {{ memoryspace.name }}_MARSHAL_D;
  wire {{ memoryspace.name }}_MARSHAL_RDY;
  MARSHALLER_{{ memoryspace.name }}
    #(.W_A({{ memoryspace.addrlen }}))
  inst_marsher_{{ memoryspace.name }}
    (.CLK(CLK), .RST(RST),
    .UP_ADDR({{ memoryspace.name }}_CACHE_ADDR),
    .UP_D({{ memoryspace.name }}_CACHE_D),
    .UP_WE({{ memoryspace.name }}_CACHE_WE),
    .UP_RE({{ memoryspace.name }}_CACHE_RE),
    .UP_Q({{ memoryspace.name }}_CACHE_Q),
    .UP_RDY({{ memoryspace.name }}_CACHE_RDY),
    .MEM_ADDR({{ memoryspace.name }}_MARSHAL_ADDR),
    .MEM_D({{ memoryspace.name }}_MARSHAL_D),
    .MEM_WE({{ memoryspace.name }}_MARSHAL_WE),
    .MEM_RE({{ memoryspace.name }}_MARSHAL_RE),
    .MEM_Q({{ memoryspace.name }}_MARSHAL_Q),
    .MEM_RDY({{ memoryspace.name }}_MARSHAL_RDY)
    );
{%- endfor %}  

  //---------------------------------------------------------------------------
  // Address Mapper
  //---------------------------------------------------------------------------

{%- for memoryspace in memoryspacelist %}
  wire [{{ offchipmemory.addrlen-1 }}:0] {{ memoryspace.name }}_MAPPED_MARSHAL_ADDR;
  ADDRMAP_{{ memoryspace.name }}
    #(.W_UP_A({{ memoryspace.addrlen }}), .W_DOWN_A({{ offchipmemory.addrlen }}))
  inst_ADDRMAP_{{ memoryspace.name }}
    (.UP_ADDR({{ memoryspace.name }}_MARSHAL_ADDR),
     .DOWN_ADDR({{ memoryspace.name }}_MAPPED_MARSHAL_ADDR)
    );
{%- endfor %}  

  //---------------------------------------------------------------------------
  // Off-chip Memory Arbiter
  //---------------------------------------------------------------------------
  {{ offchipmemory.name }}
    #(.W_OFF_A({{ offchipmemory.addrlen }}), .W_OFF_D({{ offchipmemory.datawidth }}))
  inst_{{ offchipmemory.name }}
    (.CLK(CLK), .RST(RST),
{%- for memoryspace in memoryspacelist %}
     .ADDR{{ loop.index0 }}({{ memoryspace.name }}_MAPPED_MARSHAL_ADDR),
     .RE{{ loop.index0 }}({{ memoryspace.name }}_MARSHAL_RE),
     .Q{{ loop.index0 }}({{ memoryspace.name }}_MARSHAL_Q),
     .WE{{ loop.index0 }}({{ memoryspace.name }}_MARSHAL_WE),
     .D{{ loop.index0 }}({{ memoryspace.name }}_MARSHAL_D),
     .RDY{{ loop.index0 }}({{ memoryspace.name }}_MARSHAL_RDY),
{%- endfor %}  
     .MEM_ADDR(MEM_ADDR),
     .MEM_RE(MEM_RE),
     .MEM_Q(MEM_Q),    
     .MEM_WE(MEM_WE),
     .MEM_D(MEM_D),
     .MEM_RDY(MEM_RDY)
     );

{%- else %}

  // Unused Off-chip Memory
  assign MEM_ADDR = 0;
  assign MEM_RE = 1'b0;
  assign MEM_WE = 1'b0;
  assign MEM_D = 0;

{%- endif %}

endmodule  



