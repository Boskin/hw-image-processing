module tb_multiplier_int;

localparam CLK_PERIOD = 2;
localparam RESET_DURATION = CLK_PERIOD * 5;
localparam TEST_COUNT = 500;

localparam OPP_W = 4;
localparam MAX_OPP = (1 << OPP_W) - 1;

reg clk;
reg aresetn;

reg signed [OPP_W - 1:0] opp_a;
reg signed [OPP_W - 1:0] opp_b;

reg signed [OPP_W - 1:0] opp_a_out;
reg signed [OPP_W - 1:0] opp_b_out;

wire [2 * OPP_W - 1:0] out;

initial begin
  $dumpfile("tb_multiplier_int.vcd");
  $dumpvars;

  clk = 0;
  aresetn = 0;

  opp_a = 0;
  opp_b = 0;

  opp_a_out = 0;
  opp_b_out = 0;

  #(RESET_DURATION);

  aresetn = 1;

  #(OPP_W * CLK_PERIOD);

  #(TEST_COUNT * CLK_PERIOD);
  $finish;
end

// Clock generator
always begin
  #(CLK_PERIOD / 2);
  clk = ~clk;
end

always@(posedge clk) begin
  if(aresetn == 1) begin
    opp_a <= $random % (1 << OPP_W);
    opp_b <= $random % (1 << OPP_W);

    opp_a_out <= dut.opp_a_sign[OPP_W - 1] ? -dut.opp_a_pipe[OPP_W - 1] :
      dut.opp_a_pipe[OPP_W - 1];
    opp_b_out <= dut.opp_b_sign[OPP_W - 1] ? -dut.opp_b_pipe[OPP_W - 1] :
      dut.opp_b_pipe[OPP_W - 1];

    if($signed(out) != opp_a_out * opp_b_out) begin
      $display("Computation error! %d x %d != %d", opp_a_out, opp_b_out, out);
    end
  end
end

multiplier_int#(
  .OPP_W(OPP_W)
) dut(
  .clk(clk),
  .aresetn(aresetn),

  .opp_a(opp_a),
  .opp_b(opp_b),

  .out(out)
);

endmodule

