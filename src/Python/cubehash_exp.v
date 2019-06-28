module cubehash_exp (
input clk,
input rst_p,
input in_en,
input [7:0] part_msg, // inst to byte_to_256
input load,  //inst to byte_to_256
input start,
output reg out_en,
output err,
output wire [7:0] hash1,
output wire stop_process_fake
);

wire [255:0] hash;

parameter [1023:0] iv = 1024'hea2bd4b4_ccd6f29f_63117e71_35481eae_22512d5b_e5d94e63_7e624131_f4cc12be_c2d0b696_42af2070_d0720c35_3361da8c_28cceca4_8ef8ad83_4680ac00_40e5fbab_d89041c3_6107fbd5_6c859d41_f0b26679_09392549_5fa25603_65c892fd_93cb6285_2af2b5ae_9e4b4e60_774abfdd_85254725_15815aeb_4ab6aad6_9cdaf8af_d6032c0a;

reg [1023:0] almost_hash;
/////// cubehash_round
reg [1023:0] rount_input;
wire [1023:0] rount_output;

///////controller
wire xor_fin;
wire out_en1;
wire stop_process;
wire stop_process_fake1;



// byte_to_256
wire done;
wire [255:0] msg;

reg [1023:0] data_out;
reg [1023:0] current_state;
reg iv_rou;

wire [1023:0] state_xored_msg;
reg [1023:0] mid_state;

//reg r1, r2,r3;
assign stop_process_fake = stop_process_fake1;

always @(posedge clk) begin
	if (rst_p == 1'b1)
		out_en <= 1'b0;
	else
		out_en <= out_en1 | out_en;
end

	
	
always @(*)
begin
	if(stop_process == 1'b0 && start == 1'b1 && done == 1'b1 )
		iv_rou = 1'b1;
	else 
		iv_rou = 1'b0;
	
end

assign state_xored_msg = {mid_state[1023-:256]^msg, mid_state[1023-256:0]};


always @(*) begin

	if(iv_rou == 1'b1)
		 mid_state = iv;
	else
		 mid_state = rount_output;
end


always @(*) begin
	if(done == 1'b1)
		current_state = state_xored_msg;
	else
		current_state = mid_state;
end


always @(*) begin
		if(xor_fin == 1'b1)
			rount_input = {data_out[1023:1] , data_out[0]^1'b1};
		else
			rount_input = data_out;
end


always @(posedge clk) begin
	if (rst_p == 1'b1)
		almost_hash <= {1024 {1'b0}};
	else if( out_en1 == 1'b1)
		almost_hash <= data_out;
	
end


always @ (posedge clk) begin
	if(rst_p == 1'b1)
		data_out <= {1024{1'b0}};
	else if(stop_process == 1'b0)
		data_out <= current_state;
end
			


genvar j; 


for(j=0; j<256; j = j+32) begin

	 assign hash[j+:4]	= almost_hash[768+(j+24)+:4];
	 assign hash[(j+4)+:4] = almost_hash[768+(j+28)+:4];
	 assign hash[(j+8)+:4] = almost_hash[768+(j+16)+:4];
	 assign hash[(j+12)+:4] = almost_hash[768+(j+20)+:4];
	 assign hash[(j+16)+:4] = almost_hash[768+(j+8)+:4];
	 assign hash[(j+20)+:4] = almost_hash[768+(j+12)+:4];
	 assign hash[(j+24)+:4] = almost_hash[768+j+:4];
	 assign hash[(j+28)+:4] = almost_hash[768+(j+4)+:4];

end

assign hash1 = hash [255-:8];

cubehash_round instan1(

.Rin(rount_input),
.Rout(rount_output)
);

controller_FSM instan2(
.clk(clk),
.rst_p(rst_p),
.in_en(in_en),
.start(start),
.done(done),
.out_en(out_en1),
.xor_fin(xor_fin),
.stop_process(stop_process),
.err(err),
.stop_process_fake(stop_process_fake1)
);

byte_to_256 instan3(
.rst_p(rst_p),
.clk(clk),
.part_msg(part_msg),
.load(load),
.msg(msg),
.done(done)
);

		


endmodule