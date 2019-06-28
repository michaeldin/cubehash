module out_rst (
input clk,
input rst_p,
//output level_rise_rst,
output level_fall_rst
);

reg [12:0] cntr_fall;

always @(posedge clk) begin

	if (rst_p == 1'b1)
		cntr_fall <= 0;
	else if(cntr_fall < 13'h1fff)
		cntr_fall <= cntr_fall + 1;

end

assign level_fall_rst = (cntr_fall != 13'h1fff) ? 1'b1 : 1'b0;

endmodule
		
