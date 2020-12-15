/*---------------------高斯滤波模块-----------------------------------------------------
输入：时钟，复位信号，3x3窗口
输出：滤波后的数值
|p11,p12,p13| |1,2,1| 
|p21,p22,p23|*|2,4,2|
|p31,p32,p33| |1,2,1|

//需要四个时钟周期计算
/---------------------------------------------------------------------------------------*/
module	gaussian_filter(
		input	clk,
		input	rst,
		input	[7:0]	din1_1,din1_2,din1_3,din2_1,din2_2,din2_3,din3_1,din3_2,din3_3,
		
		output	[7:0]	dout
);

reg	[11:0]	weight21,weight22,weight2,weight11,weight12,weight1,weight4,weight41,tmp1,tmp2,tmp;

always@(posedge	clk or negedge	rst)
	if(~rst)
		begin
		 weight21	<=	12'd0;
		 weight22	<=	12'd0;
		 weight2	<=	12'd0;
		 weight11	<=	12'd0;
		 weight12	<=	12'd0;
		 weight1	<=	12'd0;
		 weight4	<=	12'd0;
		 weight41	<=	12'd0;
		 tmp		<=	12'd0;
		 tmp1		<=	12'd0;
		 tmp2		<=	12'd0;
		end
	else
		begin
		 //一级流水线
		 weight21 <= din1_2 + din3_2;
		 weight22 <= din2_1 + din2_3;
		 
		 weight11 <= din1_1 + din1_3;
		 weight12 <= din3_1 + din3_3;
		 
		 weight4 <= din2_2 << 2;
		 
		 //二级流水线
		 weight2 <= weight21 + weight22;
		 weight1 <= weight11 + weight12;
		 weight41 <= weight4;
		 
		 //三级流水线
		 tmp2	<=	weight2 << 1;
		 tmp1	<=  weight1 + weight41;
		 
		 //四级流水线
		 tmp    <=	tmp1 + tmp2;
		 
		end

assign	dout = tmp>>4;

endmodule