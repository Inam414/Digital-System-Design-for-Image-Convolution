module controllerPath(
input clk,
  input rst,
input ker_final_addr, //flag activated when all kernel pixels have been loaded
input nine_flag, //flag that goes high when all nine pixels from original image have been loaded
input pix_final_addr, //flag that gose high when all of the images pixels have been convoluted
input [1:0]key_pressed,
input key_flag,
input sum_flag, //flag that goes high when the output of the matrix multiplciation is added up.
//output reg en_ker,
output reg en_vga,
output reg en_read_pix,
output reg s_read_pix,
output reg en_apply_ker,
output reg s_apply_ker,
output reg s_ker_addr,
output reg en_ker_addr,
output reg en_load_nine,
output reg s_load_nine,
output reg en_key,
output reg s_key,
output reg en_rst_sumnine,
output reg s_inc_ker,
output reg s_inc_pix,
output reg en_inc_pix,
output reg s_inc_nine,
output reg s_inc_sum,
output reg en_final_ker,
output reg en_inc_ker,
output reg en_inc_nine,
output reg en_inc_sum,
output reg en_rst_nine,
output reg en_rst_inc_pix,

output reg s_final_ker
);

parameter INIT = 5'd0;
  parameter READ_KEY = 5'd1;
parameter HOLD = 5'd2;
parameter READ_KER = 5'd3;
parameter READ_PIX = 5'd4;
parameter LOAD_NINE = 5'd5; //YO
parameter APPLY_KER = 5'd6;
parameter INC_KER = 5'd7;
parameter INC_PIX = 5'd8; //yo
parameter INC_NINE = 5'd9; //yo
parameter INC_SUM = 5'd10;
parameter FINAL_KER = 5'd11;

reg [4:0] state, nextstate;

always @(posedge clk)
if(rst)
state <= INIT;
else
state <= nextstate;

always @(*) begin
s_read_pix = 0;
en_read_pix = 0;
en_ker_addr = 0; s_ker_addr = 0;
s_apply_ker = 0; en_apply_ker = 0;
en_load_nine = 0; s_load_nine = 0;
en_key = 0; s_key = 0; s_inc_nine = 0;
s_inc_ker = 0; s_inc_pix = 0;
en_final_ker = 0; s_final_ker =0;
s_inc_sum = 0;
en_inc_ker = 0; en_inc_nine = 0;
en_inc_pix = 0; en_inc_sum = 0; en_rst_nine = 0;
en_rst_inc_pix = 0; en_rst_sumnine = 0;
nextstate = INIT;
case (state)
INIT: begin
en_ker_addr = 1; s_ker_addr = 0;
  en_read_pix = 1; s_read_pix = 0;
en_load_nine= 1; s_load_nine = 0;
en_apply_ker = 1; s_apply_ker = 0;
en_key = 1; s_key = 0;
s_inc_ker = 0; en_inc_ker = 1;

s_inc_pix = 0;

s_inc_sum = 0;

en_final_ker = 1; s_final_ker = 0;
en_inc_nine= 1; s_inc_nine = 0;
en_inc_pix= 1; en_inc_sum = 1;
en_rst_nine = 1;
en_rst_inc_pix = 1; en_rst_sumnine = 1;
if (key_flag)
nextstate = READ_KEY;
else
nextstate = INIT;

end
READ_KEY: begin //This state reads the key and decides how to precede

next

en_key = 1; s_key = 1;
case(key_pressed)
2'b00: begin
nextstate = HOLD;
end
2'b11: begin
nextstate = READ_KER;
end
default: ;
endcase
end
HOLD: begin //Our final state that

keeps the current image on the display
s_final_ker = 0;
en_vga=1;
if(key_flag)
nextstate = READ_KEY;
else
nextstate = HOLD;
  end
READ_KER: begin //reads in our nine

kernel pixels

en_ker_addr = 1; s_ker_addr = 1;
nextstate = INC_KER;
end
INC_KER: begin //increments the

address for above state

en_inc_ker = 1; s_inc_ker = 1;
if(ker_final_addr)
nextstate = LOAD_NINE;
else
nextstate = READ_KER;

end
READ_PIX: begin //chooses the pixel to

be convoluted from original image

en_read_pix = 1; s_read_pix = 1;
en_rst_inc_pix = 1;
if(pix_final_addr)
nextstate = HOLD;
else
nextstate = LOAD_NINE;

end
LOAD_NINE: begin //loads the nine

surrounding pixels

en_load_nine = 1; s_load_nine = 1;
nextstate = INC_NINE;
end
INC_NINE: begin //increments for the

above state

s_inc_nine = 1; en_inc_nine = 1;
if(nine_flag) begin
nextstate = APPLY_KER;
en_rst_nine = 1; //en_rst_inc_pix = 1;
end
else
nextstate = INC_PIX;

end
  INC_PIX: begin
//increments the current pixel address
s_inc_pix = 1; en_inc_pix = 1;
nextstate = LOAD_NINE;
end
APPLY_KER: begin //computes the

