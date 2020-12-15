//从输入p11到p55，到输出相应的state需要6个时钟周期

module julge_state(clk, rst, threshold, din1, din2, din3, din4, din5, din6, din7, din8, din9, 
                dout_state); 
	input clk;
    input rst;
	input [10:0] threshold;
    input [7:0]  din1;
    input [7:0]  din2;
    input [7:0]  din3;
    input [7:0]  din4;
    input [7:0]  din5;
    input [7:0]  din6;
    input [7:0]  din7;
    input [7:0]  din8;
    input [7:0]  din9;

	output [3:0] dout_state; 

	reg [10:0] delta;
	reg [3:0]  dout_state;

	reg [10:0]  tmpx1;
	reg [10:0]  tmpx2;
	reg [10:0]  tmpx3;
	reg [10:0]  tmpx4;
	reg [10:0]  tmpx5;
	reg [10:0]  tmpx6;
	reg [10:0]  tmpy1;
	reg [10:0]  tmpy2;
	reg [10:0]  tmpy3;
	reg [10:0]  tmpy4;
	reg [10:0]  tmpy5;
	reg [10:0]  tmpy6;
	
	reg [10:0]	tmpx6r1,tmpx6r2;
	reg	[10:0]	tmpy6r1,tmpy6r2;
	reg	[10:0]	absx_r,absy_r;

	reg [10:0] absx;
	reg [10:0] absy;

	always@(posedge clk or negedge rst)
		begin
			if(!rst)
				begin
					delta<=0;
					dout_state<=5'b00000;
					tmpx1<=0;
					tmpx2<=0;
					tmpx3<=0;
					tmpx4<=0;
					tmpx5<=0;
					tmpx6<=0;
					tmpy1<=0;
					tmpy2<=0;
					tmpy3<=0;
					tmpy4<=0;
					tmpy5<=0;
					tmpy6<=0;
					absx<=0;
					absy<=0;
					
					tmpx6r1 <= 0;
					tmpy6r1 <= 0;
					
					tmpx6r2 <= 0;
					tmpy6r2 <= 0;
					
					absx_r <= 0;
					absy_r <= 0;
					
				end
	
			else
				begin
				//
				//|-1，-2，-1 |
				//|	0， 0，	0 |
				//|	1， 2， 1 |
				tmpx1<=din7+din9;
				tmpx2<=din1+din3;
				tmpx3<=din8-din2;
				tmpx4<=tmpx3<<1;
				tmpx5<=tmpx1-tmpx2;
				tmpx6<=tmpx4+tmpx5;
				tmpx6r1 <= tmpx6;
				tmpx6r2 <= tmpx6r1;
	
				tmpy1<=din1+din7;
				tmpy2<=din3+din9;
				tmpy3<=din6-din4;
				tmpy4<=tmpy3<<1;
				tmpy5<=tmpy2-tmpy1;
				tmpy6<=tmpy4+tmpy5;
				tmpy6r1 <= tmpy6;
				tmpy6r2 <= tmpy6r1;
	
				if(tmpx6[10]==1)
					absx<={1'b0,~tmpx6[9:0]}+1;
				else
					absx<=tmpx6;
				
				if(tmpy6[10]==1)
					absy<={1'b0,~tmpy6[9:0]}+1;
				else
					absy<=tmpy6;
	
				absx_r <= absx;
				absy_r <= absy;
				delta<=absx+absy;
	
				if(delta>=threshold)
					begin
						if(absy_r<=absx_r)
							begin
								//异或，为1时，一正一负
								if((tmpx6r2[10]^tmpy6r2[10])||(tmpx6r2==11'b0)||(tmpy6r2 == 11'b0))
									dout_state<=4'b0001;		//Fy<Fx,且一正一负，（135，180）
								else
									dout_state<=4'b0010;		//Fy<Fx,且两个同号，（0，45）
							end
						else
							begin
								if((tmpx6r2[10]^tmpy6r2[10])||(tmpx6r2==11'b0)||(tmpy6r2 == 11'b0))
									dout_state<=4'b0100;		//Fy>Fx,且一正一负，（90，135）
								else
									dout_state<=4'b1000;		//Fy>Fx,且两同号，（45，90）
							end
					end
				else
					dout_state<=4'b0000;
				
			end
		end

endmodule
