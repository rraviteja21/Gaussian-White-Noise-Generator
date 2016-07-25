`timescale 1ns/100ps
`include "tausworth_urgn.v"
`include "def.v"


module testbench( );
reg clk, resetn;
wire  [31 : 0]a, b;
wire valid_a, valib_b;
wire [15:0]x0, x1;
integer fileID_a, fileID_b, fileID_x0, fileID_x1;
wire ovalid;
tausworth_urgn #( 	   .p0(32'b11111111111111111111111111111111),
					   .p1(32'b11001100110011001100110011001101),
					   .p2(32'b00000000111111110000000011111111) )
				urgn_a(.clk(clk),
					   .resetn(resetn),
					   .urgn_seed(a),
					   .valid(valid_a));

tausworth_urgn #( 	   .p0(32'b10011010000100110110100010001000),
					   .p1(32'b11001011011111110110010010100101),
					   .p2(32'b00011011010110001010000100111100) )
				urgn_b(.clk(clk),
					   .resetn(resetn),
					   .urgn_seed(b),
					   .valid(valid_b));
					 
myAWGN myAWGN_0( .clk(clk),
			     .resetn(resetn),
				 .a(a),
				 .b(b),
				 .x0(x0),
				 .x1(x1),
				 .ovalid(ovalid));


initial
begin
	fileID_a = $fopen("taus_a.txt", "w");
	fileID_b = $fopen("taus_b.txt", "w");
	fileID_x0 = $fopen("x0.txt", "w");
	fileID_x1 = $fopen("x1.txt", "w");
	clk =1;
	resetn = 0;
	#20 resetn =`TRUE;
end


initial
begin
	$dumpfile("taus.vcd");
	$dumpvars(1, a,b);
	$dumpoff;
	#20;
	$dumpon;
	#100000;
	$dumpoff;

end

always
begin
	
 #5 clk = !clk ;

end

always @(posedge clk && resetn == `TRUE)
begin
	 $fwrite(fileID_a, "%d\t \t %d\n",a[31:0], valid_a);
	 $fwrite(fileID_b, "%d\t \t %d\n",b[31:0], valid_b);
	 $fwrite(fileID_x0, "%d		\t %d\n",x0[15:0],ovalid);
	 $fwrite(fileID_x1, "%d     \t %d\n",x1[15:0],ovalid);
end

initial
begin
$display("\t time, \t %d\t %d", $time, a, b);
$monitor("%d \t %d", a, b);

end

initial
begin
	#100020 $finish;
end
endmodule