//------------------------------------------------------------------------------
// Cache
//------------------------------------------------------------------------------
module {{ name }}
 (CLK, RST, EN, FLUSH,
{%- for port in range(numports) %}
  ADDR{{ port }}, RE{{ port }}, WE{{ port }}, MASK{{ port }}, D{{ port }}, Q{{ port }}, READY{{ port }}, INIT_DONE{{ port }}, WBACK{{ port }}, WBADDR{{ port }},
{%- endfor %}
  MEM_ADDR, MEM_D, MEM_WE, MEM_RE, MEM_Q, MEM_RDY);
  parameter W_D = {{ datawidth }};
  parameter W_A = {{ addrlen }};
  parameter W_MASK = {{ maskwidth }};
  parameter W_WORD_A = {{ word_addrlen }};
  parameter W_OFFSET = {{ addroffset }};
  parameter NUMPORTS = {{ numports }};

  parameter WAY = {{ numways }};
  parameter W_LINE = {{ linewidth }}; //W_D x N_WORD_PER_LINE
  parameter N_LINE = {{ numlines }}; //the num of lines
 
  parameter N_BYTE_PER_LINE = {{ linesize }};
  parameter N_WORD_PER_LINE = {{ wordperline }};
  parameter W_WORD_PER_LINE = {{ wordperlinewidth }};
  parameter W_INDEX = {{ indexwidth }};//2 ^ W_INDEX = N_LINE. width of cache line addr

  input CLK, RST;
  input EN; //Cache Enable
  input FLUSH;
  
{%- for port in range(numports) %}
  input  [W_A-1:0]               ADDR{{ port }};
  input                          RE{{ port }};
  input                          WE{{ port }};
  input  [W_MASK-1:0]            MASK{{ port }};
  input  [W_D-1:0]               D{{ port }};
  output [W_D-1:0]               Q{{ port }};
  output                         READY{{ port }};
  output                         INIT_DONE{{ port }};
  input                          WBACK{{ port }}; //Cache flush
  input  [W_A-1:0]               WBADDR{{ port }};
{%- endfor %}

  output [W_A-1:0]               MEM_ADDR; //byte addressing
  output [W_LINE-1:0]            MEM_D;
  output                         MEM_WE;
  output                         MEM_RE;
  input [W_LINE-1:0]             MEM_Q;
  input                          MEM_RDY;
  
  wire [W_A-1:0]                 lower_addr;
  wire [W_D-1:0]                 lower_d;
  wire [W_MASK-1:0]              lower_we;
  wire [W_MASK-1:0]              lower_re;
  wire [W_D-1:0]                 lower_q;
  wire                           lower_ready;
  wire                           lower_init_done;
  wire                           lower_wback; //Cache flush
  wire [W_A-1:0]                 lower_wbaddr;

  wire                           lower_en;
  wire                           lower_flush;
  
