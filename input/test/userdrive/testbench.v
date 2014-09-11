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

always @(posedge UCLK) begin
  if(!URESETN) begin
    clock_count <= 0;
  end else begin
    if(inst_uut.DRIVE) begin
      clock_count <= clock_count + 1;
    end
  end 
end
