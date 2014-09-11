assign reset_performance_count = 1'b0;
assign syrupoutchannel_0_outchannel_ready_in = 1'b1;

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