{%- for port in range(numports) %}
  wire req{{ port }};
  assign req{{ port }} = (WE{{ port }} || RE{{ port }} || WBACK{{ port }});
{%- endfor %}

  reg [7:0] locked;
  wire [7:0] next_locked;
  reg busy;
  wire next_busy;

  assign lower_addr = {%- for port in range(numports) %}
                      (next_locked == {{ port }})? ADDR{{ port }} :
                      {%- endfor %}
                      'hx;
  assign lower_d = {%- for port in range(numports) %}
                   (next_locked == {{ port }})? D{{ port }} :
                   {%- endfor %}
                   'hx;
  assign lower_we = (!next_busy)? 'b0:
                    {%- for port in range(numports) %}
                    (next_locked == {{ port }})? (WE{{ port }})?MASK{{ port }}:0 :
                    {%- endfor %}
                    0;
  assign lower_re = (!next_busy)? 'b0:
                    {%- for port in range(numports) %}
                    (next_locked == {{ port }})? (RE{{ port }})?MASK{{ port }}:0 :
                    {%- endfor %}
                    0;
{%- for port in range(numports) %}
  assign Q{{ port }} = lower_q;
{%- endfor %}
{%- for port in range(numports) %}
  assign READY{{ port }} = busy && (locked == {{ port }}) && lower_ready;
  assign INIT_DONE{{ port }} = lower_init_done;
{%- endfor %}
  assign lower_wback = {%- for port in range(numports) %}
                       (next_locked == {{ port }})? WBACK{{ port }} :
                       {%- endfor %}
                       0;
  assign lower_wbaddr = {%- for port in range(numports) %}
                        (next_locked == {{ port }})? WBADDR{{ port }} :
                        {%- endfor %}
                        'hx;
  assign lower_en = EN;
  assign lower_flush = FLUSH;
  
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

  CACHE_{{ name }}
  #(.W_D(W_D), .W_A(W_A), .W_MASK(W_MASK), .W_OFFSET(W_OFFSET),
    .WAY(WAY), .W_LINE(W_LINE), .N_LINE(N_LINE),
    .N_BYTE_PER_LINE(N_BYTE_PER_LINE), .N_WORD_PER_LINE(N_WORD_PER_LINE),
    .W_WORD_PER_LINE(W_WORD_PER_LINE), .W_INDEX(W_INDEX))
  cache
  (.CLK(CLK), .RST(RST),
   .ADDR(lower_addr), .D(lower_d), .WE(lower_we), .RE(lower_re), .Q(lower_q), 
   .READY(lower_ready), .EN(lower_en), .INIT_DONE(lower_init_done),
   .WBACK(lower_wback), .WBADDR(lower_wbaddr), .FLUSH(lower_flush),
   .MEM_ADDR(MEM_ADDR), .MEM_D(MEM_D), .MEM_WE(MEM_WE), .MEM_RE(MEM_RE),
   .MEM_Q(MEM_Q), .MEM_RDY(MEM_RDY)
   );
  
endmodule

