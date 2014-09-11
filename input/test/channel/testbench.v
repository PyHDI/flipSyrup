assign reset_performance_count = 1'b0;

parameter USER_SIM_CYCLE = 1000;

reg [63:0] clock_count;
initial begin
  $display("# USER_SIM_CYCLE = %d", USER_SIM_CYCLE);
  clock_count = 0;
  wait(clock_count >= USER_SIM_CYCLE);
  $display("# %d (USER_SIM_CYCLE) clock cycles passed, finish", USER_SIM_CYCLE);
  $finish;
end

reg [31:0] sleep_cycle;
reg init_done;  
  
always @(posedge UCLK) begin
  if(!URESETN) begin
    clock_count <= 0;
    sleep_cycle <= 0;
    init_done <= 0;
  end else begin
    if(inst_uut.DRIVE) begin
      clock_count <= clock_count + 1;
      sleep_cycle <= 0;
      init_done <= 1;
    end else if(init_done) begin
      sleep_cycle <= sleep_cycle + 1;
    end
    if(sleep_cycle > 100) begin
      $display("DRIVE signal does not work");
    end
  end 
end

// clock and reset  
assign syrupinchannel_0_inchannel_clk = UCLK;
assign syrupinchannel_0_inchannel_rst = !URESETN;
  
reg reg_syrupoutchannel_0_outchannel_ready_in;
assign syrupoutchannel_0_outchannel_ready_in = reg_syrupoutchannel_0_outchannel_ready_in;
  
reg [31:0] reg_syrupinchannel_0_inchannel_data_in;
reg reg_syrupinchannel_0_inchannel_enq_in;
assign syrupinchannel_0_inchannel_data_in = reg_syrupinchannel_0_inchannel_data_in;
assign syrupinchannel_0_inchannel_enq_in = reg_syrupinchannel_0_inchannel_enq_in;

reg [7:0] we_cnt;
reg [7:0] re_cnt;
reg [31:0] reg_syrupinchannel_0_inchannel_data_in_value;
  
initial begin
  reg_syrupoutchannel_0_outchannel_ready_in = 1'b1;
  reg_syrupinchannel_0_inchannel_data_in = 0;
  reg_syrupinchannel_0_inchannel_enq_in = 1'b0;
  we_cnt = 0;
  re_cnt = 0;
  reg_syrupinchannel_0_inchannel_data_in_value = 'h10000;
end

parameter CHANNEL_WRITE_LATENCY = 5;
parameter CHANNEL_READ_LATENCY = 10; 

always @(posedge UCLK) begin
  
  if(syrupoutchannel_0_outchannel_enq_out === 1'b1) begin
    reg_syrupoutchannel_0_outchannel_ready_in <= 0;
    we_cnt <= CHANNEL_WRITE_LATENCY;
    $display("Time %d: WriteData:%x", $stime, syrupoutchannel_0_outchannel_data_out);
  end else if(we_cnt > 0) begin
      we_cnt <= we_cnt - 1;
      if(we_cnt == 1) begin
        reg_syrupoutchannel_0_outchannel_ready_in <= 1;
      end
  end
  
  if(init_done && syrupinchannel_0_inchannel_ready_out === 1'b1 && re_cnt == 0) begin
    reg_syrupinchannel_0_inchannel_data_in <= reg_syrupinchannel_0_inchannel_data_in_value;
    reg_syrupinchannel_0_inchannel_enq_in <= 1'b1;
    re_cnt <= CHANNEL_READ_LATENCY;
  end else if(re_cnt > 0) begin
    if(re_cnt == CHANNEL_READ_LATENCY) begin
      $display("Time %d: ReadData:%x", $stime, syrupinchannel_0_inchannel_data_in);
    end
    reg_syrupinchannel_0_inchannel_data_in <= 'hx;
    reg_syrupinchannel_0_inchannel_enq_in <= 1'b0;
    re_cnt <= re_cnt - 1;
    if(re_cnt == 1) begin
      reg_syrupinchannel_0_inchannel_data_in_value <= reg_syrupinchannel_0_inchannel_data_in_value + 1;
    end
  end
  
end

