`include "def.v"

/*-----------------------------------------------------------------------------------------------------------------
	The below module multipies the constant ln2 (0, 32) and exp_e(6,0).So the product of these terms will produce
	an unsigned value ebar with (6,32) range. The range is rounded off to (6,25).  
	(e = (ebar - y_e) << 1). Since y_e is signed, we convert ebar to a 
    signed value by padding 0 to its MSB thus making ebar (7,25).
-----------------------------------------------------------------------------------------------------------------*/
module myMultiplier #(				// checked and working
	//Parameterized values
	parameter Q = 24,
	parameter N = 32
	)	   ( A,
		     B,
		     result				
		     );
input [31: 0]A, B;
output reg [31:0]result;


reg [37 : 0]uT_result;				// uT --> unTruncated; T --> Truncated
reg [37:0]T_result;

always @(A or B)
begin
	uT_result <= A[N-1: 0] * B[N-1 : 0];
end

always @(uT_result)
begin
	
	T_result <= uT_result + (( uT_result &  1 << (6-1)) << 1) ; 
end

always @(T_result)begin
	result <= {1'b0,T_result[37:6]};
end
endmodule


//-------------------------------------------------------------------------------------------//

module myMultiplier_ln2(	x,
							C2,
							C1,
							C0,
							result);
input [48: 0]x;							//	(0, 48)[0, 1] >> 8-> (1,48) [1, 2] 
input [12 : 0]C2;
input [21: 0]C1;
input [29:0]C0;
output reg [31 :0]result;
reg [98 - 1 : 0]uT_x2;    // (1, 48) * (1, 48) -> (2, 96)
reg [71 : 0]uT_C1_x;				// (0, 22) * (1, 48) -> (1,70)+1
reg [95:0]uT_x2_C2_product;  // (1,12) * (2, 80) ->(3, 92) +1
reg [72:0]uT_C0_C1_sum;  				// (2,70) +(2,28) -> (2,70) + 1
reg [96: 0]uT_result, T_result;

always @(x or C1)
begin
	uT_x2 <= x * x;   // unsigned
	uT_C1_x <= {{50{C1[21]}},C1} * {23'b0, x};	
	
end

always @(uT_x2)
begin
	uT_x2_C2_product <= {{83{C2[12]}},C2} * { 14'b0,uT_x2[97: 16]};   // x has 8 zeros (>> 8). so producthas 16 bits zeros
	 
end

always @(uT_C1_x)
begin
	uT_C0_C1_sum <= {{1{uT_C1_x[71]}},uT_C1_x} + { {1{C0[29]}},C0,42'b0};
end

always @(uT_x2_C2_product or uT_C0_C1_sum)
begin
	uT_result	<= {{2{uT_x2_C2_product[94]}},uT_x2_C2_product[94:0]} + {{2{uT_C0_C1_sum[72]}},uT_C0_C1_sum, 22'b0};
end

always @(uT_result)
begin
	T_result <= uT_result + (( uT_result & 1 <<( 65 - 1)) <<1);
end

always @(T_result)
begin
	result <= T_result[96:65];
end

endmodule


///////////////////////////////////////////////////////////////////////////////////////
																					// checked and working
module myMultiplier_sqrt9( x_f_b,
						   C1,
						   C0,
						   y_f );
input [30:0]x_f_b;				///(7,24)
input [11:0]C1;					//(0,12)
input [19:0]C0;
output reg [19:0]y_f;			//(7, 13)
reg [42 : 0]T_y_f;
reg [42:0]uT_C1_x_f_b;  			// unsigned * unsigned . (0,12) * (7,24) --> (7,36)
reg [42 : 0]uT_y_f;
wire [42:0] shifted_C0;


always @(x_f_b or C1 or C0)
begin
	uT_C1_x_f_b <= x_f_b * C1;
end


assign shifted_C0 = {6'b0, C0} << 17;

always @(uT_C1_x_f_b)
begin
	uT_y_f <= uT_C1_x_f_b + shifted_C0 ;			  //(7,36)
end

always @(uT_y_f)
begin
	T_y_f <= uT_y_f + ((uT_y_f & 1 << ( 23 - 1)) << 1);  
end

always @(T_y_f)
begin
	y_f <= T_y_f[42: 23];
end

endmodule

///////////////////////////////////////////////////////////////////////////////////////
																					// checked and working
module myMultiplier_cos(x_g,
						C1,
						C0,
						y_g);
input [13:0]x_g; 		
input [11:0]C1;					
input [18:0]C0;
output reg [15:0]y_g;				// (1,15) output

reg [26:0]uT_C1_x_g; 				// (1, 11) * (0, 14) --> (2, 25)
reg [27: 0]uT_y_g, T_y_g;			// (2, 25) + (1,18)  --> (3,25)

always @(x_g or C1)
begin
	uT_C1_x_g <= {13'b0,x_g} * {{15{C1[11]}} ,C1};  			// unsigned * signed multiplication. Sign extension used concatenation operator
end

always @(uT_C1_x_g)
begin
		 uT_y_g <=  {uT_C1_x_g[26], uT_C1_x_g} + {2'b0, C0,7'b0};
end

always @(uT_y_g)
begin
	T_y_g <= uT_y_g + ((uT_y_g & 1 << ( 10 -1)) << 1);
end

always @(T_y_g)
begin
	y_g <= T_y_g[25:10];
end
endmodule

/////////////////////////////////////////////////

																											// checked and working
module myMultiplier_x( f,
					   g,
					   x);
input [16:0]f;
input [15:0]g;
output reg [15:0]x;

reg [33:0]uT_f_g;
reg [33:0]T_f_g;

always @(f or g)
begin
	uT_f_g <= {17'b0,f} * {{18{g[15]}},g};
end

always @(uT_f_g)
begin
	T_f_g <= uT_f_g + ((uT_f_g & 1 << (17 - 1)) << 1);
end

always @ (T_f_g)
begin
	x <= T_f_g[32:17];
end

endmodule

/*----------------------------------------------------------------------------------*/

module myMul_cnvrt_to_neg( y_g,
							g);
input [15 : 0]y_g;
output reg [15 : 0]g;

reg [32:0]uT_neg_y_g;

always @(y_g)
begin
	uT_neg_y_g <= {17'b0,y_g} * {17'b1111111111111111, 16'b1111111111111111};
end

always @(uT_neg_y_g)
begin
	g <= uT_neg_y_g[15:0];
end

endmodule

