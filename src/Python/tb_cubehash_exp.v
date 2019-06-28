`timescale 1 ns / 1 ps

module tb_cubehash_exp();

reg clk, rst_p, in_en, start, load;
wire [7:0] hash;
wire out_en, err;
reg [7:0] part_msg;

initial 
	clk = 1'b1;
  
always
	#5 clk = ~clk;

initial 
	begin
		rst_p = 1'b1;
		#111;
		rst_p = 1'b0;
	end


initial 
	begin
		start = 1'b0;
		in_en = 1'b0;
		load = 1'b0;
		
		#200;
		in_en = 1'b1;
		start =1'b1;
		repeat (3) begin
		#120
		part_msg = 8'h00;
		load = 1'b1;
		#100
		load = 1'b0;
		end
		
		#120
		part_msg = 8'h80;
		load = 1'b1;
		#100
		load = 1'b0;
		#100
		
		repeat (27) begin
		#120
		part_msg = 8'h00;
		load = 1'b1;
		#100
		load = 1'b0;
		end
		
		
		#120
		part_msg = 8'h00;
		load = 1'b1;
		#100

		load = 1'b0; 
		#1500

		#1000
		start =1'b0;
		#1000
		load = 1'b0;
		#1000
		in_en = 1'b0;
		
		
	end







cubehash_exp DUT1
(
.clk(clk),
.rst_p(rst_p),
.in_en(in_en),
.part_msg(part_msg),
.load(load),
.start(start),
.out_en(out_en),
.hash1(hash),
.err(err)
);



endmodule