//------------------------------------------------------------------------------  
module CACHE_{{ name }}
  (CLK, RST,
   ADDR, D, WE, RE, Q, READY, EN, WBACK, WBADDR, FLUSH, INIT_DONE,
   MEM_ADDR, MEM_D, MEM_WE, MEM_RE, MEM_Q, MEM_RDY);

  //----------------------------------------------------------------------------
  // Parameter
  //----------------------------------------------------------------------------
  parameter W_D = {{ datawidth }};
  parameter W_A = {{ addrlen }};
  parameter W_MASK = {{ maskwidth }};
  parameter W_OFFSET = {{ addroffset }};
  
  parameter WAY = {{ numways }};
  parameter W_LINE = {{ linewidth }}; //W_D x N_WORD_PER_LINE
  parameter N_LINE = {{ numlines }}; //the num of lines
  
  parameter N_BYTE_PER_LINE = {{ linesize }};
  parameter N_WORD_PER_LINE = {{ wordperline }};
  parameter W_WORD_PER_LINE = {{ wordperlinewidth }};
  parameter W_INDEX = {{ indexwidth }};//2 ^ W_INDEX = N_LINE. width of cache line addr
  
  localparam W_INDEX_OFFSET = W_OFFSET + W_WORD_PER_LINE; // = W_OFFSET + log(N_WORD_PER_LINE)
  localparam W_TAG = W_A - (W_INDEX_OFFSET + W_INDEX);
  localparam W_STATUS = 3; //valid, dirty, accessed
  localparam W_ATTR = W_TAG + W_STATUS;

  localparam W_B = 8;
  localparam W_4B = W_B * 4;
  localparam N_4B_PER_LINE = W_LINE / W_4B;
  
  //State Machine
  localparam INIT  = 0;
  localparam RDY   = 1;
  localparam WRITE = 2;
  localparam READ  = 3;
  localparam WB    = 4;
  localparam FL    = 5;

  //----------------------------------------------------------------------------
  // Input / Output
  //----------------------------------------------------------------------------
  input CLK, RST;

  input                          EN;
  
  input  [W_A-1:0]               ADDR;
  input  [W_D-1:0]               D;
  input  [W_MASK-1:0]            WE;
  input  [W_MASK-1:0]            RE;
  output [W_D-1:0]               Q;
  output                         READY;
  input                          WBACK;
  input  [W_A-1:0]               WBADDR;
  input                          FLUSH;
  output reg                     INIT_DONE;
  
  output reg [W_A-1:0]           MEM_ADDR;
  output reg [W_LINE-1:0]        MEM_D;
  output reg                     MEM_WE;
  output reg                     MEM_RE;
  input  [W_LINE-1:0]            MEM_Q;
  input                          MEM_RDY;

  //------------------------------------------------------------------------------
  // Functions
  //------------------------------------------------------------------------------
  function [W_INDEX-1:0] get_index;
    input [W_A-1:0] in;
    get_index = in[W_A-1:W_INDEX_OFFSET];
  endfunction 
  
  function [W_WORD_PER_LINE-1:0] get_word_pos;
    input [W_A-1:0] in;
    get_word_pos = in[W_A-1:W_OFFSET];
  endfunction
  
  function [W_TAG-1:0] get_tag;
    input [W_A-1:0] in;
    get_tag = in[W_A-1:(W_INDEX_OFFSET + W_INDEX)];
  endfunction
  
  function [W_D-1:0] get_data;
    input [W_LINE-1:0] in;
    input [W_A-1:0] addr;
    reg [W_LINE-1:0] tmp;
    integer i;
    begin
      if(W_LINE == W_D) begin
        get_data = in;
      end else begin
        tmp = in;
        for(i=0; i<N_WORD_PER_LINE; i=i+1) begin
          if(i == get_word_pos(addr)) begin
            get_data = tmp[W_D-1:0];
          end
          tmp = tmp[W_LINE-1:W_D];
        end
      end
    end
  endfunction
  
  function [W_A-1:0] addr_mask;
    input [W_A-1:0] in;
    addr_mask = { in[W_A-1:W_INDEX_OFFSET], {W_INDEX_OFFSET{1'b0}} };
  endfunction
  
  function [W_A-1:0] wb_addr;
    input [W_INDEX-1:0] index;
    input [W_TAG-1:0] tag;
    wb_addr = { {tag,index}, {W_INDEX_OFFSET{1'b0}} };
  endfunction
  
  
  function [N_BYTE_PER_LINE-1:0] write_mask;
    input [W_A-1:0] addr;
    input [W_MASK-1:0] we;
    reg [N_BYTE_PER_LINE-1:0] mask;
    reg [W_MASK-1:0] tmp;
    integer i;
    begin
      if(N_BYTE_PER_LINE == W_MASK) begin
        write_mask = we;
      end else begin
        for(i=0; i<N_WORD_PER_LINE; i=i+1) begin
          tmp = (get_word_pos(addr) == i)? {W_MASK{1'b1}} : {W_MASK{1'b0}};
          mask = { tmp, mask[N_BYTE_PER_LINE-1:W_MASK] };
        end
        write_mask = mask & {N_WORD_PER_LINE{we}};
      end
    end
  endfunction

  function [W_STATUS-1:0] set_status;
    input valid;
    input dirty;
    input accessed;
    set_status = {valid, dirty, accessed};
  endfunction

  function [W_ATTR-1:0] set_attr;
    input [W_STATUS-1:0] status;
    input [W_TAG-1:0] tag;
    set_attr = {status, tag};
  endfunction
  
  function [W_STATUS-1:0] attr_status;
    input [W_ATTR-1:0] attr;
    attr_status = attr[W_ATTR-1:W_TAG];
  endfunction

  function [W_TAG-1:0] attr_tag;
    input [W_ATTR-1:0] attr;
    attr_tag = attr[W_TAG-1:0];
  endfunction

  function [0:0] attr_valid;
    input [W_ATTR-1:0] attr;
    reg [W_STATUS-1:0] status;
    begin
      status = attr_status(attr);
      attr_valid = status[2];
    end
  endfunction

  function [0:0] attr_dirty;
    input [W_ATTR-1:0] attr;
    reg [W_STATUS-1:0] status;
    begin
      status = attr_status(attr);
      attr_dirty = status[1];
    end
  endfunction

  function [0:0] attr_accessed;
    input [W_ATTR-1:0] attr;
    reg [W_STATUS-1:0] status;
    begin
      status = attr_status(attr);
      attr_accessed = status[0];
    end
  endfunction

  function [WAY-1:0] lru;
    input [WAY-1:0] accessed;
    input [WAY-1:0] random;
    reg [WAY-1:0] ret;
    integer i;
    begin
      if(WAY == 1) begin
        lru = 'b1;
      end else begin
        ret = 0;
        for(i=0; i<WAY; i=i+1) begin
          if(accessed[i] == 0)
            ret = 1'b1 << i;
        end
        if(ret == 0)
          lru = random;
        else
          lru = ret;
      end
    end
  endfunction
  
  //----------------------------------------------------------------------------
  // delay buffer for write
  //----------------------------------------------------------------------------  
  reg    [W_A-1:0]               d_ADDR;
  reg    [W_D-1:0]               d_D;
  reg    [W_MASK-1:0]            d_WE;
  reg    [W_MASK-1:0]            d_RE;
  reg                            d_WBACK;
  reg    [W_A-1:0]               d_WBADDR;
  reg                            d_FLUSH;
  
  //----------------------------------------------------------------------------
  // Cache Data/Tag/Status Memory Port Signals
  //----------------------------------------------------------------------------  
  //Read
  wire   [W_INDEX-1:0]           core_read_index;
  
  wire   [W_LINE-1:0]            core_read_q [0:WAY-1];
  wire   [W_TAG-1:0]             core_read_tag_q [0:WAY-1];
  wire   [W_STATUS-1:0]          core_read_status_q [0:WAY-1];
  wire   [W_ATTR-1:0]            core_read_attr_q [0:WAY-1];

  wire   [W_LINE-1:0]            t_core_read_q [0:WAY-1];
  wire   [W_ATTR-1:0]            t_core_read_attr_q [0:WAY-1];

  //Update
  wire   [W_INDEX-1:0]           update_index;
  wire   [WAY-1:0]               update_way;
  
  wire   [W_LINE-1:0]            update_d;
  wire   [N_BYTE_PER_LINE-1:0]   update_we;
  wire   [W_LINE-1:0]            update_q [0:WAY-1];

  wire   [W_TAG-1:0]             update_tag_d [0:WAY-1];
  wire   [W_STATUS-1:0]          update_status_d [0:WAY-1];
  wire   [W_ATTR-1:0]            update_attr_d [0:WAY-1];
  wire                           update_attr_we;
  wire   [W_ATTR-1:0]            update_attr_q [0:WAY-1];

  //Bypass
  reg    [N_4B_PER_LINE-1:0]     core_read_bypass [0:WAY-1];
  reg    [WAY-1:0]               core_read_attr_bypass;

  //Write
  wire   [W_INDEX-1:0]           core_write_index;
  wire   [WAY-1:0]               core_write_way;
  
  wire   [W_LINE-1:0]            core_write_d;
  wire   [N_BYTE_PER_LINE-1:0]   core_write_we;
  
  wire   [W_STATUS-1:0]          core_write_status_d;
  wire   [W_ATTR-1:0]            core_write_attr_d;
  wire                           core_write_attr_we;
  
  //External Read/Write
  reg    [W_INDEX-1:0]           ext_index;
  reg    [WAY-1:0]               ext_way;

  reg    [W_LINE-1:0]            ext_d;
  reg    [N_BYTE_PER_LINE-1:0]   ext_we;
  wire   [W_LINE-1:0]            ext_q [0:WAY-1];

  wire   [W_ATTR-1:0]            ext_attr_q [0:WAY-1];
  wire   [WAY-1:0]               ext_dirty;

  wire   [W_TAG-1:0]             ext_tag_q;
  reg    [W_TAG-1:0]             ext_tag_d;
  reg                            ext_tag_we;

  //Initialize
  reg    [W_INDEX-1:0]           init_index;
  
  //----------------------------------------------------------------------------
  // Replacement
  //----------------------------------------------------------------------------
  wire   [WAY-1:0]               core_read_valid;
  wire   [WAY-1:0]               core_read_dirty;
  wire   [WAY-1:0]               core_read_accessed;
  wire   [WAY-1:0]               core_read_hit_way;

  wire   [WAY-1:0]               update_valid;
  wire   [WAY-1:0]               update_dirty;
  wire   [WAY-1:0]               update_accessed;

  wire   [W_LINE-1:0]            core_read_q_wb;
  wire   [W_TAG-1:0]             core_read_tag_q_wb;
  wire   [WAY-1:0]               lru_selected;

  wire   [W_TAG-1:0]             current_tag;

  reg    [WAY-1:0]               replace_way;
  reg    [W_A-1:0]               replace_addr;
  
  reg    [W_A-1:0]               writeback_addr;
  reg    [W_LINE-1:0]            writeback_data;

  reg    [WAY-1:0]               writeback_way_cnt;


  //----------------------------------------------------------------------------
  // State Machine
  //----------------------------------------------------------------------------
  reg    [2:0]                   state;
  reg    [2:0]                   mini_state;

  //----------------------------------------------------------------------------
  // Random Counter for Semi-LRU replacement
  //----------------------------------------------------------------------------
  reg [WAY-1:0] random_cnt;
  generate if(WAY == 1) begin: numway_eq_1
    always @(posedge CLK) begin
      if(RST) begin
        random_cnt     <= 'b1;
      end else begin
        if(state == RDY) begin
          random_cnt <= 1'b1;
        end
      end
    end
  end else begin: numway_neq_1
    always @(posedge CLK) begin
      if(RST) begin
        random_cnt     <= 'b1;
      end else begin
        if(state == RDY) begin
          random_cnt <= {random_cnt[0], random_cnt[WAY-1:1]};
        end
      end
    end
  end endgenerate

  //------------------------------------------------------------------------------
  // Data / Tag / Status Memory 
  //------------------------------------------------------------------------------
  genvar p, w;
  generate for (w=0; w<WAY; w=w+1) begin: way
    // Bybass logic for BRAM port confliction
    always @(posedge CLK) begin
      if(RST) begin
        core_read_attr_bypass[w] <= 1'b0;
      end else begin
        core_read_attr_bypass[w] <= (core_read_index == update_index) &&
                                    (update_attr_we && update_way[w]);
      end
    end
    assign core_read_attr_q[w] = (core_read_attr_bypass[w])?
                                 update_attr_q[w]:
                                 t_core_read_attr_q[w];
    
    CACHE_ATTR_{{ name }} 
     #(.W_A(W_A), .W_INDEX(W_INDEX), .N_LINE(N_LINE), .W_ATTR(W_ATTR))
    attr
     (.CLK(CLK), 
      .A0(core_read_index), 
      .D0({W_ATTR{1'b0}}),
      .WE0(1'b0),
      .Q0(t_core_read_attr_q[w]),
      .A1(update_index),
      .D1(update_attr_d[w]), 
      .WE1(update_attr_we && update_way[w]),
      .Q1(update_attr_q[w])
      );
    
    for (p=0; p<N_4B_PER_LINE; p=p+1) begin: word_pos
      // Bybass logic for BRAM port confliction
      always @(posedge CLK) begin
        if(RST) begin
          core_read_bypass[w][p] <= 1'b0;
        end else begin
          core_read_bypass[w][p] <= (core_read_index == update_index) &&
                                    (update_way[w]) &&
                                    (update_we[W_MASK*(p+1)-1:W_MASK*p] != 0);
        end
      end
      assign core_read_q[w][W_4B*(p+1)-1:W_4B*p] = (core_read_bypass[w][p])?
                                             update_q[w][W_4B*(p+1)-1:W_4B*p]:
                                             t_core_read_q[w][W_4B*(p+1)-1:W_4B*p];

      CACHE_BANKED_MEM_{{ name }}
       #(.W_A(W_A), .W_INDEX(W_INDEX), .N_LINE(N_LINE))
      mem
       (.CLK(CLK),
        .A0(core_read_index),
        .D0({W_4B{1'b0}}),
        .WE0({W_MASK{1'b0}}),
        .Q0(t_core_read_q[w][W_4B*(p+1)-1:W_4B*p]),
        .A1(update_index), 
        .D1(update_d[W_4B*(p+1)-1:W_4B*p]),
        .WE1(update_way[w]? update_we[W_MASK*(p+1)-1:W_MASK*p] : {W_MASK{1'b0}}),
        .Q1(update_q[w][W_4B*(p+1)-1:W_4B*p])
        );
    end

    assign core_read_tag_q[w] = attr_tag(core_read_attr_q[w]);
    assign core_read_valid[w] = attr_valid(core_read_attr_q[w]);
    assign core_read_dirty[w] = attr_dirty(core_read_attr_q[w]);
    assign core_read_accessed[w] = attr_accessed(core_read_attr_q[w]);
    assign core_read_hit_way[w] = core_read_valid[w] && 
                                  (get_tag(d_ADDR)==core_read_tag_q[w]);

    assign update_valid[w] = (!INIT_DONE)? 1'b0 :
                             (state == RDY)? core_read_valid[w] :
                             (state == READ)? 1'b1 :
                             1'b0;
    assign update_dirty[w] = (!INIT_DONE)? 1'b0 :
                             (state == RDY)? |d_WE || core_read_dirty[w] :
                             1'b0;
    assign update_accessed[w] = (!INIT_DONE)? 1'b0 :
                                (state == RDY)? |d_RE || |d_WE || core_read_accessed[w] :
                                1'b0;
    assign update_status_d[w] = set_status(update_valid[w], update_dirty[w], update_accessed[w]);
    assign update_tag_d[w] = (!INIT_DONE)? 'b0 :
                             (state == RDY)? core_read_tag_q[w]:
                             ext_tag_d;
    assign update_attr_d[w] = set_attr(update_status_d[w], update_tag_d[w]);

    assign ext_q[w] = update_q[w];
    assign ext_attr_q[w] = update_attr_q[w];
    assign ext_tag_q[w] = attr_tag(ext_attr_q[w]);
    assign ext_dirty[w] = attr_dirty(ext_attr_q[w]);
    
    wire init_update;
    wire ready_update;
    wire write_update;
    wire read_update;
    wire wb_update;
    wire fl_update;
    assign init_update = (!INIT_DONE);
    assign ready_update = (state == RDY && core_read_hit_way[w]);
    assign write_update = (state == WRITE && replace_way[w]);
    assign read_update = (state == READ && replace_way[w]);
    assign wb_update = (state == WB && mini_state == 2 && writeback_way_cnt == w);
    assign fl_update = (state == FL);

    assign update_way[w] = init_update ||
                           ((|d_RE || |d_WE) && ready_update) ||
                           write_update ||
                           read_update ||
                           wb_update ||
                           fl_update;
  end endgenerate

  //------------------------------------------------------------------------------
  // Read
  //------------------------------------------------------------------------------
  assign core_read_index = get_index(ADDR);
  assign Q = {% for way in range(numways) %}
             (core_read_hit_way[{{ way }}])? get_data(core_read_q[{{ way }}], d_ADDR):
             {% endfor %}
             {W_LINE{1'bx}};
  assign READY = INIT_DONE && state == RDY && |core_read_hit_way;
  assign current_tag = get_tag(d_ADDR);

  //------------------------------------------------------------------------------
  // Write
  //------------------------------------------------------------------------------
  assign core_write_index = get_index(d_ADDR);
  assign core_write_d = { N_WORD_PER_LINE{d_D} };
  assign core_write_we = write_mask(d_ADDR, d_WE);
  assign core_write_way = core_read_hit_way;

  //------------------------------------------------------------------------------
  // Update
  //------------------------------------------------------------------------------
  assign update_index = (!INIT_DONE)? init_index :
                        (state == RDY)? core_write_index :
                        ext_index;
  assign update_d = (!INIT_DONE)? 0:
                    (state == RDY)? core_write_d :
                    ext_d;
  assign update_we = (!INIT_DONE)? {N_BYTE_PER_LINE{1'b1}}:
                     (state == RDY)? core_write_we:
                     ext_we;
  assign update_attr_we = (!INIT_DONE)? 1'b1:
                          (state == RDY)? |d_RE || |d_WE :
                          (state == WB)? mini_state == 2:
                          (state == FL)? 1'b1:
                          ext_tag_we;

  //------------------------------------------------------------------------------
  // Replacement
  //------------------------------------------------------------------------------
  assign lru_selected = (WAY == 1)? 1'b1 : lru(core_read_accessed, random_cnt);
  assign core_read_q_wb = {% for way in range(numways) %}
                          (lru_selected[{{ way }}])? core_read_q[{{ way }}]:
                          {% endfor %}
                          {W_LINE{1'bx}};
  assign core_read_tag_q_wb = {% for way in range(numways) %}
                              (lru_selected[{{ way }}])? core_read_tag_q[{{ way }}]:
                              {% endfor %}
                              {W_TAG{1'bx}};

  //------------------------------------------------------------------------------
  // State Machine
  //------------------------------------------------------------------------------
  always @(posedge CLK) begin
    if(RST) begin
      state <= INIT;
      mini_state <= 0;
      
      d_ADDR <= 0;
      d_D <= 0;
      d_WE <= 0;
      d_RE <= 0;
      d_WBACK <= 0;
      d_WBADDR <= 0;
      d_FLUSH <= 0;
      
      INIT_DONE <= 0;
      
      MEM_ADDR <= 0;
      MEM_D <= 0;
      MEM_RE <= 0;
      MEM_WE <= 0;
      
      init_index <= 0;
      
      ext_index <= 0;
      ext_way <= 0;
      ext_d <= 0;
      ext_we <= 0;
      ext_tag_d <= 0;
      ext_tag_we <= 0;
      
      replace_way <= 0;
      replace_addr <= 0;
      writeback_addr <= 0;
      writeback_data <= 0;
      writeback_way_cnt <= 0;
    end else begin
      case(state)
        INIT: begin
          d_ADDR <= ADDR;
          d_WE <= WE;
          d_RE <= RE;
          d_D <= D;
          d_WBACK <= 0;
          d_WBADDR <= 0;
          d_FLUSH <= 0;
          
          if(!INIT_DONE) begin
            init_index <= init_index + 1;
            if(init_index == N_LINE - 1) begin
              INIT_DONE <= 1;
            end
          end
          if(EN && INIT_DONE) begin
            state <= RDY;
            mini_state <= 0;
          end
        end

        RDY: begin
          if(EN) begin
            if(d_WBACK) begin
              ext_index <= get_index(d_WBADDR);
              writeback_way_cnt <= 0;
              state <= WB;
              mini_state <= 0;
            end else if(d_FLUSH) begin
              ext_index <= get_index(d_WBADDR);
              state <= FL;
              mini_state <= 0;
            end else if( (|d_RE || |d_WE) && (core_read_hit_way == 'h0) ) begin //miss
              replace_way <= lru_selected;
              replace_addr <= addr_mask(d_ADDR);
              if( (core_read_dirty & lru_selected) ) begin //dirty
                writeback_addr <= wb_addr(get_index(d_ADDR), core_read_tag_q_wb);
                writeback_data <= core_read_q_wb;
                ext_index <= get_index(d_ADDR);
                state <= WRITE;
                mini_state <= 0;
              end else begin //clean
                ext_index <= get_index(d_ADDR);
                state <= READ;
                mini_state <= 0;
              end
            end else begin //hit
              d_ADDR <= ADDR;
              d_WE <= WE;
              d_RE <= RE;
              d_D <= D;
              d_WBACK <= WBACK;
              d_WBADDR <= WBADDR;
              d_FLUSH <= FLUSH;
            end
          end
        end

        WRITE: begin
          case(mini_state)
            0: begin //Throw request
              MEM_ADDR <= writeback_addr;
              MEM_D <= writeback_data;
              MEM_WE <= 1;
              mini_state <= 1;
            end
            1: begin //wait(MEM_RDY), finish
              if(MEM_RDY) begin
                MEM_WE <= 0;
                state <= READ;
                mini_state <= 0;
`ifdef DEBUG
                $display("[Cache] BACK A:%08x IDX:%08x D:%00x", writeback_addr, ext_index, writeback_data);
`endif
              end
            end
          endcase
        end

        READ: begin
          case(mini_state)
            0: begin //Throw request
              MEM_ADDR <= replace_addr;
              MEM_RE <= 1;
              mini_state <= 1;
            end
            1: begin //wait(MEM_RDY), write to cache
              if(MEM_RDY) begin
                MEM_RE <= 0;
                ext_index <= get_index(replace_addr);
                ext_d <= MEM_Q;
                ext_we <= {N_BYTE_PER_LINE{1'b1}};
                ext_tag_d <= get_tag(replace_addr);
                ext_tag_we <= 1;
                ext_way <= replace_way;
                mini_state <= 2;
              end
            end
            2: begin //finish
              ext_we <= 0;
              ext_tag_we <= 0;
              state <= INIT;
              mini_state <= 0;
`ifdef DEBUG
              $display("[Cache] FILL A:%08x IDX:%08x Q:%00x", replace_addr, ext_index, ext_d);
`endif
            end
          endcase
        end

        WB: begin
          case(mini_state)
            0: begin
              mini_state <= 1;
            end
            1: begin //Throw request
              MEM_ADDR <= wb_addr(get_index(d_WBADDR),ext_tag_q[writeback_way_cnt]);
              MEM_D <= ext_q[writeback_way_cnt];
              if(ext_dirty[writeback_way_cnt]) begin
                MEM_WE <= 1;
                mini_state <= 2;
              end else begin
                MEM_WE <= 0;
                writeback_way_cnt <= writeback_way_cnt + 1;
              end
            end
            2: begin //wait(MEM_RDY), finish
              if(MEM_RDY) begin
                MEM_WE <= 0;
                if(writeback_way_cnt == WAY-1) begin
                  state <= INIT;
                  mini_state <= 0;
                end else begin
                  writeback_way_cnt <= writeback_way_cnt + 1;
                  mini_state <= 1;
                end
              end
            end
          endcase
        end

        FL: begin
          case(mini_state)
            0: begin
              state <= INIT;
              mini_state <= 0;
            end
          endcase
        end
      endcase

    end

  end

endmodule

//------------------------------------------------------------------------------
module CACHE_BANKED_MEM_{{ name }}(CLK, A0, A1, D0, D1, WE0, WE1, Q0, Q1);
    parameter W_A = 19;
    parameter W_INDEX = 7;
    parameter N_LINE = 128;
    parameter W_D = 32;
    parameter W_MASK = 4;
    input                CLK;
    input  [W_INDEX-1:0] A0;
    input  [W_INDEX-1:0] A1;
    input  [W_D-1:0]     D0;
    input  [W_D-1:0]     D1;
    input  [W_MASK-1:0]  WE0;
    input  [W_MASK-1:0]  WE1;
    output [W_D-1:0]     Q0;
    output [W_D-1:0]     Q1;
`ifndef SIM  
(* RAM_STYLE="BLOCK" *)
`endif  
    reg    [W_D-1:0]     mem [0:N_LINE-1];
    reg    [W_INDEX-1:0] d_A0;
    reg    [W_INDEX-1:0] d_A1;
    always @(posedge CLK) begin
        d_A0 <= A0;
        d_A1 <= A1;
{%- for b in range(4) %}
        if(WE0[{{ b }}]) mem[A0][{{ (b+1)*8 -1 }}:{{ b*8 }}] <= D0[{{ (b+1)*8 -1 }}:{{ b*8 }}];
{%- endfor %}
{%- for b in range(4) %}
        if(WE1[{{ b }}]) mem[A1][{{ (b+1)*8 -1 }}:{{ b*8 }}] <= D1[{{ (b+1)*8 -1 }}:{{ b*8 }}];
{%- endfor %}
    end
    assign Q0 = mem[d_A0];
    assign Q1 = mem[d_A1];
endmodule

module CACHE_ATTR_{{ name }}(CLK, A0, A1, D0, D1, WE0, WE1, Q0, Q1);
    parameter W_A = 19;
    parameter W_INDEX = 7;
    parameter N_LINE = 128;
    parameter W_ATTR = 7;
    input                CLK;
    input  [W_INDEX-1:0] A0;
    input  [W_INDEX-1:0] A1;    
    input  [W_ATTR-1:0]  D0;
    input  [W_ATTR-1:0]  D1;
    input                WE0;
    input                WE1;
    output [W_ATTR-1:0]  Q0;
    output [W_ATTR-1:0]  Q1;
`ifndef SIM  
(* RAM_STYLE="BLOCK" *)
`endif  
    reg    [W_ATTR-1:0]   mem [0:N_LINE-1];
    reg    [W_INDEX-1:0] d_A0;
    reg    [W_INDEX-1:0] d_A1;    
    always @(posedge CLK) begin
        d_A0 <= A0;
        d_A1 <= A1;
        if(WE0)
          mem[A0] <= D0;
        if(WE1)
          mem[A1] <= D1;
    end
    assign Q0 = mem[d_A0];
    assign Q1 = mem[d_A1];
endmodule



