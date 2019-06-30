/* 
This module is probably the heart of the design.
At this module are specified the signals that run the cubehash.

this module contains the state machine with all the possible states in our design.


 
Explanation about inputs:

clk 	- internal 100MHz clock
rst_p 	- active high synchronous reset
in_en 	- High when there are blocks to send for encryption
start1	- pulse when the first block had been transmitted
done	- pulse when a block arrived to the board


Explanation about outputs:

stop_process	- high when the design waits to signal to determine what it needs to do. this signal freeze all the design
err				- high when an illogical scenario occurs 
xor_fin			- pulse when the design enters to finalization process. the design needs to do a XOR before starting finalization
out_en			- pulse when the hash is ready



Explanation about the states:

idle	- at this states the design is waiting for a trigger to start cubehash

round	- at this states the FSM generates 16 rounds

waiting	- at this state the design waits for a trigger to decide what to do next. at this state the whole logic freezes.

fin		- at this state the design enter to finalization process (XOR and 160 rounds).

 */
 
module controller_FSM (
    input clk, rst_p, in_en, start1, done, 
	output stop_process, err, xor_fin,
	output reg	out_en
);



parameter SIZE = 4;
parameter idle  = 4'b0001, round = 4'b0010, waiting = 4'b0100, fin =4'b1000  ; // one-hot encode
reg [SIZE-1:0] state, next_state;


reg [3:0] cnt_16;	// counts 16 rounds
reg [3:0] cnt_10;	// counts 10 of 16 rounds for finalization (actually counts 160 rounds)



/////////////////////////////////////////////

//logic that even when the input is not connected, the design won't receive "Z".
reg start;

always @(posedge clk) begin 
	if ( rst_p == 1'b1) 
		start <= 0;
	else if(in_en ==1'b1)
		start <= start1;

end

////////////////////////////////////////////////


always @ (*)
begin : FSM_COMBO
next_state = 4'b0000;



case(state)
	idle : 	begin
				if (start == 1'b1 && in_en == 1'b1 && done == 1'b1)	// when it occurs it triggers to start encrypting
					next_state = round;
				else 
					next_state = idle;
			end	
			
///////////////////////////////////////////////////////////////////////////////		
				
	round : begin
				if (cnt_16 == 15)			//  finished 16 rounds
				begin
					if (in_en == 1'b0)		// finished 16 rounds and all the blocks have successfully received 
						next_state = fin;
					else
						next_state = waiting;// finished 16 rounds and there are more blocks to receive
					
				end 
				else						// in the middle of 16 rounds	
				
					if( done == 1'b0)		// in the middle of 16 rounds of current block and there is no new block (this is good)
					
						next_state = round;	// continue with the rounds
						
					else					// in the middle of 16 rounds for current state an a new block arrived (illogical scenario)
					
						next_state = idle;	// stop cubehash and return to idle
						
			end
			
///////////////////////////////////////////////////////////////////////////////		
						
	waiting : 	begin
					if (done == 1'b1 && in_en == 1'b1)		// new block arrived
						next_state = round;
					else if(in_en == 1'b1 && done == 1'b0)	// should arrive new block but it didn't arrive yet.
						next_state = waiting;
					else if(in_en == 1'b0 & done == 1'b0)	// finished receiving the message to encrypt
						next_state = fin;
					else 									// shouldn't arrive block but somehow arrives a new block (illogical scenario).
						next_state = idle;					// stop cubehash and return to idle
					
				end
				
///////////////////////////////////////////////////////////////////////////////		

	fin: 	begin
				if (cnt_16 == 15)				// finished 16 rounds
				begin
					if (cnt_10 == 9)			// finished 10 times 16 rounds (160 rounds)
						next_state = idle;		// end of successful cubehash encryption
						
					else begin					// finished a 16 rounds cycle but didn't achieve yet 160 rounds
					
						if (done  == 1'b0)		// no new block arrives (this is good)
							next_state = fin;	// continue with finalization
							
						else 					// at finalization and a new block arrives (illogical scenario).
							next_state = idle;
					end
				end
				else begin						// in the middle of 16 cycle of 16 rounds
				
					if (done == 1'b0)			// no new block arrives
						next_state = fin;		// continue with finalization
						
					else						// at finalization and a new block arrives (illogical scenario).
						next_state = idle;		// stop cubehash and return to idle
				end
			end
			
///////////////////////////////////////////////////////////////////////////////		

   default : next_state = idle;
  endcase
end


//----------Seq Logic-----------------------------
always @ (posedge clk)
	begin : FSM_SEQ
		if (rst_p == 1'b1)
			state <=  idle;
		else
			state <=  next_state;
	end
	
//////////////////////////////////////////////////////////////

// stop_process is High when there is no enough information to know what to do
assign stop_process = ((state == round && in_en == 1'b1 && cnt_16 == 15) || (state == waiting && done == 1'b0 && in_en == 1'b1)) ? 1'b1 : 1'b0;

//	err is High when an illogical scenario occurs
assign err = ((state == round && cnt_16 != 15 && done == 1'b1) || ( state == fin && (cnt_16 != 15 || cnt_10 != 9) && done ==1'b1) ||(in_en== 1'b0 && done== 1'b1)) ? 1'b1 : 1'b0;

// xor_fin is high when finalization process is starting
assign xor_fin = (state == fin && in_en == 1'b0 & done == 1'b0 && cnt_10 ==0 && cnt_16 == 0) ? 1'b1 : 1'b0;

// out_en1 is high when cubehash is finished successfully
assign out_en1 = (state == fin && cnt_10 == 9 && cnt_16 == 15) ? 1'b1 : 1'b0;




////////////////////////////////////////////////////////////////////////

// a signal that indicate whether cubehash has finished. it passed to other blocks one clock after it really occurs because there is a delay of
// one clock cycle till the hash is loaded in the registers  
  always @( posedge clk) 
	  if (rst_p == 1'b1)
		  out_en <= 1'b0;
	  else
		  out_en <= out_en1;
		
////////////////////////////////////////////////////////////////////////

// logic that counts 160 rounds (16*10 rounds)
always @ (posedge clk) 
begin
		if (rst_p == 1'b1)
			cnt_10 = 0;
		else if (state == fin && cnt_16 == 15 && cnt_10 != 9)
			cnt_10 = cnt_10 + 1;
end		

////////////////////////////////////////////////////////////////////////

// logic that counts 16 rounds
always @ (posedge clk) // cnt_16
begin
		if (rst_p == 1'b1)
			cnt_16 = 0;
		else if (state == round || state == fin)
			cnt_16 = cnt_16 + 1;
end		


	


endmodule 