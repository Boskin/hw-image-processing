module multiply_accumulate(
  clk,
  aresetn,

  reset,

  data,
  multi,

  result,
  overflow
);
  parameter I_OPP_W = 4;
  parameter O_OPP_W = 2 * I_OPP_W;

  input clk;
  input aresetn;

  input reset;

  input [I_OPP_W - 1:0] data;
  input [I_OPP_W - 1:0] multi;

  output reg [O_OPP_W - 1:0] result;
  output reg overflow;

  wire [2 * I_OPP_W - 1:0] product;

  always@(posedge clk, negedge aresetn) begin
    if(aresetn == 0) begin
      result <= 0;
      overflow <= 0;
    end else if(reset == 1) begin
      result <= 0;
      overflow <= 0;
    end else begin
      result <= result + product;
      overflow <= result[O_OPP_W - 1] ^ product[2 * I_OPP_W - 1];
    end
  end

  multiply_accumulate#(
    .OPP_W(I_OPP_W)
  ) u0(
    .clk(clk),
    .aresetn(aresetn),

    .opp_a(data),
    .opp_b(multi),

    .out(product)
  );

endmodule

