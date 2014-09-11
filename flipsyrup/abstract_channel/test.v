`include "out.v"

module test;
  reg CLK;
  reg RST;
  
  reg [31:0] NorthOut_d;
  reg NorthOut_we;
  
  wire [31:0] NorthIn_q;
  reg NorthIn_re;
  
  wire [31:0] NorthOut_ext_data_out;
  wire NorthOut_ext_enq_out;
  reg NorthOut_ext_ready_in;

  wire NorthIn_ext_clk;
  wire NorthIn_ext_rst;
  
  reg [31:0] NorthIn_ext_data_in;
  reg NorthIn_ext_enq_in;
  wire NorthIn_ext_ready_out;
  
  reg MCore_slave_drive_in;
  wire MCore_slave_drive_out;
  reg MCore_master_drive_in;
  wire MCore_master_drive_out;
  wire MCore_DRIVE;

  assign NorthIn_ext_clk = CLK;
  assign NorthIn_ext_rst = RST;
  
  SYRUP_CHANNELSYSTEM
  uut
  (
   .CLK(CLK),
   .RST(RST),
   .NorthOut_d(NorthOut_d),
   .NorthOut_we(NorthOut_we),
   .NorthIn_q(NorthIn_q),
   .NorthIn_re(NorthIn_re),
   .NorthOut_ext_data_out(NorthOut_ext_data_out),
   .NorthOut_ext_enq_out(NorthOut_ext_enq_out),
   .NorthOut_ext_ready_in(NorthOut_ext_ready_in),
   .NorthIn_ext_clk(NorthIn_ext_clk),
   .NorthIn_ext_rst(NorthIn_ext_rst),
   .NorthIn_ext_data_in(NorthIn_ext_data_in),
   .NorthIn_ext_enq_in(NorthIn_ext_enq_in),
   .NorthIn_ext_ready_out(NorthIn_ext_ready_out),
   .MCore_slave_drive_in(MCore_slave_drive_in),
   .MCore_slave_drive_out(MCore_slave_drive_out),
   .MCore_master_drive_in(MCore_master_drive_in),
   .MCore_master_drive_out(MCore_master_drive_out),
   .MCore_DRIVE(MCore_DRIVE)
  );

  initial begin
    CLK = 0;
    forever #5 CLK = ~CLK;
  end

  task nclk;
    begin
      wait(~CLK);
      wait(CLK);
      #1;
    end
  endtask

  reg init_done;
  
  initial begin
    init_done = 0;
    MCore_master_drive_in = 1;
    MCore_slave_drive_in = 1;
    
    NorthOut_we = 0;
    NorthIn_re = 0;
    
    RST = 0;
    
    #100;
    RST = 1;
    #100;
    RST = 0;
    
    init_done = 1;
    
    NorthOut_d = 'h0000;
    
    nclk();
    nclk();
    nclk();
    
    NorthOut_d = NorthOut_d + 1;
    NorthOut_we = 1;
    NorthIn_re = 1;
    nclk();
    while(!MCore_DRIVE) begin
      nclk();
    end

    NorthOut_we = 0;
    NorthIn_re = 0;
    nclk();
    while(!MCore_DRIVE) begin
      nclk();
    end
    
    NorthOut_we = 0;
    NorthIn_re = 1;
    nclk();
    while(!MCore_DRIVE) begin
      nclk();
    end
    
    NorthOut_we = 0;
    NorthIn_re = 0;
    nclk();
    while(!MCore_DRIVE) begin
      nclk();
    end
    
    NorthOut_we = 0;
    NorthIn_re = 0;
    nclk();
    while(!MCore_DRIVE) begin
      nclk();
    end
    
    NorthOut_we = 0;
    NorthIn_re = 0;
    nclk();
    while(!MCore_DRIVE) begin
      nclk();
    end
    
    NorthOut_we = 0;
    NorthIn_re = 0;
    nclk();
    while(!MCore_DRIVE) begin
      nclk();
    end
    
    NorthOut_d = NorthOut_d + 1;
    NorthOut_we = 1;
    NorthIn_re = 1;
    nclk();
    while(!MCore_DRIVE) begin
      nclk();
    end

    NorthOut_d = NorthOut_d + 1;
    NorthOut_we = 1;
    NorthIn_re = 1;
    nclk();
    while(!MCore_DRIVE) begin
      nclk();
    end

    NorthOut_we = 0;
    NorthIn_re = 0;
    nclk();
    while(!MCore_DRIVE) begin
      nclk();
    end
    
    NorthOut_we = 0;
    NorthIn_re = 1;
    nclk();
    while(!MCore_DRIVE) begin
      nclk();
    end
    
    NorthOut_we = 0;
    NorthIn_re = 1;
    nclk();
    while(!MCore_DRIVE) begin
      nclk();
    end
    
    NorthOut_d = NorthOut_d + 1;
    NorthOut_we = 1;
    NorthIn_re = 1;
    nclk();
    while(!MCore_DRIVE) begin
      nclk();
    end

    NorthOut_d = NorthOut_d + 1;
    NorthOut_we = 1;
    NorthIn_re = 1;
    nclk();
    while(!MCore_DRIVE) begin
      nclk();
    end

    NorthOut_we = 0;
    NorthIn_re = 0;
    nclk();
    while(!MCore_DRIVE) begin
      nclk();
    end
    
    NorthOut_we = 0;
    NorthIn_re = 0;
    nclk();
    while(!MCore_DRIVE) begin
      nclk();
    end
    
    #1000;
    $finish;
  end

  
  reg [7:0] enq_cnt;
  initial begin
    enq_cnt = 0;
    NorthOut_ext_ready_in = 1;
  end
  always @(posedge CLK) begin
    if(NorthOut_ext_enq_out) begin
      NorthOut_ext_ready_in <= 0;
      enq_cnt <= 1;
    end else if(enq_cnt > 0) begin
      enq_cnt <= enq_cnt - 1;
      if(enq_cnt == 1) begin
        NorthOut_ext_ready_in <= 1;
      end
    end
  end

  
  reg [7:0] deq_cnt;
  reg [31:0] NorthIn_ext_data_in_value;
  initial begin
    deq_cnt = 0;
    NorthIn_ext_data_in = 'hffff;
    NorthIn_ext_enq_in = 0;
    NorthIn_ext_data_in_value = 'h10000;
  end
  always @(posedge CLK) begin
    if(init_done && deq_cnt == 0 && NorthIn_ext_ready_out) begin
      NorthIn_ext_data_in <= NorthIn_ext_data_in_value;
      NorthIn_ext_enq_in = 1;
      deq_cnt <= 8;
    end else if(deq_cnt > 0) begin
      NorthIn_ext_data_in <= 'hx;
      NorthIn_ext_enq_in = 0;
      deq_cnt <= deq_cnt - 1;
      if(deq_cnt == 1) begin
        NorthIn_ext_data_in_value <= NorthIn_ext_data_in_value + 1;
      end
    end
  end

  reg read_unmatch;
  reg d_NorthIn_re;
  reg [31:0] d_NorthIn_q;
  initial begin
    read_unmatch = 0;
    d_NorthIn_re = 0;
    d_NorthIn_q = 'hffff;
  end
  always @(posedge CLK) begin
    if(MCore_DRIVE) begin
      d_NorthIn_re <= NorthIn_re;
      if(d_NorthIn_re) begin
        d_NorthIn_q <= NorthIn_q;
        if(d_NorthIn_q + 1 !== NorthIn_q) begin
          read_unmatch = 1;
          $display("READ Mismatch Expected:%x Actual:%x", d_NorthIn_q + 1, NorthIn_q);
        end
      end
    end
  end

  reg write_unmatch;
  reg [31:0] d_NorthOut_ext_data_out;
  initial begin
    write_unmatch = 0;
    d_NorthOut_ext_data_out <= 0;
  end
  always @(posedge CLK) begin
    if(NorthOut_ext_enq_out) begin
      d_NorthOut_ext_data_out <= NorthOut_d;
      if(d_NorthOut_ext_data_out + 1 !== NorthOut_d) begin
        write_unmatch = 1;
        $display("WRITE Mismatch Expected:%x Actual:%x", d_NorthOut_ext_data_out + 1, NorthOut_d);
      end
    end
  end
  
  initial begin
    #10000;
    $display("Time out");
    $finish;
  end
  
  initial begin
    $dumpfile("uut.vcd");
    $dumpvars(0, uut, read_unmatch, write_unmatch, d_NorthIn_q, d_NorthOut_ext_data_out);
  end
  
endmodule

