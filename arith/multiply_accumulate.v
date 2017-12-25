module multiply_accumulate(
  clk,
  aresetn,

  data,
  multi,

  result
);
  parameter DATA_OPP_W = 4;
  parameter MULTI_OPP_W = 4;

  parameter RESULT_OPP_W = 2 * I_OPP_W;

  input clk;
  input aresetn;

  input [DATA_OPP_W - 1:0] data;
  input [MULTI_OPP_W - 1:0] multi;

  output reg  [O_OPP_W - 1:0] result;

  

endmodule

