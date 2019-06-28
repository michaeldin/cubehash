
/* 
this module generates inputs & outputs to the block that does one cunehash round.

in several times on the cubehash some XORs and freezing (freezing is because the communication that we chose to 
implement) should be done, and this module takes care of the logic that does it.

 */
 
module cubehash(
input clk,							// internal 100MHz clock
input rst_p,						// active high synchronous reset
input stop_process,					// this signal freeze all the design
input done,							// inform that a new block arrived to the board
input xor_fin,						// inform to XOR the internal state (internal state is the 1024 bits that the cubehash is made of them)
input out_en,						// inform that the cubehash finished and should be transmitted outside the board 
input start1,						// when high it means that now was the first block
input in_en,						// High when there are blocks to send for encryption
input [1023:0] round_output,		// the result of one round
input [255:0] msg,					// the block to be processed
output reg [1023:0] round_input,	// the 1024 bits that should do a round
output hash_ready_led,				// a led turns on when the hash is ready
output [255:0] hash_big_endian,		// as specified on spec, we work on little endian but we want to display in big endian
output reg level_out_en				// a stable constant signal that inform the other board that cubehash finished
);

// this initial vector is a function of h,b and r - and was calculated in advance
parameter [1023:0] iv = 1024'hea2bd4b4_ccd6f29f_63117e71_35481eae_22512d5b_e5d94e63_7e624131_f4cc12be_c2d0b696_42af2070_d0720c35_3361da8c_28cceca4_8ef8ad83_4680ac00_40e5fbab_d89041c3_6107fbd5_6c859d41_f0b26679_09392549_5fa25603_65c892fd_93cb6285_2af2b5ae_9e4b4e60_774abfdd_85254725_15815aeb_4ab6aad6_9cdaf8af_d6032c0a;

reg [255:0] hash_little_endian;

// the flip-flops between output & input of module of one round
reg [1023:0] data_out;

// current internal state
reg [1023:0] current_state;

// signal that inform if to take the iv (at the beginning of cubehash) or the result of round (not in the very beginning of cubehash)
reg iv_rou;

wire [1023:0] state_xored_msg;
reg [1023:0] mid_state;

/////////////////////////////////////////////////////////////

//logic that even when the input is not connected, the design won't receive "Z".
reg start;

always @(posedge clk) begin 
	if ( rst_p == 1'b1) 
		start <= 0;
	else if(in_en ==1'b1)
		start <= start1;

end

/////////////////////////////////////////////////////////////

// logic that decides if now it's the very beginning of cubehash or not

always @(*)
begin
	if(stop_process == 1'b0 && start == 1'b1 && done == 1'b1 )
		iv_rou = 1'b1;
	else 
		iv_rou = 1'b0;
	
end
 
//////////////////////////////////////////////////////////// 

// XORs the new block with the internal state
assign state_xored_msg = {mid_state[1023-:256]^msg, mid_state[1023-256:0]};

// MUXs that decides which 1024 bits to take
always @(*) begin

	if(iv_rou == 1'b1)
		 mid_state = iv;
	else
		 mid_state = round_output;
end


always @(*) begin
	if(done == 1'b1)
		current_state = state_xored_msg;
	else
		current_state = mid_state;
end


// logic that enables the flip-flops just when is needed, otherwise the states freeze
always @ (posedge clk) begin
	if(rst_p == 1'b1)
		data_out <= {1024{1'b0}};
	else if(stop_process == 1'b0)
		data_out <= current_state;
end

// logic that XORs the last word with 1 - when needed
always @(*) begin
		if(xor_fin == 1'b1)
			round_input = {data_out[1023:1] , data_out[0]^1'b1};
		else
			round_input = data_out;
end


/////////////////////////////////////////////////////////////////////

// flip-flops between this module to the module that transmit the hash, they are loaded just when cubehash finished successfully
always @(posedge clk) begin
	if (rst_p == 1'b1)
		hash_little_endian <= {255 {1'b0}};
	else if( out_en == 1'b1)
		hash_little_endian <= data_out[1023-:256];
	
end


// to display the result, we want to change to big endian format
genvar j; 

for(j=0; j<256; j = j+32) begin

	 assign hash_big_endian[j+:4]		= hash_little_endian[(j+24)+:4];
	 assign hash_big_endian[(j+4)+:4] 	= hash_little_endian[(j+28)+:4];
	 assign hash_big_endian[(j+8)+:4] 	= hash_little_endian[(j+16)+:4];
	 assign hash_big_endian[(j+12)+:4] 	= hash_little_endian[(j+20)+:4];
	 assign hash_big_endian[(j+16)+:4] 	= hash_little_endian[(j+8)+:4];
	 assign hash_big_endian[(j+20)+:4] 	= hash_little_endian[(j+12)+:4];
	 assign hash_big_endian[(j+24)+:4] 	= hash_little_endian[j+:4];
	 assign hash_big_endian[(j+28)+:4] 	= hash_little_endian[(j+4)+:4];

end

///////////////////////////////////////////////////////////

//logic that generates HIGH on pmods when the process has finished.
always @(posedge clk) begin
	if (rst_p == 1'b1)
		level_out_en <= 1'b0;
	else
		level_out_en <= out_en | level_out_en;
end

// another signal to drive it to leds also.
assign hash_ready_led = level_out_en;

endmodule