module multiply_add(
  clk,
  aresetn,

  x,
  h,

  saturate,

  sum
);

  parameter KERNEL_LEN = 8;
  parameter I_OPP_W = 8;
  parameter O_OPP_W = 8;

  input clk;
  input aresetn;

  input [I_OPP_W * KERNEL_LEN - 1:0] x;
  input [I_OPP_W * KERNEL_LEN - 1:0] h;

  input saturate;

  output reg [O_OPP_W - 1:0] sum;

  always@(posedge clk, negedge aresetn) begin
    if(aresetn == 0) begin
      sum <= 0;
    end else begin

    end
  end

endmodule
