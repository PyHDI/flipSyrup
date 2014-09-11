//------------------------------------------------------------------------------
// Data Marshaller between cache and off-chip memory
//------------------------------------------------------------------------------
module MARSHALLER_{{ name }}
  (CLK, RST,
   MEM_ADDR, MEM_D, MEM_WE, MEM_RE, MEM_Q, MEM_RDY,
   UP_ADDR, UP_D, UP_WE, UP_RE, UP_Q, UP_RDY);

  parameter W_A = {{ addrlen }};
  parameter W_LINE_OFFSET = {{ line_offset }};
  parameter W_MEM_OFFSET = {{ offchip_offset }};
  localparam W_POS = W_MEM_OFFSET - W_LINE_OFFSET;
  localparam N_ENTRY = 2 ** W_POS;
  parameter W_LINE = {{ linewidth }};
  parameter W_OFF_D = {{ offchip_datawidth }};
  
  input CLK, RST;

  input [W_A-1:0]         UP_ADDR;
  input [W_LINE-1:0]      UP_D;
  input                   UP_WE;
  input                   UP_RE;
  output reg [W_LINE-1:0] UP_Q;
  output reg              UP_RDY;
  
  output reg [W_A-1:0]     MEM_ADDR;
  output reg [W_OFF_D-1:0] MEM_D;
  output reg               MEM_WE;
  output reg               MEM_RE;
  input [W_OFF_D-1:0]      MEM_Q;
  input                    MEM_RDY;

  function [W_A-1:0] addr_mask;
    input [W_A-1:0] in;
    addr_mask = { in[W_A-1:W_MEM_OFFSET], {W_MEM_OFFSET{1'b0}} }; 
  endfunction

{% if line_offset == offchip_offset %}
  function [W_POS:0] get_pos;
    input [W_A-1:0] in;
    get_pos = 0;
  endfunction
{% else %}
  function [W_POS-1:0] get_pos;
    input [W_A-1:0] in;
    get_pos = in[W_MEM_OFFSET-1:W_LINE_OFFSET];
  endfunction
{% endif %}
  
  wire [W_OFF_D-1:0]   row_buffer_read;
  reg [W_LINE-1:0]     row_buffer [0:N_ENTRY-1];

  reg                  dirty;
  reg [W_A-1:0]        current_addr;
  reg [W_A-1:0]        requested_addr;
  
  reg [3:0]            state;
  localparam IDLE = 0;
  localparam RDY = 1;
  localparam WRITE = 2;
  localparam READ = 3;
  
  genvar i;
  generate for(i=0; i<N_ENTRY; i=i+1) begin: s_bank
    assign row_buffer_read[(i+1)*W_LINE-1:i*W_LINE] = row_buffer[i];
    always @(posedge CLK) begin
      if(state == RDY && current_addr == addr_mask(UP_ADDR) &&
         UP_WE && get_pos(UP_ADDR) == i) begin
        row_buffer[i] <= UP_D;
      end else if(state == READ && MEM_RDY) begin
        row_buffer[i] <= MEM_Q[(i+1)*W_LINE-1:i*W_LINE];
      end
    end
  end endgenerate

  always @(posedge CLK) begin
    if(RST) begin
      state <= IDLE;
      dirty <= 0;
      UP_RDY <= 0;
      MEM_WE <= 0;
      MEM_RE <= 0;
    end else begin

      // Initial state
      if(state == IDLE) begin
        if(UP_RE || UP_WE) begin
          state <= READ;
          MEM_ADDR <= addr_mask(UP_ADDR);
          MEM_RE <= 1;
        end

      // Normal state
      end else if(state == RDY) begin
        UP_RDY <= 0;
        if(UP_WE || UP_RE) begin //access
          if(current_addr !=  addr_mask(UP_ADDR)) begin // miss
            if(dirty) begin
              requested_addr <= addr_mask(UP_ADDR);
              state <= WRITE;
              MEM_ADDR <= current_addr;
              MEM_D <= row_buffer_read;
              MEM_WE <= 1;
            end else begin
              state <= READ;
              MEM_ADDR <= addr_mask(UP_ADDR);
              MEM_RE <= 1;
            end
          end else if(UP_WE) begin // hit (write)
            dirty <= 1;
            UP_RDY <= 1;
          end else begin // hit (read)
            UP_Q <= row_buffer[get_pos(UP_ADDR)];
            UP_RDY <= 1;
          end
        end

      // Write state
      end else if(state == WRITE) begin
        if(MEM_RDY) begin
          state <= READ;
          dirty <= 0;
          MEM_WE <= 0;
          MEM_ADDR <= requested_addr;
          MEM_RE <= 1;
        end
    
      // Read state
      end else if(state == READ) begin
        if(MEM_RDY) begin
          state <= RDY;
          current_addr <= MEM_ADDR;
          MEM_RE <= 0;
        end
      end
      
    end
  end
  
endmodule


