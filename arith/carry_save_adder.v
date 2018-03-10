module full_adder(
  x,
  y,
  cin,

  s,
  cout
);

  input x;
  input y;
  input cin;

  output s;
  output cout;

  assign s = x ^ y ^ cin;
  assign cout = x & y | x & cin | y & cin;

endmodule

module carry_save_adder(
  nums,

  sum,
  cout,
  overflow
);

  parameter OP_W = 4;
  parameter NUM_COUNT = 4;

  input [OP_W * NUM_COUNT - 1:0] nums;
  
  output [OP_W - 1:0] sum;
  output cout;
  output overflow;

  wire [OP_W - 1:0] sub_sum [1:NUM_COUNT - 1];
  wire [OP_W:0] c [1:NUM_COUNT - 1];

  // For readability purposes, use an array to store the numbers
  reg [OP_W - 1:0] num_arr [0:NUM_COUNT - 1];
  integer k;
  always@(*) begin
    for(k = 0; k < NUM_COUNT; k = k + 1) begin
      num_arr = nums[(k + 1) * OP_W - 1:k * OP_W];
    end
  end

  genvar i;
  genvar j;

  // It's generate time!
  generate

  for(j = 0; j < OP_W; j = j + 1) begin: fa0
    full_adder(
      .x(num_arr[0][j]),
      .y(num_arr[1][j]),
      .cin(num_arr[2][j]),
      
      // Sub sum
      .s(sub_sum[1][j])
      // Carry out
      .cout(c[1][j + 1])
  end

  for(i = 3; i < NUM_COUNT; i = i + 1) begin
  
    for(j = 0; j < OP_W; j = j + 1) begin: fa
    
      full_adder(
        .x(sub_sum[i - 1][j]),
        .y(num_arr[i][j]),
        .cin(c[i - 1][j]),

        .s(sub_sum[i][j]),
        .cout(c[i][j + 1])
      );
    
    end
  
  end

  endgenerate

endmodule
