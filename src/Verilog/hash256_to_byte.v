/* 

At this module when the hash is ready - 32 registers are loaded with the 32 bytes of the hash 
and each clock enable the information continue to next register till all the bits had been transmitted. 

according to our experiments, the optimal pulse for the Raspberry Pi Zero load signal is 20ms, 
less than this it won't notice the pulse 

 */

module hash256_to_byte(
	input rst_p, 			// active high synchronous reset
	input clk,				// internal 100MHz clock
	input [255:0] hash,		// hashed message to transmit
	input out_en,			// when High start transmitting
	output [7:0] part_hash,	// 8 bits of the 256 bits hashed message
	output load_rpi0 	// High when needs to inform Rpi Zero to read the pins of 8 bits of hashed message
	);
	
reg [21:0] cnt22bit;	// counts the time load_rpi0 is high and low

wire clk_en;			// proceeding the hashed message on the 32 registers

reg level_out_en;		// High when the hashed message is ready.


// declaration of 32 registers of hashed message
reg [7:0] hash_div0;
reg [7:0] hash_div1;
reg [7:0] hash_div2;
reg [7:0] hash_div3;
reg [7:0] hash_div4;
reg [7:0] hash_div5;
reg [7:0] hash_div6;
reg [7:0] hash_div7;
reg [7:0] hash_div8;
reg [7:0] hash_div9;
reg [7:0] hash_div10;
reg [7:0] hash_div11;
reg [7:0] hash_div12;
reg [7:0] hash_div13;
reg [7:0] hash_div14;
reg [7:0] hash_div15;
reg [7:0] hash_div16;
reg [7:0] hash_div17;
reg [7:0] hash_div18;
reg [7:0] hash_div19;
reg [7:0] hash_div20;
reg [7:0] hash_div21;
reg [7:0] hash_div22;
reg [7:0] hash_div23;
reg [7:0] hash_div24;
reg [7:0] hash_div25;
reg [7:0] hash_div26;
reg [7:0] hash_div27;
reg [7:0] hash_div28;
reg [7:0] hash_div29;
reg [7:0] hash_div30;
reg [7:0] hash_div31;

// to facilitate writing the hashed message will be on two-dimensional array  32*8
wire [7:0] arr_hash [0:31];


reg [4:0] cnt_32; // counts 32 pulses of clk_en

wire finish_transmitting;


// a small FSM to control the sending information process
parameter SIZE = 2;
parameter idle  = 2'b01,send_bytes = 2'b10;

//-------------Internal Variables---------------------------
reg   [SIZE-1:0]          state        ;// Seq part of the FSM
reg   [SIZE-1:0]          next_state   ;// combo part of FSM

always @ (*)
begin : FSM_COMBO_SEND
	next_state = 2'b00;
	case(state)
	
