`define ASSERT(cond) \
  if(!(cond)) begin \
    $display("Assertion failed at time %d!", $time); \
    $finish; \
  end

module tb_fifo_sync;

  localparam CLK_PERIOD = 2;
  localparam RESET_DURATION = 5;

  localparam DATA_W = 10;
  localparam SIZE = 16;

  reg clk;
  reg aresetn;

  wire [DATA_W - 1:0] data_rd;
  reg rd_en;

  reg [DATA_W - 1:0] data_wr;
  reg wr_en;

  wire [$clog2(SIZE):0] data_count;
  wire full;
  wire overflow;
  wire empty;
  wire underflow;

  reg [DATA_W - 1:0] test_data [0:SIZE];

  integer i;
  initial begin
    $dumpfile("tb_fifo_sync.vcd");
    $dumpvars;

    clk = 0;
    aresetn = 0;

    rd_en = 0;
    data_wr = 0;
    wr_en = 0;

    // Generate a batch of test data
    for(i = 0; i < SIZE + 1; i = i + 1) begin
      test_data[i] = $random % (1 << DATA_W);
    end

    #(RESET_DURATION * CLK_PERIOD);

    aresetn = 1;

    #(CLK_PERIOD);

    $display("Reset test!");

    `ASSERT(data_count == 0)
    `ASSERT(full == 0)
    `ASSERT(overflow == 0)
    `ASSERT(empty == 1)
    `ASSERT(underflow == 0)

    rd_en = 1;

    #(CLK_PERIOD);

    $display("Testing underflow condition!");

    `ASSERT(data_count == 0)
    `ASSERT(full == 0)
    `ASSERT(overflow == 0)
    `ASSERT(empty == 1)
    `ASSERT(underflow == 1)

    rd_en = 0;

    $display("Testing data write!");
    wr_en = 1;
    for(i = 0; i < SIZE; i = i + 1) begin
      $display("[%d] writing %d", i, test_data[i]);

      data_wr = test_data[i];

      #(CLK_PERIOD);

      `ASSERT(data_count == i + 1)
      `ASSERT(full == (i == SIZE - 1))
      `ASSERT(overflow == 0)
      `ASSERT(empty == 0)
      `ASSERT(underflow == 0)
    end

    data_wr = test_data[SIZE];

    #(CLK_PERIOD);

    $display("Testing overflow condition!");

    `ASSERT(data_count == SIZE)
    `ASSERT(full == 1)
    `ASSERT(overflow == 1)
    `ASSERT(empty == 0)
    `ASSERT(underflow == 0)

    $display("Testing data read!");
    wr_en = 0;
    rd_en = 1;
    for(i = 1; i <= SIZE; i = i + 1) begin
      #(CLK_PERIOD);

      `ASSERT(data_rd == test_data[i])
      `ASSERT(data_count == SIZE - i)
      `ASSERT(full == 0)
      `ASSERT(overflow == 0)
      `ASSERT(empty == (i == SIZE))
      `ASSERT(underflow == 0)

    end

    wr_en = 1;
    rd_en = 0;
    for(i = 0; i < SIZE / 2; i = i + 1) begin
      data_wr = test_data[i];
      #(CLK_PERIOD);

      `ASSERT(data_count == i + 1)
      `ASSERT(full == 0)
      `ASSERT(overflow == 0)
      `ASSERT(empty == 0)
      `ASSERT(underflow == 0)
    end

    $display("Testing read and write at the same time!");
    wr_en = 1;
    rd_en = 1;
    for(i = 0; i < SIZE / 2; i = i + 1) begin
      data_wr = test_data[i + SIZE / 2];

      #(CLK_PERIOD);

      `ASSERT(data_rd == test_data[i])
      `ASSERT(data_count == SIZE / 2)
      `ASSERT(full == 0)
      `ASSERT(overflow == 0)
      `ASSERT(empty == 0)
      `ASSERT(underflow == 0)
    end

    wr_en = 0;
    for(i = SIZE / 2; i < SIZE; i = i + 1) begin
      #(CLK_PERIOD);

      `ASSERT(data_rd == test_data[i])
      `ASSERT(data_count == SIZE - i - 1)
      `ASSERT(full == 0)
      `ASSERT(overflow == 0)
      `ASSERT(empty == (i == SIZE - 1))
      `ASSERT(underflow == 0)
    end

    $display("All assertions passed!");
    $finish;
  end

  // Clock generator
  always begin
    #(CLK_PERIOD / 2);
    clk = ~clk;
  end

  // FIFO instantiation
  fifo_sync#(
    .DATA_W(DATA_W),
    .SIZE(SIZE)
  ) dut(
    .clk(clk),
    .aresetn(aresetn),

    // Data to write
    .data_wr(data_wr),
    // Write enable
    .wr_en(wr_en),

    // Data read
    .data_rd(data_rd),
    // Read enable
    .rd_en(rd_en),

    // Data count
    .data_count(data_count),
    // Asserted if full
    .full(full),
    // Asserted if a write happens when the FIFO is full
    .overflow(overflow),
    // Asserted if no data is in the FIFO
    .empty(empty),
    // Asserted if a read is attempted when empty
    .underflow(underflow)
  );

endmodule
