module system(
	input clk_proc,
	input clk_vga,
	input rst,
	input [1:0]key_pressed,
	input key_flag,
	input [7:0] vga_x,
	input [7:0] vga_y,
	output reg [2:0] vga_dout,
	output en_vga
	
);

	//outputs from processor to RAM
	//wire [2:0] s_im;
	wire [7:0] nine_x_addr;
	wire [7:0] nine_y_addr;
	wire [2:0] rom1_dout;
	//wire [2:0] rom2_dout;
	//wire [2:0] rom3_dout;
	wire [3:0] ker_addr;
	//reg [2:0] rom_din;
	reg [2:0] pix_din;
	reg [4:0] kerq_dout;
	
	wire we;
	wire [2:0] newpix;
	wire [7:0] pix_x_addr;
	wire [7:0] pix_y_addr;
	wire [0:0] s_ker;
	wire [4:0] ker1_dout;
	//wire [4:0] ker2_dout;
	//wire [4:0] ker3_dout;
	wire [2:0] pix1_dout;
	//wire [2:0] pix2_dout;
	//wire [2:0] pix3_dout;
	wire [2:0] kern_dout;
	//wire [2:0] s_mus;

	
	always@(posedge clk_proc)begin
            	begin
				pix_din <= pix1_dout;
				if(s_ker == 1) //if no kernel is selected display original image, else display convoluted image
					vga_dout <= kern_dout;
				else
					vga_dout <= rom1_dout;
				end
		  begin
			kerq_dout <= ker1_dout;
			end
	end
	processor processor(
		.clk(clk_proc),
		.rst(rst),
		.key_pressed(key_pressed), //key_pressed
		.key_flag(key_flag), //when a key is pressed its high
		//.s_im(s_im),			//selects the current image
		.s_ker(s_ker),			//selects current kernel
		.ker_din(kerq_dout),	//input of kernel
		.ker_addr(ker_addr), 
		.nine_x_addr(nine_x_addr),
		.nine_y_addr(nine_y_addr),
		.pix_din(pix_din), //original image pixel at pix_x pix_Y
		.we(we),					//enables writing to our ram
		.pix_x_addr(pix_x_addr),
		.pix_y_addr(pix_y_addr),
					
		.newpix(newpix), //conv pixel output to ram
		.en_vga(en_vga)
	);
	//vga_dout what goes to the vga
	rom1 r1(					//image one
		.clk_vga(clk_vga),
		.clk_proc(clk_proc),
		.x_proc(nine_x_addr),
		.y_proc(nine_y_addr),
		.x_vga(vga_x),
		.y_vga(vga_y),
		.dout_vga(rom1_dout),
		.dout_proc(pix1_dout)
	);
	
	ram1 rm1(					//where the convoluted image pixels are stored
		.we(we),
		.clk_proc(clk_proc),
		.clk_vga(clk_vga),
		.x_proc(pix_x_addr),
		.y_proc(pix_y_addr),
		.din(newpix),
		.x_vga(vga_x),
		.y_vga(vga_y),
		.dout_vga(kern_dout)
	);
	ker1 kr1(					//kernel 1
		.clk(clk_proc),
		.addr(ker_addr),
		.dout(ker1_dout)
	);	
endmodule