////////////////////////////////////////////////////////////////////////
	
		idle :  
		
		if (out_en == 1'b1)
			next_state = send_bytes;
		else
			next_state = idle;
			
////////////////////////////////////////////////////////////////////////	
 
		send_bytes : 
		
		if (finish_transmitting == 1'b0) 
			next_state = send_bytes;
		else 
			next_state = idle;
			
////////////////////////////////////////////////////////////////////////
				  
		default : next_state = idle;
		
	endcase
end



always @ (posedge clk)
begin : FSM_SEQ_SEND
  if (rst_p == 1'b1) begin
    state <=  idle;
  end else begin
    state <=  next_state;
  end
end


// wiring the hashed message in two - dimensional array
genvar i;

for (i = 0; i < 32; i = i + 1) 
	assign arr_hash[i] = hash[255-8*i: 248 - 8*i];

	
// logic that generates a 22 bits counter, starting when the hash is ready
always @ (posedge clk) begin

	if(rst_p == 1'b1)
		cnt22bit <= 0;
	else if(level_out_en == 1'b1 && state == send_bytes)
		cnt22bit <= cnt22bit + 1;
end


//logic that generates a pulse when new 8 bits should load to the pins of Basys 3 (load_rpi0 will be high also)
assign clk_en = (cnt22bit == 22'h3fffff && cnt_32 != 5'h1f) ? 1'b1 : 1'b0; 





// logic that creates a delayed pulse when the hash is ready (one clock after it's ready)
reg r1;
wire r2;

always @ (posedge clk) begin
	if(rst_p == 1'b1)
		r1 <= 1'b0;
	else
		r1 <= level_out_en ;
end

assign r2 = level_out_en  & !r1; // r2 will be High for one clock just after one clock the hash is ready.



always @ (posedge clk) begin

 
	if (rst_p == 1'b1) begin	// reset the 32 registers

		hash_div0 	<= 8'h00;
		hash_div1 	<= 8'h00;
		hash_div2 	<= 8'h00;
		hash_div3 	<= 8'h00;
		hash_div4 	<= 8'h00;
		hash_div5 	<= 8'h00;
		hash_div6 	<= 8'h00;
		hash_div7 	<= 8'h00;
		hash_div8 	<= 8'h00;
		hash_div9 	<= 8'h00;
		hash_div10 	<= 8'h00;
		hash_div11 	<= 8'h00;
		hash_div12 	<= 8'h00;
		hash_div13 	<= 8'h00;
		hash_div14 	<= 8'h00;
		hash_div15 	<= 8'h00;
		hash_div16 	<= 8'h00;
		hash_div17 	<= 8'h00;
		hash_div18 	<= 8'h00;
		hash_div19 	<= 8'h00;
		hash_div20 	<= 8'h00;
		hash_div21 	<= 8'h00;
		hash_div22 	<= 8'h00;
		hash_div23 	<= 8'h00;
		hash_div24 	<= 8'h00;
		hash_div25 	<= 8'h00;
		hash_div26 	<= 8'h00;
		hash_div27 	<= 8'h00;
		hash_div28 	<= 8'h00;
		hash_div29 	<= 8'h00;
		hash_div30 	<= 8'h00;
		hash_div31 	<= 8'h00;

	end		
	else if(out_en == 1'b1 || r2 == 1'b1)	begin	// initialize them with the hash
	
		hash_div0 	<=  	arr_hash[0]	;
		hash_div1 	<=  	arr_hash[1]	;
		hash_div2 	<=  	arr_hash[2]	;
		hash_div3 	<=  	arr_hash[3]	;
		hash_div4 	<=  	arr_hash[4]	;
		hash_div5 	<=  	arr_hash[5]	;
		hash_div6 	<=  	arr_hash[6]	;
		hash_div7 	<=  	arr_hash[7]	;
		hash_div8 	<=  	arr_hash[8]	;
		hash_div9 	<=  	arr_hash[9]	;
		hash_div10 	<=  	arr_hash[10];
		hash_div11 	<=  	arr_hash[11];
		hash_div12 	<=  	arr_hash[12];
		hash_div13 	<=  	arr_hash[13];
		hash_div14 	<=  	arr_hash[14];
		hash_div15 	<=  	arr_hash[15];
		hash_div16 	<=  	arr_hash[16];
		hash_div17 	<=  	arr_hash[17];
		hash_div18 	<=  	arr_hash[18];
		hash_div19 	<=  	arr_hash[19];
		hash_div20 	<=  	arr_hash[20];
		hash_div21 	<=  	arr_hash[21];
		hash_div22 	<=  	arr_hash[22];
		hash_div23 	<=  	arr_hash[23];
		hash_div24 	<=  	arr_hash[24];
		hash_div25 	<=  	arr_hash[25];
		hash_div26 	<=  	arr_hash[26];
		hash_div27 	<=  	arr_hash[27];
		hash_div28 	<=  	arr_hash[28];
		hash_div29 	<=  	arr_hash[29];
		hash_div30 	<=  	arr_hash[30];
		hash_div31 	<=  	arr_hash[31];
		

	end			
	else if(clk_en == 1'b1 && state == send_bytes) 	begin	// move content to next reg when clk_en has pulse
	
		hash_div0 	<=  hash_div1	;
		hash_div1 	<=  hash_div2	;
		hash_div2 	<=  hash_div3	;
		hash_div3 	<=  hash_div4	;
		hash_div4 	<=  hash_div5	;
		hash_div5 	<=  hash_div6	;
		hash_div6 	<=  hash_div7	;
		hash_div7 	<=  hash_div8	;
		hash_div8 	<=  hash_div9	;
		hash_div9 	<=  hash_div10	;
		hash_div10 	<=  hash_div11	;
		hash_div11 	<=  hash_div12	;
		hash_div12 	<=  hash_div13	;
		hash_div13 	<=  hash_div14	;
		hash_div14 	<=  hash_div15	;
		hash_div15 	<=  hash_div16	;
		hash_div16 	<=  hash_div17	;
		hash_div17 	<=  hash_div18	;
		hash_div18 	<=  hash_div19	;
		hash_div19 	<=  hash_div20	;
		hash_div20 	<=  hash_div21	;
		hash_div21 	<=  hash_div22	;
		hash_div22 	<=  hash_div23	;
		hash_div23 	<=  hash_div24	;
		hash_div24 	<=  hash_div25	;
		hash_div25 	<=  hash_div26	;
		hash_div26 	<=  hash_div27	;
		hash_div27 	<=  hash_div28	;
		hash_div28 	<=  hash_div29	;
		hash_div29 	<=  hash_div30	;
		hash_div30 	<=  hash_div31	;
	end

		
end
		
		
assign part_hash = hash_div0;	// the 8 bits that need to be transmitted are always on the last register.	
		
	
// logic that generates a pulse when the data is ready to be transmitted with 50% duty cycle.

/* always @ (posedge clk) begin

	if(rst_p == 1'b1)
		load_rpi0 <= 0;
	else if(cnt22bit <=8'h7f && state == send_bytes) //change
		load_rpi0 <= 1'b1;
	else
		load_rpi0 <= 1'b0;
end */

assign load_rpi0 = (state == idle) ? 1'b0 : !cnt22bit[21];
/////////////////////////////////////////////////////////// 

// logic that counts 32 bytes of hash
always @ (posedge clk) begin

	if(rst_p == 1'b1)
		cnt_32 <= 0;
	else if(clk_en == 1'b1 && state == send_bytes)
		cnt_32 <= cnt_32 + 1;
end	

// a flag that inform the FSM that all the data had been transmitted
assign finish_transmitting = (cnt22bit == 22'h3fffff && cnt_32 == 5'h1f) ? 1'b1 : 1'b0; 



/////////////////////////////////////////////////////////////////

always @ (posedge clk) begin
	if(rst_p == 1'b1)
		level_out_en <= 1'b0;
	else
		level_out_en <= out_en | level_out_en;
end






endmodule
