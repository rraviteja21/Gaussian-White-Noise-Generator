`include "def.v"


/* Generates the input seeds . Parameterised inputs. So they can be changed  at the time of instantiation*/
module tausworth_urgn #( parameter p0 = 32'b11111111111111111111111111111111,
						 parameter p1 = 32'b11001100110011001100110011001101,
						 parameter p2 = 32'b00000000111111110000000011111111)
						( clk,
						resetn,
						urgn_seed,			// OUTPUT SEED
						valid
						);
input clk, resetn;
output  reg [31 : 0]urgn_seed;
output reg valid;					// validates the seed generated

reg [31 :0]s0, s1, s2;
reg [31 : 0]next_s0, next_s1, next_s2;
reg [31 : 0]b1 , b2, b3;

always @(*) begin
	b1 = ((( s0 << 13) ^ s0) >> 19);
	next_s0 = ((( s0 & 32'hFFFFFFFE ) << 12) ^ b1);
	b2 = ((( s1 << 2) ^ s1)  >> 25);
	next_s1 = ((( s1 & 32'hFFFFFFF8) << 4 ) ^ b2);
	b3 = (((s2 << 3) ^ s2) >> 11);
	next_s2 = ((( s2 & 32'hFFFFFFF0) << 17 ) ^ b3); 
	
	urgn_seed <= s0 ^ s1 ^ s2;
end

always @(posedge clk)
begin
	if (resetn == `FALSE) begin
		valid <= `FALSE;
		urgn_seed <= 32'b0;	
		s0 <= p0;		
		s1 <= p1; 		
		s2 <= p2;		
	end
	else begin
		s0 <= next_s0;
		s1 <= next_s1;
		s2 <= next_s2;
		valid <= `TRUE;
	end
end
endmodule
