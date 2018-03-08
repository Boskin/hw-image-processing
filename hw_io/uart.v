module uart(
  clk,
  aresetn,

  // Receive line
  rx,
  // Transmit line
  tx,

  // Byte to be transmitted
  trans,
  // Enable transmit
  trans_en,
  // Byte received
  recv,
  // Asserted if byte is available to be received
  recv_avail
);
  parameter CLK_FREQ = 50000000;
  parameter BAUD = 9600;

  input clk;
  input aresetn;

  input rx;
  output reg tx;

  reg [7:0] transmit_buf;

  reg baud_clk;
  reg [$clog2(CLK_FREQ / BAUD) - 1:0] baud_counter;

  always@(posedge clk) begin
    if(aresetn == 0) begin
      transmit_buf <= 0;

      baud_clk <= 0;
      baud_counter <= 0;
    end else begin
      transmit_buf <= rx;

      // Baud clock generation
      baud_clk <= baud_counter == CLK_FREQ / BAUD / 2;
      baud_counter <= baud_counter + 1;
      if(baud_counter == (CLK_FREQ / BAUD) / 2) begin
        baud_clk <= ~baud_clk;
        baud_counter <= 0;
      end
    end
  end

  /******************/
  /* Transmit logic */
  /******************/
  // Idle state
  localparam TX_IDLE = 0;
  // Transmitting state
  localparam TX_TRANS = 1;

  reg [7:0] transmit_buf_sync0;
  reg [7:0] transmit_buf_sync1;
  reg [7:0] transmit_buf_tx;

  reg trans_en_sync0;
  reg trans_en_sync1;

  reg tx_state;
  reg [3:0] tx_bit_counter;

  always@(posedge baud_clk) begin
    if(aresetn == 0) begin

      tx_state <= TX_IDLE;

      transmit_buf_sync0 <= 0;
      transmit_buf_sync1 <= 0;

      trans_en_sync0 <= 0;
      trans_en_sync1 <= 0;

      tx_bit_counter <= 0;

      tx <= 1;
    end else begin
      transmit_buf_sync0 <= transmit_buf;
      transmit_buf_sync1 <= transmit_buf;

      trans_en_sync0 <= trans_en;
      trans_en_sync1 <= trans_en_sync0;

      case(tx_state)
        TX_IDLE: begin
          if(trans_en_sync1 == 1) begin
            // Start bit
            tx <= 0;

            // Start transmitting the byte
            tx_state <= TX_TRANS;
            // Capture the synchronized register
            transmit_buf_tx <= transmit_buf_sync1;
            // Keep track of how many bits need to be transmitted
            tx_bit_counter <= 8;
          end else begin
            // Hold the line high
            tx <= 1;

            // Remain idle
            tx_state <= TX_IDLE;
            // Don't do anything with these registers
            transmit_buf_tx <= 0;
            tx_bit_counter <= 0;
          end
        end

        TX_TRANS: begin
          if(tx_bit_counter == 0) begin
            // Stop bit
            tx <= 1;

            // Go back to being idle
            tx_state <= TX_IDLE;
            // Reset these registers
            transmit_buf_tx <= 0;
            tx_bit_counter <= 0;
          end else begin
            // Transmit the next bit
            tx <= trransmit_buf_tx[0];

            // Continue transmitting next cycle
            tx_state <= TX_TRANS;
            // Shift the transmit buffer to the right
            transmit_buf_tx[6:0] <= transmit_buf_tx[7:1];
            // Setting the MSb to 0 just to be complete
            transmit_buf_tx[7] <= 0;
            // Decrement the counter
            tx_bit_counter <= tx_bit_counter - 1;
          end
        end
      endcase
    end
  end

  /*****************/
  /* Receive logic */
  /*****************/
  localparam RX_IDLE = 0;
  localparam RX_RECV = 1;

  reg rx_state;

  reg rx_sync0;
  reg rx_sync1;

  reg [7:0] rx_recv;
  reg rx_avail;

  reg [3:0] rx_bit_counter;

  always@(posedge baud_clk) begin
    if(aresetn == 0) begin
      rx_state <= RX_IDLE;
      rx_bit_counter <= 0;
    end else begin
      rx_sync0 <= rx;
      rx_sync1 <= rx;
      case(rx_state)
        RX_IDLE: begin
          if(rx_sync1 == 0) begin
            rx_state <= RX_RECV;
            rx_bit_counter <= 7;
          end else begin
            rx_state <= RX_IDLE;
            rx_bit_counter <= 0;
          end
        end

        RX_RECV: begin
          rx_recv[0] <= rx_sync1;
          rx_recv[7:1] <= rx_recv[6:0];

          if(rx_bit_counter == 0) begin
            rx_state <= RX_IDLE;
          end else begin
            rx_state <= RX_RECV;
            rx_bit_counter <= rx_bit_counter - 1;
          end
        end
      endcase
    end
  end

endmodule
