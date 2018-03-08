module fifo_async(
  clk_rd,
  clk_wr,
  aresetn,

  rd_data,
  rd_en,
  rd_ack,

  data_count_rd,
  full_rd,
  empty_rd,

  wr_data,
  wr_en,

  data_count_wr,
  full_wr,
  empty_wr
);
  parameter DATA_W = 8;
  parameter SIZE = 32;

  localparam POINTER_W = $clog2(SIZE);

  input clk_rd;
  input clk_wr;
  input aresetn;

  output [DATA_W - 1:0] rd_data;
  input rd_en;
  output rd_ack;

  output reg [POINTER_W:0] data_count_rd;
  output full_rd;
  output empty_rd;

  input [DATA_W - 1:0] wr_data;
  input wr_en;

  output reg [POINTER_W:0] data_count_wr;
  output full_wr;
  output empty_wr;

  // All synchronus to clk_wr
  reg [DATA_W - 1:0] data [0:SIZE - 1];
  reg [POINTER_W - 1:0] head;
  reg [POINTER_W - 1:0] tail;

  reg rd_en_sync0;
  reg rd_en_sync1;

  // Full and empty signals synchronous to clk_rd
  assign full_rd = data_count_rd == SIZE;
  assign empty_rd = data_count_rd == 0;

  // Full and empty signals synchronous to clk_wr
  assign full_wr = data_count_wr == SIZE;
  assign empty_wr = data_count_wr == 0;

  integer i;
  always@(posedge clk_wr, negedge aresetn) begin
    if(aresetn == 0) begin
      for(i = 0; i < SIZE; i = i + 1) begin
        data[i] <= 0;
      end

      head <= 0;
      tail <= 0;
    end else begin
      rd_en_sync0 <= rd_en;
      rd_en_sync1 <= rd_en_sync0;

      if(rd_en_sync1 == 1) begin

      end
    end
  end

  always@(posedge clk_rd, negedge aresetn) begin
    if(aresetn == 0) begin

    end else begin

    end
  end

endmodule
