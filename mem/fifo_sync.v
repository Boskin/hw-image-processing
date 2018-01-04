/* Synchronous FIFO module:
 * SIZE must be a power of 2, this makes the pointer loop around logic easy
 * data_rd peeks at the data that is at the tail
 * it takes 1 cycle to write data_wr into the FIFO */
module fifo_sync(
  clk,
  aresetn,

  // Write side
  data_wr,
  wr_en,

  // Read side, data
  data_rd,
  rd_en,

  // Data count and other related signals
  data_count,
  full,
  overflow,
  empty,
  underflow
);
  parameter DATA_W = 8;
  parameter SIZE = 32;

  localparam SIZE_W = $clog2(SIZE) + 1;
  localparam POINTER_W = $clog2(SIZE);

  input clk;
  input aresetn;

  input [DATA_W - 1:0] data_wr;
  input wr_en;

  output reg [DATA_W - 1:0] data_rd;
  input rd_en;

  output reg [SIZE_W - 1:0] data_count;
  output full;
  output reg overflow;
  output empty;
  output reg underflow;

  reg [DATA_W - 1:0] data [0:SIZE - 1];
  reg [POINTER_W - 1:0] head;
  reg [POINTER_W - 1:0] tail;

  // Set full and empty signals accordingly
  assign full = data_count == SIZE;
  assign empty = data_count == 0;

  integer i;
  always@(posedge clk, negedge aresetn) begin
    if(aresetn == 0) begin
      for(i = 0 ; i < SIZE; i = i + 1) begin
        data[i] <= 0;
      end

      data_rd <= 0;
      data_count <= 0;
      overflow <= 0;
      underflow <= 0;

      head <= 0;
      tail <= 0;
    end else begin
      // By default these should be deasserted
      overflow <= 0;
      underflow <= 0;

      // Read
      if(rd_en == 1) begin
        // Check for an underflow
        if(empty == 1) begin
          underflow <= 1;
        end else begin
          data_rd <= data[tail];
          data_count <= data_count - 1;
          tail <= tail + 1;
        end
      end

      // Write
      if(wr_en == 1) begin
        // Check for an overflow
        if(full == 1) begin
          overflow <= 1;
          // Overwrite the oldest element
          tail <= tail + 1;
        end else begin
          data_count <= data_count + 1;
        end

        // Always write, even if there is an overflow
        data[head] <= data_wr;
        head <= head + 1;
      end
    end
  end
endmodule
