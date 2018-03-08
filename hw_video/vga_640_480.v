module vga_640_480(
  clk25,
  reset,

  o_vsync,
  o_hsync
);

  input clk25;
  input reset;

  output reg o_vsync;
  output reg o_hsync;

  reg [10:0] counter_x;
  reg [10:0] counter_y;

  always@(posedge clk25) begin
  end

endmodule
