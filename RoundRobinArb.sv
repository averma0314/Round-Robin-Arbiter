
module RoundRobinArb # (
  parameter NumOfAgents = 4 // number of agents
) (
  input  logic clk,
  input  logic rstb,
  input  logic [NumOfAgents-1:0] In,
  output logic [NumOfAgents-1:0] Grant  
);
  
  
  logic [$clog2(NumOfAgents) -1 : 0] LastGrant; // last grant
  logic [NumOfAgents-1:0]            RotIn;     // rotated inputs
  logic [NumOfAgents-1:0]            RotGrant;  // rotated output from priority encoder
  
  assign RotIn = (In >> (LastGrant + 1'b1)) | (In << (NumOfAgents - LastGrant - 1'b1));
  
  // priority encoder
  priority_enc #(.NumOfAgents(NumOfAgents)) enc (
    .In(RotIn),
    .en(|In),
    .Z (RotGrant)
  );
  
  assign Grant = (RotGrant << (LastGrant + 1'b1)) | (RotGrant >> (NumOfAgents - LastGrant - 1'b1));

  
  always_ff @(posedge clk) begin
    if (!rstb) 
      LastGrant <= '0;
    else begin
      for (int i = 0; i < NumOfAgents ; i++) begin
        if (Grant[i])
          LastGrant <= i;
      end
    end 
  end
  
  
endmodule

module priority_enc # (
  parameter NumOfAgents = 4 // number of agents
) (
  input  logic [NumOfAgents-1:0] In,
  input  logic           en, // enable
  output logic [NumOfAgents-1:0] Z   
);
  
  logic [NumOfAgents-1:0] InQ; // input qualified
  
  assign InQ = In & {NumOfAgents{en}};
  
  always_comb begin
    Z[0] = InQ[0]; // Highest priority  
  end
  
  genvar i;
  generate
    for (i=1; i<NumOfAgents; i++) begin : enc
      always_comb begin
        Z[i] = InQ[i] & ~(|(InQ[i-1:0]));
      end
    end
  endgenerate
  
endmodule
