module tb_RoundRobinArb # (
  parameter NumOfAgents = 4,
  parameter MULT = 5.1
) ();
  
  parameter CLK_PERIOD = 0.5;
  parameter MAX_REQ_COUNT = 10;  // Number of times the tb will send input requests till all agents are serviced!
  
  logic                   clk;
  logic                   rstb;
  logic [NumOfAgents-1:0] In;
  logic [NumOfAgents-1:0] Grant;
  int                     RstAssertionCount;
  int                     AgentReqCount;
  
  RoundRobinArb # (
    .NumOfAgents(NumOfAgents)
  ) RoundRobinArb_Inst (
     .clk,
     .rstb,
     .In,
     .Grant      
  );
  
  

///////////////////////////////////////////////////
// Reset initialization
///////////////////////////////////////////////////
initial begin
   rstb = 1'bx;   
   #($urandom_range(20,1));
   
   // Reset assertion. Should assert for a few clock cycles!
   rstb = 1'b0;   
   RstAssertionCount = $urandom_range(20,5);
   while (RstAssertionCount > 0) begin // {
      @(posedge clk); 
	  RstAssertionCount--;
   end // }
   
   // Reset de-assertion
   rstb = 1'b1;
  #($urandom_range(35,10));
end

///////////////////////////////////////////////////
// Test Initialization 
///////////////////////////////////////////////////
// Agent requests
initial begin
  @(posedge rstb); // Wait for the reset to de-assert
  
  In = {NumOfAgents{1'b0}};
  AgentReqCount = 0;
  #($urandom_range(20,1));
  
  @(posedge clk);
  // Initial requests from the agents
  for (int i=0; i<NumOfAgents;i++) begin
    In[i] = $urandom_range(1,0);
  end  
  @(posedge clk);
  
  while (AgentReqCount < MAX_REQ_COUNT) begin
     for (int i=0; i<NumOfAgents;i++) begin
	   if (Grant[i] || ~In[i]) begin  // If the current agent received last grant or if request was 0 in the previous clock, then randomly assert the request.
	      In[i] = $urandom_range(1,0);
	   end
	 end
	 @(posedge clk);
     AgentReqCount++;
  end
  
  // Wait for all the requests to flush out
  while (|In) begin
     for (int i=0; i<NumOfAgents;i++) begin
	   if (Grant[i]) begin 
	      In[i] = 1'b0;
	   end
	 end
	 @(posedge clk);
  end  
  
  #($urandom_range(200,100));
  $finish;
end
 

///////////////////////////////////////////////////
// Checks
///////////////////////////////////////////////////
initial begin

 forever begin
    @(posedge clk);
    #0.1;
    // Check no agent is granted unless it requested
    for (int i = 0; i < NumOfAgents; i++) begin
      if (Grant[i] && !In[i]) begin
        $error("Error: Agent %0d granted without a request. Grant=%0b In=%0b", i, Grant, In);
      end
    end
   
    // Check that only one grant is high
	if (|In) begin
       assert ($onehot0(Grant)) else begin
         $error("Error: Multiple or invalid grants at time %t: %b", $time, Grant);
       end
	end
	
  end	
end

///////////////////////////////////////////////////
// Clock Generation
///////////////////////////////////////////////////
initial begin
        clk = 1'b0;
        forever begin
      	  #(CLK_PERIOD*MULT) clk = ~clk;
        end
end

///////////////////////////////////////////////////
// Waveform
///////////////////////////////////////////////////
initial begin
  $dumpfile("dump.vcd");
  $dumpvars();
end
  
endmodule
