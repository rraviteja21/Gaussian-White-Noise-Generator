`include "def.v"

module myAWGN( clk,					// clock input. 
	       resetn,					// reset bar. Active low input
	       a,						// input seed 0
	       b,						// input seed 1
	       x0,						// Output noise signal 0
	       x1,						// Output noise signal 1
		   ovalid);					// output valid signal.

input clk, resetn;
input [31 : 0]a, b;
output reg [15 : 0]x0, x1;
output reg ovalid;

/***************************************************** signal declaration*********************************************/
reg [31:0]next_a, next_b, curr_a, curr_b;
reg [47 : 0]next_u0, curr_u0;
reg [15 : 0]next_u1, curr_u1;
reg [48 : 0]curr_x_e, next_x_e;
wire [5 : 0]p48;
wire [2 : 0]p8;
reg [5 : 0]next_exp_e, curr_exp_e;
wire [31 : 0]eBar;
wire [31:0]y_e;
wire[19:0]y_f;
reg [30:0]next_e, curr_e; 		 // (7,24)
reg [30:0]next_x_f, curr_x_f;  //(7,24)
wire valid48, valid8;
reg [2:0]next_exp_f, curr_exp_f;
reg [16:0]curr_f, next_f;
reg [1:0]next_seg, curr_seg,next_seg_1;
reg [13:0]next_x_g_a, curr_x_g_a, next_x_g_b, curr_x_g_b;
reg [15:0]next_y_g_a, next_y_g_b, curr_y_g_a, curr_y_g_b;
wire [15:0] y_g_a, y_g_b;
reg [15:0]next_g1,next_g0, next_g1_1,next_g0_1, curr_g0, curr_g1;
wire [15 : 0]x0_p, x1_p, neg_y_g_a, neg_y_g_b;

/**************************************************Required Logic blocks******************************************************/

LRZ48 LRZ48_0(		 .datain(curr_u0),
					 .p(p48),
					 .valid(valid48) );

myMultiplier ln2Mul(.A(32'b10110001011100100001011111111000),
		             .B({26'b0,curr_exp_e}),
		             .result(eBar) );

ln_mul ln_mul0( .x_e(curr_x_e),
	            .y_e(y_e) );
				
sqrt srt_0 (    .x_f(curr_x_f),
	            .polysel(curr_exp_f[0]),
	            .y_f(y_f) );
				
cos_mul cos_mul_0( .x_g_a(curr_x_g_a),
		  .x_g_b(curr_x_g_b),
		  .y_g_a(y_g_a),
		  .y_g_b(y_g_b));
		  
myMultiplier_x x0_product( .f(curr_f),
						   .g(curr_g0),
						   .x(x0_p));	
						   
myMultiplier_x x1_product( .f(curr_f),
						   .g(curr_g1),
						   .x(x1_p));		

myMul_cnvrt_to_neg cnvrt_y_g_a(.y_g(curr_y_g_a),
							.g(neg_y_g_a));	
							
myMul_cnvrt_to_neg cnvrt_y_g_b(.y_g(curr_y_g_b),
							.g(neg_y_g_b));	

LRZ8 LRZ8_0(  .datain({1'b0,curr_e[30:24]}),
			  .p(p8),
			  .valid(valid8));
/*
Active low Synchronous reset(resetbar == 0) initializes all the intermediate signals and set the output signals to zero.  
*/
always @(posedge clk)
begin
	if( resetn == `FALSE) begin
		x0 <= 16'b0;
		x1 <= 16'b0;
		curr_a <= 32'b0;
		curr_b <= 32'b0;
		next_a <= 32'b0;
		next_b <= 32'b0;
		curr_u0 <= 48'b0;
		next_u0 <= 48'b0;
		curr_u1 <= 16'b0;
		next_u1 <= 16'b0;
		curr_exp_e <= 6'b0;
		next_exp_e <= 6'b0;
		curr_x_e <= 49'b0;
		next_x_e <= 49'b0;
		curr_e <= 31'b0;
		next_e <= 31'b0;
		curr_exp_f <= 3'b0;
		next_exp_f <= 3'b0;
		curr_x_f <= 31'b0;
		next_x_f <= 31'b0;
		curr_f <= 17'b0;
		next_f <= 17'b0;
		curr_x_g_a <=14'b0;
		next_x_g_a <=14'b0;
		curr_x_g_b <=14'b0;
		next_x_g_b <=14'b0;
		curr_y_g_a <= 16'b0;
		next_y_g_a <= 16'b0;
		curr_y_g_b <= 16'b0;
		next_y_g_b <= 16'b0;
		next_seg <= 2'b0;
		next_seg_1 <= 2'b0;
		curr_seg <= 2'b0;
		next_g0 <= 16'b0;
		next_g0_1 <= 16'b0;
		next_g1 <= 16'b0;
		next_g1_1 <= 16'b0;
		curr_g0 <= 16'b0;
		curr_g1 <= 16'b0;
		ovalid <= `FALSE;
	end
	/* The "next_" signals are calculated based on the current inputs. In the next clock cycle, the "next" inputs 
	are assigned to their corresponding "curr" inputs. */
	else begin
		curr_a  <= next_a;
		curr_b  <= next_b;
		curr_u0 <= next_u0;
		curr_u1 <= next_u1;
		curr_exp_e <= next_exp_e;
		curr_x_e <= next_x_e;
		curr_e <= next_e;
		curr_exp_f <= next_exp_f;
		curr_x_f <= next_x_f;
		curr_f <= next_f; 
		curr_x_g_a <= next_x_g_a;
		curr_x_g_b <= next_x_g_b;
		curr_y_g_a <= next_y_g_a;
		curr_y_g_b <= next_y_g_b;
		next_seg <= next_seg_1;
		curr_seg <= next_seg;
		next_g0 <= next_g0_1;				// Since the cos/sine functions are evaluated one clock cycle before the square rot and logarithm, 
		next_g1 <= next_g1_1;			    // a delay for one clock cycle is introduced.
		curr_g0 <= next_g0;
		curr_g1 <= next_g1;
		ovalid <= `TRUE;
	end
