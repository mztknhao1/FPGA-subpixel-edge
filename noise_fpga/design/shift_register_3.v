`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    17:36:22 06/10/11
// Design Name:    
// Module Name:    shift_register_3
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
module shift_register_3(clk, din, rst, dout0, dout1, dout2);//, dout3, dout4);
    input [7:0] din;
    input rst;
	 input clk;
	 output [7:0] dout0;
    output [7:0] dout1;
    output [7:0] dout2;
//    output [7:0] dout3;
//	 output [7:0] dout4;

	 wire[7:0] dout0;
	 reg[7:0] dout1;
	 reg[7:0] dout2;
//	 reg[7:0] dout3;
//	 reg[7:0] dout4;

	 always@(posedge clk or negedge rst)
	 begin
	 	if(!rst)
		begin
			dout1<=8'bzzzzzzzz;
			dout2<=8'bzzzzzzzz;
//			dout3<=8'bzzzzzzzz;
//			dout4<=8'bzzzzzzzz;
		end
		else
		begin
			dout1<=din;
			dout2<=dout1;
//			dout3<=dout2;
//			dout4<=dout3;
		end
	 end

	 assign dout0=din;

endmodule
