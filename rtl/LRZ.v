`include "def.v"

/* 2 bit LZD*/
module LRZ2( bitVector,
	    p,
	    v );

input [1 : 0]bitVector;
output reg p, v;

always @(*) 
begin
	v <= bitVector[0] | bitVector[1] ;
	p <= bitVector[0] & (!bitVector[1]);

end
endmodule

//******************* 4 bit LZD*********************/
module LRZ4( datain,
	     p,
	     valid);

input [3 : 0]datain;
output reg [1:0]p;
output reg valid;

wire pOut0, pOut1;
wire valid0, valid1;

LRZ2 LRZ0( .bitVector( datain[1:0] ),
		 .p( pOut0 ),
		 .v( valid0) );

LRZ2 LRZ1( .bitVector( datain[3:2]),
		 .p( pOut1 ),
		 .v( valid1));

always @(*)
begin
	valid <= valid0 | valid1;
	if ((valid0 | valid1)==`TRUE)
		p <= {!valid1,(valid1) ? pOut1: pOut0};
	else
		p<= 2'b0;
end

endmodule

//******************* 8 bit LZD*********************/


module LRZ8( datain,
	     p,
	     valid);

input [7:0]datain;
output reg [2 : 0]p;
output reg valid;

wire [3: 0]pOut;
wire valid0, valid1;

LRZ4 LRZ0( .datain( datain[3:0] ),
		 .p( pOut[1:0] ),
		 .valid( valid0) );

LRZ4 LRZ1( .datain( datain[7:4]),
		 .p( pOut[3:2] ),
		 .valid( valid1));
always @(*)
begin
	valid <= valid0 | valid1;
	if ((valid0 | valid1)==`TRUE)
		p <= {!valid1,(valid1) ? pOut[3:2]: pOut[1:0]};
	else
		p <= 3'b0;
end
endmodule

//******************* 16 bit LZD*********************/

module LRZ16( datain,
	      p,
	      valid);

input [15:0]datain;
output reg [3 : 0]p;
output reg valid;

wire [5: 0]pOut;
wire valid0, valid1;

LRZ8 LRZ0( .datain( datain[7:0] ),
		 .p( pOut[2:0] ),
		 .valid( valid0) );

LRZ8 LRZ1( .datain( datain[15:8]),
		 .p( pOut[5:3] ),
		 .valid( valid1));
always @(*)
begin
	valid <= valid0 | valid1;
	if ((valid0 | valid1)==`TRUE)
		p <= {!valid1,(valid1) ? pOut[5:3]: pOut[2:0]};
	else
		p <= 4'b0;
end
endmodule

//******************* 32 bit LZD*********************/

module LRZ32( datain,
	      p,
	      valid);

input [31 : 0]datain;
output reg [4 : 0]p;
output reg valid;

wire [7 : 0]pOut;
wire valid0, valid1;

LRZ16 LRZ0( .datain( datain[15:0] ),
		 .p( pOut[3:0] ),
		 .valid( valid0) );

LRZ16 LRZ1( .datain( datain[31:16]),
		 .p( pOut[7:4] ),
		 .valid( valid1));

always @(*)
begin
	valid <= valid0 | valid1 ;
	if ((valid0 | valid1 )==`TRUE)
		p <= {!valid1,(valid1) ? pOut[7:4]: pOut[3:0]};
	else
		p <= 5'b0;
end

endmodule

//************************************************** 48 bit LZD*****************************************************//

module LRZ48( datain,
	      p,
	      valid);

input [47 : 0]datain;
output reg valid;
output reg [5 : 0]p;

wire valid0, valid1;
wire [8:0]pOut;

LRZ32 LRZ0( .datain( datain[31:0] ),
		 .p( pOut[4:0] ),
		 .valid( valid0) );

LRZ16 LRZ1( .datain( datain[47:32]),
		 .p( pOut[8:5] ),
		 .valid( valid1));

always @(*)
begin
	valid <= valid0 | valid1 ;
	if ((valid0 | valid1 )==`TRUE) begin
		if(valid1 == `FALSE && valid0 == `TRUE) begin
			p <= 6'b010000 + pOut[4:0]; 
		end
		if(valid1 == `TRUE && valid0 == `FALSE) begin
			p <= pOut[8:5];
		end
		if(valid1 == `TRUE && valid0 == `TRUE) begin
			p <= pOut[8 : 5];
		end
	end
	else begin
		p <= 6'b0;
	end
end
endmodule



