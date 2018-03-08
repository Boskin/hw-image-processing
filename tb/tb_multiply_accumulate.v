module tb_multiply_accumulate;

  localparam CLK_PERIOD = 2;
  localparam RESET_DURATION = CLK_PERIOD * 5;
  localparam NUM_TESTS = 1;

  localparam DATA_W = 4;
  localparam RESULT_W = 16;

  localparam DATA_LEN = 8;

  reg clk;
  reg aresetn;

  reg [DATA_W - 1:0] data [0:DATA_LEN - 1];
  reg [DATA_W - 1:0] multi [0:DATA_LEN - 1];

  reg reset;

  wire [RESULT_W - 1:0] result;
  wire overflow;

  integer i;
  initial begin
    $dumpfile("tb_mulitply_accumulate.vcd");
    $dumpvars;

    clk = 0;
    aresetn = 0;

    for(i = 0; i < DATA_LEN; i = i + 1) begin
      data[i] <= 0;
      multi[i] <= 0;
    end

    #(RESET_DURATION);

    aresetn = 1;

     

  end

  always begin
    #(CLK_PERIOD / 2);
    clk <= ~clk;
  end

  always@(posedge clk) begin
    
  end

  multiply_accumulate#(
    .I_OPP_W(DATA_W),
    .O_OPP_W(RESULT_W)
  ) dut(
    .clk(clk),
    .aresetn(aresetn),

    .reset(reset),

    .result(result),
    .overflow(overflow)
  );

endmodule