end

/* This always block is triggered when a or b or positive edge of clock occurs. The inputs are latched into "next" registers.     */
always @(posedge clk)
begin
	next_a <= a;
	next_b <= b;
end

/*Whenevr the "curr" a or b changes, the "next" u0 and u1 are calculated.*/
always @(posedge clk )
begin
	next_u0 <= {curr_a, curr_b[31: 16]};
	next_u1 <= curr_b[15 : 0];

end
/*The u0 value is the input to the logarithm and square root functions. So evry clock cycle, the "next" x_e and exp_e signals are evaluated.*/
always @( posedge clk )
begin
	if(valid48==`TRUE) begin
		next_x_e <= curr_u0 << ( p48 + 1);
		next_exp_e <= p48 + 1;
	end
end

/* Based on the "curr" exp_e the sigals eBar and y_e are calculated by the multipliers and the results are subtracted to generate "next eBar"
eBar is an unsigned number, while y_e is a signed 2's complemented number. So y_e is just added to eBar.*/
always @(posedge clk)
begin
	next_e <= ({1'b0,eBar[31:2]} + {{1{y_e[31]}},y_e[31:3]}) <<1;
end
/*Based on the "curr" exp_f, the LZD for the for the "curr e " is calculated from the LRZ48 instatiation above. And "next" x_f is calculated 
based on the LRZ output*/
always @(posedge clk)
begin
	if(valid8==`TRUE) begin
		next_exp_f <= 3'b101  - (p8 - 1'b1);
		next_x_f <= (p8[0] == 1'b0) ? (curr_e >> (3'b101  - (p8 - 1'b1)))>> 1:(curr_e >> (3'b101  - (p8 - 1'b1)));
	end
end
/* "next f" i calcualted based on "curr exp_f". y_f is the output of the sqrt instatiation above based on the "curr x_f"*/
always @(posedge clk )
begin
	if(curr_exp_f[0] == `TRUE)
		next_f <= y_f << ((curr_exp_f +1)>>1);
	else 
		next_f <= y_f << (curr_exp_f >> 1);
end
/* This always block calculates the input for cos and sine functions*/
always @( posedge clk)
begin
 	next_x_g_a  <= curr_u1[13: 0];
	next_x_g_b <= 14'b1 - curr_u1[13: 0];
	next_seg_1 <= curr_u1[15:14];
end
/*calculates the output from cos_mul instatiation above based on curr x_g */
always @( posedge clk)
begin
	next_y_g_a <= y_g_a;
	next_y_g_b <= y_g_b;
end
/*based on which quadrant they belog to, corresponding 2's complement numbers are generated*/
always @(posedge clk)
begin
	case(curr_seg)
		2'b00:
		begin
			next_g0_1 <= curr_y_g_b;
			next_g1_1 <= curr_y_g_a;
		end
		2'b01:
		begin
			next_g0_1 <= curr_y_g_a;
			next_g1_1 <= neg_y_g_b;
		end
		2'b10:
		begin
			next_g0_1 <= neg_y_g_b;
			next_g1_1 <= neg_y_g_a;
		end
		2'b11:
		begin
			next_g0_1 <= neg_y_g_a;
			next_g1_1 <= curr_y_g_b;
		end
		endcase
end
/* multiplies the out put of cos/sine and log/sqrt functions and produces noise signals*/
always @(posedge clk )
begin
	x0 <= x0_p;
	x1 <= x1_p;
end

endmodule
