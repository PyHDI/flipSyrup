//------------------------------------------------------------------------------
// User Logic - AXI Master Interface Bridge
//------------------------------------------------------------------------------
// Simple Log2 calculation function
`define C_LOG_2(n) (\
(n) <= (1<<0) ? 0 : (n) <= (1<<1) ? 1 :\
(n) <= (1<<2) ? 2 : (n) <= (1<<3) ? 3 :\
(n) <= (1<<4) ? 4 : (n) <= (1<<5) ? 5 :\
(n) <= (1<<6) ? 6 : (n) <= (1<<7) ? 7 :\
(n) <= (1<<8) ? 8 : (n) <= (1<<9) ? 9 :\
(n) <= (1<<10) ? 10 : (n) <= (1<<11) ? 11 :\
(n) <= (1<<12) ? 12 : (n) <= (1<<13) ? 13 :\
(n) <= (1<<14) ? 14 : (n) <= (1<<15) ? 15 :\
(n) <= (1<<16) ? 16 : (n) <= (1<<17) ? 17 :\
(n) <= (1<<18) ? 18 : (n) <= (1<<19) ? 19 :\
(n) <= (1<<20) ? 20 : (n) <= (1<<21) ? 21 :\
(n) <= (1<<22) ? 22 : (n) <= (1<<23) ? 23 :\
(n) <= (1<<24) ? 24 : (n) <= (1<<25) ? 25 :\
(n) <= (1<<26) ? 26 : (n) <= (1<<27) ? 27 :\
(n) <= (1<<28) ? 28 : (n) <= (1<<29) ? 29 :\
(n) <= (1<<30) ? 30 : (n) <= (1<<31) ? 31 : 32)

module axi_master_interface #
  (
   //----------------------------------------------------------------------------
   // User Parameter
   //----------------------------------------------------------------------------
   parameter integer USER_DATA_WIDTH = 128,
   parameter integer USER_ADDR_WIDTH = 32,

   //----------------------------------------------------------------------------
   // AXI Parameter
   //----------------------------------------------------------------------------
   parameter integer C_M_AXI_THREAD_ID_WIDTH       = 1,
   parameter integer C_M_AXI_ADDR_WIDTH            = 32,
   parameter integer C_M_AXI_DATA_WIDTH            = 32,
   parameter integer C_M_AXI_AWUSER_WIDTH          = 1,
   parameter integer C_M_AXI_ARUSER_WIDTH          = 1,
   parameter integer C_M_AXI_WUSER_WIDTH           = 1,
   parameter integer C_M_AXI_RUSER_WIDTH           = 1,
   parameter integer C_M_AXI_BUSER_WIDTH           = 1,
   
   /* Disabling these parameters will remove any throttling.
    The resulting ERROR flag will not be useful */ 
   parameter integer C_M_AXI_SUPPORTS_WRITE        = 1,
   parameter integer C_M_AXI_SUPPORTS_READ         = 1,
   
   // Example design parameters
   // Base address of targeted slave
   parameter C_M_AXI_TARGET = 'h00000000
   )
  (

   //----------------------------------------------------------------------------
   // System Signals
   //----------------------------------------------------------------------------
   input wire ACLK,
   input wire ARESETN,

   //----------------------------------------------------------------------------
   // User Interface
   //----------------------------------------------------------------------------
   input [USER_ADDR_WIDTH-1:0]      user_addr,
   input                            user_read_enable,
   output reg [USER_DATA_WIDTH-1:0] user_read_data,
   input                            user_write_enable,
   input [USER_DATA_WIDTH-1:0]      user_write_data,
   output reg                       user_ready,
   
   output wire                      ERROR,
   
   //----------------------------------------------------------------------------
   // AXI Master Interface
   //----------------------------------------------------------------------------
   // Master Interface Write Address
   output wire [C_M_AXI_THREAD_ID_WIDTH-1:0] M_AXI_AWID,
   output wire [C_M_AXI_ADDR_WIDTH-1:0]      M_AXI_AWADDR,
   output wire [8-1:0]                       M_AXI_AWLEN,
   output wire [3-1:0]                       M_AXI_AWSIZE,
   output wire [2-1:0]                       M_AXI_AWBURST,
   output wire                               M_AXI_AWLOCK,
   output wire [4-1:0]                       M_AXI_AWCACHE,
   output wire [3-1:0]                       M_AXI_AWPROT,
   output wire [4-1:0]                       M_AXI_AWQOS,
   output wire [C_M_AXI_AWUSER_WIDTH-1:0]    M_AXI_AWUSER,
   output wire                               M_AXI_AWVALID,
   input  wire                               M_AXI_AWREADY,
   
   // Master Interface Write Data
   output wire [C_M_AXI_DATA_WIDTH-1:0]      M_AXI_WDATA,
   output wire [C_M_AXI_DATA_WIDTH/8-1:0]    M_AXI_WSTRB,
   output wire                               M_AXI_WLAST,
   output wire [C_M_AXI_WUSER_WIDTH-1:0]     M_AXI_WUSER,
   output wire                               M_AXI_WVALID,
   input  wire                               M_AXI_WREADY,
   
   // Master Interface Write Response
   input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0] M_AXI_BID,
   input  wire [2-1:0]                       M_AXI_BRESP,
   input  wire [C_M_AXI_BUSER_WIDTH-1:0]     M_AXI_BUSER,
   input  wire                               M_AXI_BVALID,
   output wire                               M_AXI_BREADY,
   
   // Master Interface Read Address
   output wire [C_M_AXI_THREAD_ID_WIDTH-1:0] M_AXI_ARID,
   output wire [C_M_AXI_ADDR_WIDTH-1:0]      M_AXI_ARADDR,
   output wire [8-1:0]                       M_AXI_ARLEN,
   output wire [3-1:0]                       M_AXI_ARSIZE,
   output wire [2-1:0]                       M_AXI_ARBURST,
   output wire [2-1:0]                       M_AXI_ARLOCK,
   output wire [4-1:0]                       M_AXI_ARCACHE,
   output wire [3-1:0]                       M_AXI_ARPROT,
   output wire [4-1:0]                       M_AXI_ARQOS,
   output wire [C_M_AXI_ARUSER_WIDTH-1:0]    M_AXI_ARUSER,
   output wire                               M_AXI_ARVALID,
   input  wire                               M_AXI_ARREADY,
   
   // Master Interface Read Data 
   input  wire [C_M_AXI_THREAD_ID_WIDTH-1:0] M_AXI_RID,
   input  wire [C_M_AXI_DATA_WIDTH-1:0]      M_AXI_RDATA,
   input  wire [2-1:0]                       M_AXI_RRESP,
   input  wire                               M_AXI_RLAST,
   input  wire [C_M_AXI_RUSER_WIDTH-1:0]     M_AXI_RUSER,
   input  wire                               M_AXI_RVALID,
   output wire                               M_AXI_RREADY
   ); 

  //------------------------------------------------------------------------------
  // Internal Constant
  //------------------------------------------------------------------------------
  localparam integer C_M_AXI_BURST_LEN = USER_DATA_WIDTH / C_M_AXI_DATA_WIDTH;
  localparam integer C_M_AXI_BURST_COUNT_WIDTH = `C_LOG_2(C_M_AXI_BURST_LEN)+1;
  localparam integer ADDRMASK_WIDTH = `C_LOG_2(USER_DATA_WIDTH / 8);
  
  //------------------------------------------------------------------------------
  // Internal Signal
  //------------------------------------------------------------------------------
  // Write Address
  reg [USER_ADDR_WIDTH-1:0]    awaddr_offset;
  reg                          awvalid;
  // Write Data
  reg [C_M_AXI_DATA_WIDTH-1:0] wdata;
  reg                          wlast;
  reg                          wvalid;
  // Read Address
  reg [USER_ADDR_WIDTH-1:0]    araddr_offset;
  reg                          arvalid;

  reg error_reg;
  wire write_resp_error;
  wire read_resp_error; 
  
  //----------------------------------------------------------------------------
  // Write Address (AW)
  //----------------------------------------------------------------------------
  // Single threaded   
  assign M_AXI_AWID = 'b0;   
  
  // The AXI address is a concatenation of the target base address + active offset range
  assign M_AXI_AWADDR = C_M_AXI_TARGET + awaddr_offset;
  
  // Burst LENgth is number of transaction beats, minus 1
  assign M_AXI_AWLEN = C_M_AXI_BURST_LEN - 1;
  
  // Size should be C_M_AXI_DATA_WIDTH, in 2^SIZE bytes, otherwise narrow bursts are used
  assign M_AXI_AWSIZE = `C_LOG_2(C_M_AXI_DATA_WIDTH/8);
  
  // INCR burst type is usually used, except for keyhole bursts
  assign M_AXI_AWBURST = 2'b01;
  assign M_AXI_AWLOCK = 1'b0;
  assign M_AXI_AWCACHE = 4'b0011;
  assign M_AXI_AWPROT = 3'h0;
  assign M_AXI_AWQOS = 4'h0;
  assign M_AXI_AWUSER = 'b0;
  assign M_AXI_AWVALID = awvalid;
  
  //----------------------------------------------------------------------------
  // Write Data(W)
  //----------------------------------------------------------------------------
  assign M_AXI_WDATA = wdata;

  // Mask Signal
  //All bursts are complete and aligned in this example
  assign M_AXI_WSTRB = {(C_M_AXI_DATA_WIDTH/8){1'b1}}; 
  assign M_AXI_WLAST = wlast;
  assign M_AXI_WUSER = 'b0;
  assign M_AXI_WVALID = wvalid;
  
  //----------------------------------------------------------------------------
  // Write Response (B)
  //----------------------------------------------------------------------------
  assign M_AXI_BREADY = C_M_AXI_SUPPORTS_WRITE;

  //----------------------------------------------------------------------------  
  // Read Address (AR)
  //----------------------------------------------------------------------------
  assign M_AXI_ARID = 'b0;   
  assign M_AXI_ARADDR = C_M_AXI_TARGET + araddr_offset;
  
  //Burst LENgth is number of transaction beats, minus 1
  assign M_AXI_ARLEN = C_M_AXI_BURST_LEN - 1;
  
  // Size should be C_M_AXI_DATA_WIDTH, in 2^n bytes, otherwise narrow bursts are used
  assign M_AXI_ARSIZE = `C_LOG_2(C_M_AXI_DATA_WIDTH/8);
  
  // INCR burst type is usually used, except for keyhole bursts
  assign M_AXI_ARBURST = 2'b01;
  assign M_AXI_ARLOCK = 1'b0;
  assign M_AXI_ARCACHE = 4'b0011;
  assign M_AXI_ARPROT = 3'h0;
  assign M_AXI_ARQOS = 4'h0;
  assign M_AXI_ARUSER = 'b0;
  assign M_AXI_ARVALID = arvalid;

  //----------------------------------------------------------------------------    
  // Read and Read Response (R)
  //----------------------------------------------------------------------------    
  assign M_AXI_RREADY = C_M_AXI_SUPPORTS_READ;

  //----------------------------------------------------------------------------
  // Error state
  //----------------------------------------------------------------------------
  assign ERROR = error_reg;
  
  //----------------------------------------------------------------------------
  // Reset logic
  //----------------------------------------------------------------------------
  reg aresetn_r;
  reg aresetn_rr;
  reg aresetn_rrr;

  always @(posedge ACLK) begin
    aresetn_r <= ARESETN;
    aresetn_rr <= aresetn_r;
    aresetn_rrr <= aresetn_rr;
  end

  //----------------------------------------------------------------------------
  // User State Machine
  //----------------------------------------------------------------------------
  function [USER_ADDR_WIDTH-1:0] addrmask;
    input [USER_ADDR_WIDTH-1:0] in;
    addrmask = { in[USER_ADDR_WIDTH-1:ADDRMASK_WIDTH], {ADDRMASK_WIDTH{1'b0}} };
  endfunction

  reg [USER_ADDR_WIDTH-1:0] user_addr_buf;
  reg [USER_DATA_WIDTH-1:0] user_write_data_buf;

  wire [USER_DATA_WIDTH-1:0] next_user_read_data;
  wire [USER_DATA_WIDTH-1:0] next_user_write_data_buf;

  reg read_busy;
  reg read_addr_done;
  reg [C_M_AXI_BURST_COUNT_WIDTH-1:0] read_cnt;

  reg write_busy;
  reg write_addr_done;
  reg [C_M_AXI_BURST_COUNT_WIDTH-1:0] write_cnt;

  generate if(C_M_AXI_BURST_LEN == 1) begin: burstlen_eq_1
    assign next_user_read_data = M_AXI_RDATA;
  end else begin: burstlen_neq_1
    assign next_user_read_data = {M_AXI_RDATA,
                                  user_read_data[USER_DATA_WIDTH-1:C_M_AXI_DATA_WIDTH]};
  end endgenerate
  
  generate if(C_M_AXI_BURST_LEN > 1) begin: burstlen_gt_1
    assign next_user_write_data_buf = {{C_M_AXI_DATA_WIDTH{1'b0}},
                                       user_write_data_buf[USER_DATA_WIDTH-1:C_M_AXI_DATA_WIDTH]};
  end else begin: not_burstlen_gt_1
    assign next_user_write_data_buf = 'hx;
  end endgenerate

  always @(posedge ACLK) begin
    if(aresetn_rrr == 0) begin
      arvalid <= 0;
      awvalid <= 0;
      wlast <= 0;
      wvalid <= 0;
      wdata <= 0;
      araddr_offset <= 0;
      awaddr_offset <= 0;
      read_busy <= 0;
      write_busy <= 0;
      read_cnt <= 0;
      write_cnt <= 0;
      read_addr_done <= 0;
      write_addr_done <= 0;
      user_ready <= 0;
      user_addr_buf <= 0;
      user_read_data <= 0;
      user_write_data_buf <= 0;
    end else begin
      //default
      arvalid <= 0;
      awvalid <= 0;
      wlast <= 0;
      wvalid <= 0;
      user_ready <= 0;

      //----------------------------------------------------------------------
      if(read_busy) begin
        
        if(!read_addr_done) begin
          araddr_offset <= user_addr_buf;
          arvalid <= 1;
          if(arvalid && M_AXI_ARREADY) begin
            read_addr_done <= 1;
            arvalid <= 0;
          end
        end
        
        if(M_AXI_RVALID) begin
          if(C_M_AXI_BURST_LEN == 1) begin
            read_cnt <= 1;
            //user_read_data <= M_AXI_RDATA;
            user_read_data <= next_user_read_data;
            read_busy <= 0;
            user_ready <= 1;
          end else begin
            read_cnt <= read_cnt + 1;
            //user_read_data <= {M_AXI_RDATA,
            //                   user_read_data[USER_DATA_WIDTH-1:C_M_AXI_DATA_WIDTH]};
            user_read_data <= next_user_read_data;
            if(read_cnt == C_M_AXI_BURST_LEN -1) begin
              read_busy <= 0;
              user_ready <= 1;
            end
          end
        end
      
      end
      //----------------------------------------------------------------------
      else if(write_busy) begin
        
        if(!write_addr_done) begin
          awaddr_offset <= user_addr_buf;
          awvalid <= 1;
          if(awvalid && M_AXI_AWREADY) begin
            write_addr_done <= 1;
            awvalid <= 0;
          end
        end

        if((write_addr_done || (awvalid && M_AXI_AWREADY)) &&
           write_cnt < C_M_AXI_BURST_LEN) begin
          
          wvalid <= 1;        
          if(!wvalid || (wvalid && M_AXI_WREADY)) begin
            wdata <= user_write_data_buf[C_M_AXI_DATA_WIDTH-1:0];
            if(C_M_AXI_BURST_LEN > 1) begin
              //user_write_data_buf <= {{C_M_AXI_DATA_WIDTH{1'b0}},
              //                        user_write_data_buf[USER_DATA_WIDTH-1:C_M_AXI_DATA_WIDTH]};
              user_write_data_buf <= next_user_write_data_buf;
            end
            write_cnt <= write_cnt + 1;
          end
          
          if(write_cnt == C_M_AXI_BURST_LEN -1) begin
            wlast <= 1;
          end
        end
        
        if(write_cnt == C_M_AXI_BURST_LEN && wvalid && !M_AXI_WREADY) begin
          wvalid <= 1;
          wlast <= 1;
        end
        
        if(M_AXI_BVALID) begin
          write_busy <= 0;
          user_ready <= 1;
        end

      end
      //----------------------------------------------------------------------
      else if(user_read_enable) begin
        user_addr_buf <= addrmask(user_addr);
        read_busy <= 1;
        read_addr_done <= 0;
        read_cnt <= 0;
      end
      //----------------------------------------------------------------------
      else if(user_write_enable) begin
        user_write_data_buf <= user_write_data;
        user_addr_buf <= addrmask(user_addr);
        write_busy <= 1;
        write_addr_done <= 0;
        write_cnt <= 0;
      end 
      //----------------------------------------------------------------------

    end
  end
  
  //----------------------------------------------------------------------------
  // Error register
  //----------------------------------------------------------------------------
  assign write_resp_error = C_M_AXI_SUPPORTS_WRITE & M_AXI_BVALID & M_AXI_BRESP[1];
  assign read_resp_error = C_M_AXI_SUPPORTS_READ & M_AXI_RVALID & M_AXI_RRESP[1];

  always @(posedge ACLK) begin
     if (ARESETN == 0)
       error_reg <= 1'b0;
     else if (write_resp_error || read_resp_error)
       error_reg <= 1'b1;
     else
       error_reg <= error_reg;
  end

endmodule