matrix multiplication

s_inc_nine = 0; s_inc_pix = 0;
en_apply_ker = 1; s_apply_ker = 1;
nextstate = INC_SUM;
end
INC_SUM: begin //cycles

through addresses for above state

en_inc_sum = 1; s_inc_sum = 1;
if(sum_flag) begin
en_rst_sumnine = 1;
nextstate = FINAL_KER;
end
else
nextstate = APPLY_KER;

end
FINAL_KER: begin //sets the output pixel
s_inc_sum = 0; s_apply_ker = 0; en_apply_ker = 1;
en_final_ker = 1; s_final_ker = 1;
nextstate = READ_PIX;
end
endcase
end
endmodule
module processor(
input clk,
input rst,
input [1:0]key_pressed,
input key_flag,
input [2:0] pix_din,
  input [4:0] ker_din,
//output [2:0] s_im,
output [0:0] s_ker,
output [3:0] ker_addr,
output [7:0] nine_x_addr,
output [7:0] nine_y_addr,
output [7:0] pix_x_addr,
output [7:0] pix_y_addr,
output we,
output [2:0] newpix,
output en_vga
);

wire ker_final_addr;
wire en_ker_addr;
wire s_ker_addr;
wire en_load_nine;
wire s_load_nine;
wire en_read_pix;
wire s_read_pix;
wire pix_final_addr;
wire nine_flag;
//wire nine_final_addr;
wire en_apply_ker;
wire s_apply_ker;
wire en_key;
wire s_key;
wire s_inc_ker;
wire s_inc_pix;
wire s_inc_nine;
wire s_inc_sum;
wire sum_flag;
wire en_divide_ker;
wire s_divide_ker;
wire en_inc_ker;
  wire en_inc_nine;
wire en_inc_pix;
wire en_inc_sum;
wire en_rst_nine;
wire en_rst_inc_pix;
wire en_rst_sumnine;

controllerPath controller(
.clk(clk),
.rst(rst),
.ker_final_addr(ker_final_addr),
.key_pressed(key_pressed),
.key_flag(key_flag),
.en_vga(en_vga),
.s_inc_ker(s_inc_ker),
.en_inc_ker(en_inc_ker),
.en_key(en_key),
.en_inc_nine(en_inc_nine),
.s_key(s_key),
.s_inc_sum(s_inc_sum),
.s_inc_pix(s_inc_pix),
.en_ker_addr(en_ker_addr),
.s_inc_nine(s_inc_nine),
.en_read_pix(en_read_pix),
.s_read_pix(s_read_pix),
.en_load_nine(en_load_nine),
.en_apply_ker(en_apply_ker),
.sum_flag(sum_flag),
.s_apply_ker(s_apply_ker),
.s_load_nine(s_load_nine),
.s_ker_addr(s_ker_addr),
.pix_final_addr(pix_final_addr),
.en_divide_ker(en_divide_ker),
.s_divide_ker(s_divide_ker),
.nine_flag(nine_flag),
  .en_inc_pix(en_inc_pix),
.en_inc_sum(en_inc_sum),
.en_rst_nine(en_rst_nine),
.en_rst_sumnine(en_rst_sumnine),
.en_rst_inc_pix(en_rst_inc_pix)
);

datapath datapath(
.clk(clk),
//.rst(rst),
.ker_din(ker_din),
.key_pressed(key_pressed),
.pix_din(pix_din),
.s_inc_ker(s_inc_ker),
.s_inc_sum(s_inc_sum),
.en_apply_ker(en_apply_ker),
.s_apply_ker(s_apply_ker),
.en_inc_nine(en_inc_nine),
.s_ker(s_ker),
.en_inc_ker(en_inc_ker),
.en_key(en_key),
.s_inc_pix(s_inc_pix),
.s_inc_nine(s_inc_nine),
.s_key(s_key),
.ker_final_addr(ker_final_addr),
.ker_addr(ker_addr),
.en_ker_addr(en_ker_addr),
//.s_im(s_im),
.s_ker_addr(s_ker_addr),
.nine_flag(nine_flag),
.pix_final_addr(pix_final_addr),
.en_read_pix(en_read_pix),
.en_divide_ker(en_divide_ker),
.s_divide_ker(s_divide_ker),
.s_read_pix(s_read_pix),
  .sum_flag(sum_flag),
.nine_x_addr(nine_x_addr),
.nine_y_addr(nine_y_addr),
.en_inc_sum(en_inc_sum),
.s_load_nine(s_load_nine),
.en_load_nine(en_load_nine),
.pix_x_addr(pix_x_addr),
.pix_y_addr(pix_y_addr),
.en_inc_pix(en_inc_pix),
.en_rst_sumnine(en_rst_sumnine),
.we(we),
.newpix(newpix),
.en_rst_nine(en_rst_nine),
.en_rst_inc_pix(en_rst_inc_pix)
);

endmodule
