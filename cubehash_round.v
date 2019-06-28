module cubehash_round(
input [1023:0] Rin,
output  [1023:0] Rout
);

wire [31:0] PLUS1[0:15];
wire [31:0] ROT7[0:15];
wire [31:0] SWAP1[0:15];
wire [31:0] XOR1[0:15];
wire [31:0] SWAP2[0:15];
wire [31:0] PLUS2[0:15];
wire [31:0] ROT11[0:15];
wire [31:0] SWAP3[0:15];
wire [31:0] XOR2[0:15];
wire [31:0] SWAP4[0:15];

wire [31:0] arr_Rin [0:31];
wire [31:0] arr_Rout [0:31];

genvar i;

for (i = 0; i < 32; i = i + 1) 
	assign arr_Rin[i] = Rin[1023-32*i: 992 - 32*i];



//------------------------------------------- here the magic of the round is happening

for (i = 0; i < 16; i = i + 1)
	assign	PLUS1[i] = arr_Rin[i] + arr_Rin[i + 16];


for (i = 0; i < 16; i = i + 1)
	assign ROT7[i] = {arr_Rin[i][24:0],arr_Rin[i][31:25]};
 


for (i = 0; i < 8; i = i + 1) begin
	assign SWAP1[i] = ROT7[i+8];
	assign SWAP1[i + 8] = ROT7[i]; 
end

for (i = 0; i < 16; i = i + 1)
	assign XOR1[i] = PLUS1[i] ^ SWAP1[i];


for (i = 0; i < 2; i = i + 1) begin
	assign SWAP2[i]    = PLUS1[i+2];
    assign SWAP2[i+2]  = PLUS1[i];
    assign SWAP2[i+4]  = PLUS1[i+6];
    assign SWAP2[i+6]  = PLUS1[i+4];
    assign SWAP2[i+8]  = PLUS1[i+10];
    assign SWAP2[i+10] = PLUS1[i+8];
    assign SWAP2[i+12] = PLUS1[i+14];
    assign SWAP2[i+14] = PLUS1[i+12];
end 

for (i = 0; i < 16; i = i + 1)
	assign PLUS2[i] = XOR1[i] + SWAP2[i];




for (i = 0; i < 16; i = i + 1)
	assign ROT11[i] = {XOR1[i][20:0],XOR1[i][31:21]};
 

for (i = 0; i < 4; i = i + 1) begin
    assign SWAP3[i]   = ROT11[i + 4];
    assign SWAP3[i + 4]  = ROT11[i];
    assign SWAP3[i + 8]  = ROT11[i + 12];
    assign SWAP3[i + 12] = ROT11[i + 8];
end

for (i = 0; i < 16; i = i + 1)
	assign XOR2[i] = SWAP3[i] ^ PLUS2[i];


for (i = 0; i < 8; i = i + 1) begin
    assign SWAP4[i*2]   = PLUS2[i*2+1];
    assign SWAP4[i*2+1] = PLUS2[i*2];
end

for (i = 0; i < 16; i= i+1) begin
    assign arr_Rout[i] = XOR2[i];
    assign arr_Rout[i+16] = SWAP4[i];
end

//------------------------------------------- here the magic of the round is ending, if you missed it you are probably not smart enough

 for (i = 0; i < 32; i = i + 1)
	assign Rout[1023-32*i: 992 - 32*i] = arr_Rout[i];


endmodule
























