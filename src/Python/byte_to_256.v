`timescale 1 ns / 1 ps


module byte_to_256(
	input rst_p, // active high
	input clk,
	input [7:0] part_msg,
	input load,
	output reg  [255:0] msg,
	output reg done
	);
	
reg [4:0] adrs;
reg [4:0] adrs1;
reg [255:0] tmp_msg;
reg tc;
wire load_en;
reg r1, r2, r3;

wire done_en;





always @(posedge clk) begin 
	if ( rst_p == 1'b1)
		r3 <= 1'b0;
	else
		r3 <= load;
	end
	
assign load_en = load & !r3;

always @ (posedge clk) begin

	if (rst_p == 1'b1) begin
		adrs <= 6'h00;
		tmp_msg <= {255{1'b0}};
	end
	else if (load_en == 1'b1) begin
		tmp_msg[248 - 8*adrs+:8] <= part_msg;
		adrs <= adrs +1; // check if rise at time!
	end
end	

	
always @(posedge clk) begin
	if (rst_p == 1'b1)
		msg <= {255{1'b0}};
	else if(done_en ==1'b1)
		msg = tmp_msg;	
	end
	

always @(posedge clk) begin
	if (rst_p == 1'b1)
		adrs1 <= 5'h00;
	else if(load_en == 1'b1)
			adrs1 <= adrs;
end
	
always @(*) begin
	if (adrs1 == 5'b11111)
		tc = 1'b1;
	else
		tc = 1'b0;
end	
	
always @(posedge clk) begin 
	if (rst_p == 1'b1) begin
		r1 <= 1'b0;
		r2 <= 1'b0;
		//r3 <= 1'b0;
	end
	else begin
		r1 <=tc;
		r2<=r1;
		//r3<=r2;
	end
end

	
assign done_en = r1 && !r2;

always @ (posedge clk)
begin
	if(rst_p == 1'b1)
		done <= 1'b0;
	else begin
		done <= done_en;
	end
end

endmodule 


// always @(*) begin
		// if (rst == 1'b0) 
			// tc = 1'b0;
		// else if (adrs1 == 5'b11111)
			// tc = 1'b1;
		// else
			// tc = 1'b0;
	// end	

	
// parameter SIZE = 2           ;
// parameter idle  = 2'b01, finish_msg  = 2'b10;
// reg   [SIZE-1:0] state;

// always @ (posedge tc)
// begin : mini_FSM
	// if (rst == 1'b0) begin
		// state <= #1 idle;
		// done <= 1'b0;
	// end else
	
 // case(state)
   // idle : 	begin		
					// done <= 1'b1;
					// state <= finish_msg;
				
			// end
		
   // finish_msg : begin			
					// done <= 1'b0;
					// state <= idle;
			
				// end

   // default : state <= #1 idle;
// endcase
// end