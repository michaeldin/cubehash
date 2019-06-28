module controller_FSM (
    input clk, rst_p, in_en, start, done, // rst_p is active high
	output reg out_en, stop_process_fake,
	output stop_process, err, xor_fin
);


parameter SIZE = 4;
parameter idle  = 4'b0001, round = 4'b0010, waiting = 4'b0100, fin =4'b1000  ;
reg [SIZE-1:0] state, next_state;

reg [3:0] cnt_16A;
reg [3:0] cnt_10A;

wire out_en1;

always @ (*)
begin : FSM_COMBO
next_state = 4'b0000;

case(state)
	idle : 	begin
				if (start == 1'b1 && in_en == 1'b1 && done == 1'b1) 
					next_state = round;
				else 
					next_state = idle;
			end	
			
///////////////////////////////////////////////////////////////////////////////		
				
	round : begin
				if (cnt_16A == 15) 
				begin
					if (in_en == 1'b0)
						next_state = fin;
					else
						next_state = waiting;
					
				end 
				else
					if( done == 1'b0)
						next_state = round;
					else
						next_state = idle;			
			end
			
///////////////////////////////////////////////////////////////////////////////		
						
	waiting : 	begin
					if (done == 1'b1 && in_en == 1'b1)
						next_state = round;
					else if(in_en == 1'b1 && done == 1'b0)
						next_state = waiting;
					else if(in_en == 1'b0 & done == 1'b0) 
						next_state = fin;
					else 								//error
						next_state = idle;
					
				end
				
///////////////////////////////////////////////////////////////////////////////		

	fin: 	begin
				if (cnt_16A == 15)
				begin
					if (cnt_10A == 9)
						next_state = idle;
					else begin
						if (done  == 1'b0)	
							next_state = fin;
						else 
							next_state = idle;
					end
				end
				else begin
					if (done == 1'b0)
						next_state = fin;
					else
						next_state = idle;
				end
			end
			
///////////////////////////////////////////////////////////////////////////////		

   default : next_state = idle;
  endcase
end

////////////////////////////////////////////////////////////////////

assign stop_process = ((state == round && in_en == 1'b1 && cnt_16A == 15) || (state == waiting && done == 1'b0)) ? 1'b1 : 1'b0;
assign err = ((state == round && cnt_16A != 15 && done == 1'b1) || ( state == fin && (cnt_16A != 15 || cnt_10A != 9) && done ==1'b1) ||(in_en== 1'b0 && done== 1'b1)) ? 1'b1 : 1'b0;
assign xor_fin = (state == fin && cnt_16A == 0 && cnt_10A == 0 && in_en == 0) ? 1'b1 : 1'b0;
assign out_en1 = (state == fin && cnt_10A == 9 && cnt_16A == 15) ? 1'b1 : 1'b0;

always @ (posedge clk) // just for checking
	if(rst_p == 1'b1)
		stop_process_fake <= 1'b0;
	else
		stop_process_fake <= stop_process;

////////////////////////////////////////////////////////////////////////
always @( posedge clk) // out_en
	if (rst_p == 1'b1)
		out_en <= 1'b0;
	else
		out_en <= out_en1;
		
////////////////////////////////////////////////////////////////////////

always @ (posedge clk) // cnt_10A
begin
		if (rst_p == 1'b1)
			cnt_10A = 0;
		else if (state == fin && cnt_16A == 15 && cnt_10A != 9)
			cnt_10A = cnt_10A + 1;
end		

////////////////////////////////////////////////////////////////////////

always @ (posedge clk) // cnt_16A
begin
		if (rst_p == 1'b1)
			cnt_16A = 0;
		else if (state == round || state == fin)
			cnt_16A = cnt_16A + 1;
end		

//----------Seq Logic-----------------------------
always @ (posedge clk)
	begin : FSM_SEQ
		if (rst_p == 1'b1)
			state <=  idle;
		else
			state <=  next_state;
	end
	


endmodule 