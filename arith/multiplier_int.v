// Pipelined integer multiplier
module multiplier_int(
  // Clock and reset
  clk,
  aresetn,

  opp_a,
  opp_b,

  out
);

  parameter OPP_W = 4;

  input clk;
  input aresetn;

  input [OPP_W - 1:0] opp_a;
  input [OPP_W - 1:0] opp_b;


  output [2 * OPP_W - 1:0] out;

  reg [OPP_W - 1:0] opp_a_pipe [0:OPP_W - 1];
  reg [OPP_W - 1:0] opp_b_pipe [0:OPP_W - 1];
  reg opp_a_sign [0:OPP_W];
  reg opp_b_sign [0:OPP_W];


  reg [2 * OPP_W - 1:0] acc [0:OPP_W - 1];
  reg [2 * OPP_W - 1:0] p_product [0:OPP_W - 1];

  integer i;
  always@(posedge clk, negedge aresetn) begin
    if(aresetn == 0) begin
      // Clear all registers
      for(i = 0; i < OPP_W; i = i + 1) begin
        opp_a_pipe[i] <= 0;
        opp_b_pipe[i] <= 0;
        acc[i] <= 0;
      end

      for(i = 0; i <= OPP_W; i = i + 1) begin
        opp_a_sign[i] <= 0;
        opp_b_sign[i] <= 0;
      end

    end else begin
      // Pipeline input opperands
      opp_a_pipe[0] <= opp_a[OPP_W - 1] ? -opp_a : opp_a;
      opp_b_pipe[0] <= opp_b[OPP_W - 1] ? -opp_b : opp_b;
      opp_a_sign[0] <= opp_a[OPP_W - 1];
      opp_b_sign[0] <= opp_b[OPP_W - 1];
      for(i = 1; i < OPP_W; i = i + 1) begin
        opp_a_pipe[i] <= opp_a_pipe[i - 1];
        opp_b_pipe[i] <= opp_b_pipe[i - 1];
        opp_a_sign[i] <= opp_a_sign[i - 1];
        opp_b_sign[i] <= opp_b_sign[i - 1];
      end
      opp_a_sign[OPP_W] <= opp_a_sign[OPP_W - 1];
      opp_b_sign[OPP_W] <= opp_b_sign[OPP_W - 1];

      // Pipeline accumulator registers
      acc[0] <= p_product[0];
      for(i = 1; i < OPP_W; i = i + 1) begin
        acc[i] <= acc[i - 1] + p_product[i];
      end
    end
  end

  // Output is the last accumulator register
  assign out = (opp_a_sign[OPP_W] ^ opp_b_sign[OPP_W]) ? 
    -acc[OPP_W - 1] : acc[OPP_W - 1];

  // Generate parital products for each pipeline stage
  always@(*) begin
    for(i = 0; i < OPP_W; i = i + 1) begin
      // Computer partial product
      p_product[i] = (opp_a_pipe[i] & {OPP_W{opp_b_pipe[i][i]}}) << i;
    end
  end

endmodule

