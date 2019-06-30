/* 
this module specifies the instantiation between all the modules.

we chose to do cubehash in iterative implementation,
due consideration of optimization.

there is no need to faster implementation that uses more area because
with our resources of external board, a faster implementation
will not benefit





 */

module top_level(
input clk,				// internal 100MHz clock 
input rst_p,			// active high synchronous reset - recommended from a button 
input in_en,			// High when there are more blocks to send for encryption 
input [7:0] part_block,	// 8 bits as part of a block
input load,  			// when high- new 8 bits had been loaded to pins
input start,			// pulse when the first block had been transmitted
output level_out_en,	// a stable constant signal that inform the other board that cubehash finished
output err, 			// high when an illogical scenario occurs
output [7:0] part_hash,	// 8 bits of the 256 bits hashed message
output load_rpi0,		// High when needs to inform Rpi Zero to read the pins of 8 bits of hashed message
output level_fall_rst,	// stable pulse of RESET
output hash_ready_led	// a led turns on when the hash is ready
);


wire [1023:0] round_input,round_output;
wire [255:0] hash;
wire [255:0] block;
wire stop_process;
wire done;
wire xor_fin;
wire out_en;



cubehash_round instan1(

.Rin(round_input),
.Rout(round_output)
);

controller_FSM instan2(
.clk(clk),
.rst_p(rst_p),
.in_en(in_en),
.start1(start),
.done(done),
.out_en(out_en),
.xor_fin(xor_fin),
.stop_process(stop_process),
.err(err)
);

byte_to_256 instan3(
.rst_p(rst_p),
.clk(clk),
.part_block1(part_block),
.load1(load),
.block(block),
.done(done),
.in_en(in_en)
);

out_rst instan4(
.clk(clk),
.rst_p(rst_p),
.level_fall_rst(level_fall_rst)
);

hash256_to_byte instan5(
.rst_p(rst_p),
.clk(clk),
.hash(hash),
.out_en(out_en),
.part_hash(part_hash),
.load_rpi0(load_rpi0)
);

cubehash instan6(
.clk(clk),
.rst_p(rst_p),
.round_input(round_input),
.round_output(round_output),
.hash_big_endian(hash),
.stop_process(stop_process),
.done(done),
.xor_fin(xor_fin),
.out_en,
.block(block),
.hash_ready_led(hash_ready_led),
.level_out_en(level_out_en),
.in_en(in_en),
.start1(start)

);



endmodule