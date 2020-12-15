module	top_noise(
		input	clk,
		input	rst,
		
		input	[7:0]	din,
		
		output			window_7x7_start,
		output  [7:0]	gin,
		
		output	[31:0]	result_a,
		output			adivbyzero,
		output	[31:0]	result_b,
		output			bdivbyzero,
		
		output			ab_start,
		output	[3:0]	state,
		output			frame_complete	
);
	
	reg		[17:0]	global_cnt;			//全局计数器，当第一个din输入时有开始计数
	
	//----------------------------产生整幅图的地址，用于之后的控制----------------------
	always@(posedge clk or negedge rst)
		if(~rst)
			global_cnt <= 0;
		else
			global_cnt <= global_cnt + 1'b1;
			
	assign	frame_complete = (global_cnt > 163840) ? 1:0;			//一帧图像结束
	
	
	//-----------------------------首先产生3x3窗口--------------------------------------
	wire	[7:0]	p11,p12,p13,
					p21,p22,p23,
					p31,p32,p33;				
	data_window_3x3	data_window_3x3_inst(
		.clk			(clk),
		.rst			(rst),
		.din			(din),
		.dout1_1		(p11),
		.dout1_2		(p12),
		.dout1_3		(p13),
		.dout2_1		(p21),
		.dout2_2		(p22),
		.dout2_3		(p23),
		.dout3_1		(p31),
		.dout3_2		(p32),
		.dout3_3		(p33)
	);
	
	//----------------------------然后高斯滤波--------------------------------------------
	wire			gaussian_start;
	wire	[7:0]	gout;
	
	//控制信号：高斯开始滤波，即输入的全局地址大于1026
	assign			gaussian_start = (global_cnt > 1026) ? 1:0;
	gaussian_filter	gaussian_filter_inst(
	
		.clk(clk),
		.rst(gaussian_start),
		.din1_1(p11),.din1_2(p12),.din1_3(p13),
		.din2_1(p21),.din2_2(p22),.din2_3(p23),
		.din3_1(p31),.din3_2(p32),.din3_3(p33),
		.dout(gout)
	);
	
	//---------------------接下来将高斯模板输出的值送入7x7窗口产生模块--------------------
	//高斯模板启动以后，需要4个周期产生第一个数据，这时输入7x7窗口产生模块
	reg		window_7x7_start_r;
	//wire	window_7x7_start;
	reg 	[1:0]	cnt_window_7x7;
	//wire	[7:0]	gin;									//输入给7x7窗口的数据，第一个补0
	wire	[7:0]	g11,g12,g13,g14,g15,g16,g17,
					g21,g22,g23,g24,g25,g26,g27,
					g31,g32,g33,g34,g35,g36,g37,
					g41,g42,g43,g44,g45,g46,g47,
					g51,g52,g53,g54,g55,g56,g57,
					g61,g62,g63,g64,g65,g66,g67,
					g71,g72,g73,g74,g75,g76,g77;
					
	
	always@(posedge clk or negedge	rst)
		if(~rst)
			begin
			 window_7x7_start_r <= 1'b0;
			 cnt_window_7x7   <= 1'b0;
			end
		else if(gaussian_start)
			begin
			 if(cnt_window_7x7 < 2'd2)
				cnt_window_7x7 <=	cnt_window_7x7 + 1'b1;
			 else
				window_7x7_start_r <= 1'b1;
			end
		else
			window_7x7_start_r <= 1'b0;
	
	assign	gin = window_7x7_start_r?gout:8'h0;
	assign	window_7x7_start = window_7x7_start_r;
	
	data_window_7x7	data_window_7x7_inst(
		.clk		(clk),
		.rst		(window_7x7_start),
		.din		(gin),
		// data_window
		.dout1_1(g11),.dout1_2(g12),.dout1_3(g13),.dout1_4(g14),.dout1_5(g15),.dout1_6(g16),.dout1_7(g17),
		.dout2_1(g21),.dout2_2(g22),.dout2_3(g23),.dout2_4(g24),.dout2_5(g25),.dout2_6(g26),.dout2_7(g27),
		.dout3_1(g31),.dout3_2(g32),.dout3_3(g33),.dout3_4(g34),.dout3_5(g35),.dout3_6(g36),.dout3_7(g37),
		.dout4_1(g41),.dout4_2(g42),.dout4_3(g43),.dout4_4(g44),.dout4_5(g45),.dout4_6(g46),.dout4_7(g47),
		.dout5_1(g51),.dout5_2(g52),.dout5_3(g53),.dout5_4(g54),.dout5_5(g55),.dout5_6(g56),.dout5_7(g57),
		.dout6_1(g61),.dout6_2(g62),.dout6_3(g63),.dout6_4(g64),.dout6_5(g65),.dout6_6(g66),.dout6_7(g67),
		.dout7_1(g71),.dout7_2(g72),.dout7_3(g73),.dout7_4(g74),.dout7_5(g75),.dout7_6(g76),.dout7_7(g77),
		
		.data_valid(julge_start)
	);
	
	//---------------------------------------判断斜率范围------------------------------------------------
	parameter		THRESHOLD = 11'd400;
	wire		[3:0]	state_w;
	julge_state	julge_state_inst(
	.clk		(clk), 
	.rst		(julge_start), 
	.threshold	(THRESHOLD), 
	.din1(g33), .din2(g34), .din3(g35), 
	.din4(g43), .din5(g44), .din6(g45),
	.din7(g53), .din8(g54), .din9(g55),
    .dout_state(state_w)
	);
	
	//-------------------------------------延时6个周期来输入state_w和p11~p77到下一个计算模块--------------
	reg	[7:0]		g11_r1,g12_r1,g13_r1,g14_r1,g15_r1,g16_r1,g17_r1,
					g21_r1,g22_r1,g23_r1,g24_r1,g25_r1,g26_r1,g27_r1,
					g31_r1,g32_r1,g33_r1,g34_r1,g35_r1,g36_r1,g37_r1,
					g41_r1,g42_r1,g43_r1,g44_r1,g45_r1,g46_r1,g47_r1,
					g51_r1,g52_r1,g53_r1,g54_r1,g55_r1,g56_r1,g57_r1,
					g61_r1,g62_r1,g63_r1,g64_r1,g65_r1,g66_r1,g67_r1,
					g71_r1,g72_r1,g73_r1,g74_r1,g75_r1,g76_r1,g77_r1;
					
	reg	[7:0]		g11_r2,g12_r2,g13_r2,g14_r2,g15_r2,g16_r2,g17_r2,
					g21_r2,g22_r2,g23_r2,g24_r2,g25_r2,g26_r2,g27_r2,
					g31_r2,g32_r2,g33_r2,g34_r2,g35_r2,g36_r2,g37_r2,
					g41_r2,g42_r2,g43_r2,g44_r2,g45_r2,g46_r2,g47_r2,
					g51_r2,g52_r2,g53_r2,g54_r2,g55_r2,g56_r2,g57_r2,
					g61_r2,g62_r2,g63_r2,g64_r2,g65_r2,g66_r2,g67_r2,
					g71_r2,g72_r2,g73_r2,g74_r2,g75_r2,g76_r2,g77_r2;
					
	reg	[7:0]		g11_r3,g12_r3,g13_r3,g14_r3,g15_r3,g16_r3,g17_r3,
					g21_r3,g22_r3,g23_r3,g24_r3,g25_r3,g26_r3,g27_r3,
					g31_r3,g32_r3,g33_r3,g34_r3,g35_r3,g36_r3,g37_r3,
					g41_r3,g42_r3,g43_r3,g44_r3,g45_r3,g46_r3,g47_r3,
					g51_r3,g52_r3,g53_r3,g54_r3,g55_r3,g56_r3,g57_r3,
					g61_r3,g62_r3,g63_r3,g64_r3,g65_r3,g66_r3,g67_r3,
					g71_r3,g72_r3,g73_r3,g74_r3,g75_r3,g76_r3,g77_r3;
					
	reg	[7:0]		g11_r4,g12_r4,g13_r4,g14_r4,g15_r4,g16_r4,g17_r4,
					g21_r4,g22_r4,g23_r4,g24_r4,g25_r4,g26_r4,g27_r4,
					g31_r4,g32_r4,g33_r4,g34_r4,g35_r4,g36_r4,g37_r4,
					g41_r4,g42_r4,g43_r4,g44_r4,g45_r4,g46_r4,g47_r4,
					g51_r4,g52_r4,g53_r4,g54_r4,g55_r4,g56_r4,g57_r4,
					g61_r4,g62_r4,g63_r4,g64_r4,g65_r4,g66_r4,g67_r4,
					g71_r4,g72_r4,g73_r4,g74_r4,g75_r4,g76_r4,g77_r4;
					
	reg	[7:0]		g11_r5,g12_r5,g13_r5,g14_r5,g15_r5,g16_r5,g17_r5,
					g21_r5,g22_r5,g23_r5,g24_r5,g25_r5,g26_r5,g27_r5,
					g31_r5,g32_r5,g33_r5,g34_r5,g35_r5,g36_r5,g37_r5,
					g41_r5,g42_r5,g43_r5,g44_r5,g45_r5,g46_r5,g47_r5,
					g51_r5,g52_r5,g53_r5,g54_r5,g55_r5,g56_r5,g57_r5,
					g61_r5,g62_r5,g63_r5,g64_r5,g65_r5,g66_r5,g67_r5,
					g71_r5,g72_r5,g73_r5,g74_r5,g75_r5,g76_r5,g77_r5;
					
	reg	[7:0]		g11_r6,g12_r6,g13_r6,g14_r6,g15_r6,g16_r6,g17_r6,
					g21_r6,g22_r6,g23_r6,g24_r6,g25_r6,g26_r6,g27_r6,
					g31_r6,g32_r6,g33_r6,g34_r6,g35_r6,g36_r6,g37_r6,
					g41_r6,g42_r6,g43_r6,g44_r6,g45_r6,g46_r6,g47_r6,
					g51_r6,g52_r6,g53_r6,g54_r6,g55_r6,g56_r6,g57_r6,
					g61_r6,g62_r6,g63_r6,g64_r6,g65_r6,g66_r6,g67_r6,
					g71_r6,g72_r6,g73_r6,g74_r6,g75_r6,g76_r6,g77_r6;
	always@(posedge clk or negedge rst)
		begin
			if(~rst)
				begin
				 g11_r1<=8'b0;g12_r1<=8'b0;g13_r1<=8'b0;g14_r1<=8'b0;g15_r1<=8'b0;g16_r1<=8'b0;g17_r1<=8'b0;
				 g21_r1<=8'b0;g22_r1<=8'b0;g23_r1<=8'b0;g24_r1<=8'b0;g25_r1<=8'b0;g26_r1<=8'b0;g27_r1<=8'b0;
				 g31_r1<=8'b0;g32_r1<=8'b0;g33_r1<=8'b0;g34_r1<=8'b0;g35_r1<=8'b0;g36_r1<=8'b0;g37_r1<=8'b0;
				 g41_r1<=8'b0;g42_r1<=8'b0;g43_r1<=8'b0;g44_r1<=8'b0;g45_r1<=8'b0;g46_r1<=8'b0;g47_r1<=8'b0;
				 g51_r1<=8'b0;g52_r1<=8'b0;g53_r1<=8'b0;g54_r1<=8'b0;g55_r1<=8'b0;g56_r1<=8'b0;g57_r1<=8'b0;
				 g61_r1<=8'b0;g62_r1<=8'b0;g63_r1<=8'b0;g64_r1<=8'b0;g65_r1<=8'b0;g66_r1<=8'b0;g67_r1<=8'b0;
				 g71_r1<=8'b0;g72_r1<=8'b0;g73_r1<=8'b0;g74_r1<=8'b0;g75_r1<=8'b0;g76_r1<=8'b0;g77_r1<=8'b0;

				 g11_r2<=8'b0;g12_r2<=8'b0;g13_r2<=8'b0;g14_r2<=8'b0;g15_r2<=8'b0;g16_r2<=8'b0;g17_r2<=8'b0;
				 g21_r2<=8'b0;g22_r2<=8'b0;g23_r2<=8'b0;g24_r2<=8'b0;g25_r2<=8'b0;g26_r2<=8'b0;g27_r2<=8'b0;
				 g31_r2<=8'b0;g32_r2<=8'b0;g33_r2<=8'b0;g34_r2<=8'b0;g35_r2<=8'b0;g36_r2<=8'b0;g37_r2<=8'b0;
				 g41_r2<=8'b0;g42_r2<=8'b0;g43_r2<=8'b0;g44_r2<=8'b0;g45_r2<=8'b0;g46_r2<=8'b0;g47_r2<=8'b0;
				 g51_r2<=8'b0;g52_r2<=8'b0;g53_r2<=8'b0;g54_r2<=8'b0;g55_r2<=8'b0;g56_r2<=8'b0;g57_r2<=8'b0;
				 g61_r2<=8'b0;g62_r2<=8'b0;g63_r2<=8'b0;g64_r2<=8'b0;g65_r2<=8'b0;g66_r2<=8'b0;g67_r2<=8'b0;
				 g71_r2<=8'b0;g72_r2<=8'b0;g73_r2<=8'b0;g74_r2<=8'b0;g75_r2<=8'b0;g76_r2<=8'b0;g77_r2<=8'b0;
	
				 g11_r3<=8'b0;g12_r3<=8'b0;g13_r3<=8'b0;g14_r3<=8'b0;g15_r3<=8'b0;g16_r3<=8'b0;g17_r3<=8'b0;
				 g21_r3<=8'b0;g22_r3<=8'b0;g23_r3<=8'b0;g24_r3<=8'b0;g25_r3<=8'b0;g26_r3<=8'b0;g27_r3<=8'b0;
				 g31_r3<=8'b0;g32_r3<=8'b0;g33_r3<=8'b0;g34_r3<=8'b0;g35_r3<=8'b0;g36_r3<=8'b0;g37_r3<=8'b0;
				 g41_r3<=8'b0;g42_r3<=8'b0;g43_r3<=8'b0;g44_r3<=8'b0;g45_r3<=8'b0;g46_r3<=8'b0;g47_r3<=8'b0;
				 g51_r3<=8'b0;g52_r3<=8'b0;g53_r3<=8'b0;g54_r3<=8'b0;g55_r3<=8'b0;g56_r3<=8'b0;g57_r3<=8'b0;
				 g61_r3<=8'b0;g62_r3<=8'b0;g63_r3<=8'b0;g64_r3<=8'b0;g65_r3<=8'b0;g66_r3<=8'b0;g67_r3<=8'b0;
				 g71_r3<=8'b0;g72_r3<=8'b0;g73_r3<=8'b0;g74_r3<=8'b0;g75_r3<=8'b0;g76_r3<=8'b0;g77_r3<=8'b0;
		
				 g11_r4<=8'b0;g12_r4<=8'b0;g13_r4<=8'b0;g14_r4<=8'b0;g15_r4<=8'b0;g16_r4<=8'b0;g17_r4<=8'b0;
				 g21_r4<=8'b0;g22_r4<=8'b0;g23_r4<=8'b0;g24_r4<=8'b0;g25_r4<=8'b0;g26_r4<=8'b0;g27_r4<=8'b0;
				 g31_r4<=8'b0;g32_r4<=8'b0;g33_r4<=8'b0;g34_r4<=8'b0;g35_r4<=8'b0;g36_r4<=8'b0;g37_r4<=8'b0;
				 g41_r4<=8'b0;g42_r4<=8'b0;g43_r4<=8'b0;g44_r4<=8'b0;g45_r4<=8'b0;g46_r4<=8'b0;g47_r4<=8'b0;
				 g51_r4<=8'b0;g52_r4<=8'b0;g53_r4<=8'b0;g54_r4<=8'b0;g55_r4<=8'b0;g56_r4<=8'b0;g57_r4<=8'b0;
				 g61_r4<=8'b0;g62_r4<=8'b0;g63_r4<=8'b0;g64_r4<=8'b0;g65_r4<=8'b0;g66_r4<=8'b0;g67_r4<=8'b0;
				 g71_r4<=8'b0;g72_r4<=8'b0;g73_r4<=8'b0;g74_r4<=8'b0;g75_r4<=8'b0;g76_r4<=8'b0;g77_r4<=8'b0;
		
				 g11_r5<=8'b0;g12_r5<=8'b0;g13_r5<=8'b0;g14_r5<=8'b0;g15_r5<=8'b0;g16_r5<=8'b0;g17_r5<=8'b0;
				 g21_r5<=8'b0;g22_r5<=8'b0;g23_r5<=8'b0;g24_r5<=8'b0;g25_r5<=8'b0;g26_r5<=8'b0;g27_r5<=8'b0;
				 g31_r5<=8'b0;g32_r5<=8'b0;g33_r5<=8'b0;g34_r5<=8'b0;g35_r5<=8'b0;g36_r5<=8'b0;g37_r5<=8'b0;
				 g41_r5<=8'b0;g42_r5<=8'b0;g43_r5<=8'b0;g44_r5<=8'b0;g45_r5<=8'b0;g46_r5<=8'b0;g47_r5<=8'b0;
				 g51_r5<=8'b0;g52_r5<=8'b0;g53_r5<=8'b0;g54_r5<=8'b0;g55_r5<=8'b0;g56_r5<=8'b0;g57_r5<=8'b0;
				 g61_r5<=8'b0;g62_r5<=8'b0;g63_r5<=8'b0;g64_r5<=8'b0;g65_r5<=8'b0;g66_r5<=8'b0;g67_r5<=8'b0;
				 g71_r5<=8'b0;g72_r5<=8'b0;g73_r5<=8'b0;g74_r5<=8'b0;g75_r5<=8'b0;g76_r5<=8'b0;g77_r5<=8'b0;
				   
				 g11_r6<=8'b0;g12_r6<=8'b0;g13_r6<=8'b0;g14_r6<=8'b0;g15_r6<=8'b0;g16_r6<=8'b0;g17_r6<=8'b0;
				 g21_r6<=8'b0;g22_r6<=8'b0;g23_r6<=8'b0;g24_r6<=8'b0;g25_r6<=8'b0;g26_r6<=8'b0;g27_r6<=8'b0;
				 g31_r6<=8'b0;g32_r6<=8'b0;g33_r6<=8'b0;g34_r6<=8'b0;g35_r6<=8'b0;g36_r6<=8'b0;g37_r6<=8'b0;
				 g41_r6<=8'b0;g42_r6<=8'b0;g43_r6<=8'b0;g44_r6<=8'b0;g45_r6<=8'b0;g46_r6<=8'b0;g47_r6<=8'b0;
				 g51_r6<=8'b0;g52_r6<=8'b0;g53_r6<=8'b0;g54_r6<=8'b0;g55_r6<=8'b0;g56_r6<=8'b0;g57_r6<=8'b0;
				 g61_r6<=8'b0;g62_r6<=8'b0;g63_r6<=8'b0;g64_r6<=8'b0;g65_r6<=8'b0;g66_r6<=8'b0;g67_r6<=8'b0;
				 g71_r6<=8'b0;g72_r6<=8'b0;g73_r6<=8'b0;g74_r6<=8'b0;g75_r6<=8'b0;g76_r6<=8'b0;g77_r6<=8'b0;
					
				end
			else
				begin
					g11_r1<=g11; g12_r1<=g12; g13_r1<=g13; g14_r1<=g14; g15_r1<=g15; g16_r1<=g16; g17_r1<=g17;
					g21_r1<=g21; g22_r1<=g22; g23_r1<=g23; g24_r1<=g24; g25_r1<=g25; g26_r1<=g26; g27_r1<=g27;
					g31_r1<=g31; g32_r1<=g32; g33_r1<=g33; g34_r1<=g34; g35_r1<=g35; g36_r1<=g36; g37_r1<=g37;
					g41_r1<=g41; g42_r1<=g42; g43_r1<=g43; g44_r1<=g44; g45_r1<=g45; g46_r1<=g46; g47_r1<=g47;
					g51_r1<=g51; g52_r1<=g52; g53_r1<=g53; g54_r1<=g54; g55_r1<=g55; g56_r1<=g56; g57_r1<=g57;
					g61_r1<=g61; g62_r1<=g62; g63_r1<=g63; g64_r1<=g64; g65_r1<=g65; g66_r1<=g66; g67_r1<=g67;
					g71_r1<=g71; g72_r1<=g72; g73_r1<=g73; g74_r1<=g74; g75_r1<=g75; g76_r1<=g76; g77_r1<=g77;
		
					g11_r2<=g11_r1;g12_r2<=g12_r1;g13_r2<=g13_r1;g14_r2<=g14_r1;g15_r2<=g15_r1;g16_r2<=g16_r1;g17_r2<=g17_r1;
					g21_r2<=g21_r1;g22_r2<=g22_r1;g23_r2<=g23_r1;g24_r2<=g24_r1;g25_r2<=g25_r1;g26_r2<=g26_r1;g27_r2<=g27_r1;
					g31_r2<=g31_r1;g32_r2<=g32_r1;g33_r2<=g33_r1;g34_r2<=g34_r1;g35_r2<=g35_r1;g36_r2<=g36_r1;g37_r2<=g37_r1;
					g41_r2<=g41_r1;g42_r2<=g42_r1;g43_r2<=g43_r1;g44_r2<=g44_r1;g45_r2<=g45_r1;g46_r2<=g46_r1;g47_r2<=g47_r1;
					g51_r2<=g51_r1;g52_r2<=g52_r1;g53_r2<=g53_r1;g54_r2<=g54_r1;g55_r2<=g55_r1;g56_r2<=g56_r1;g57_r2<=g57_r1;
					g61_r2<=g61_r1;g62_r2<=g62_r1;g63_r2<=g63_r1;g64_r2<=g64_r1;g65_r2<=g65_r1;g66_r2<=g66_r1;g67_r2<=g67_r1;
					g71_r2<=g71_r1;g72_r2<=g72_r1;g73_r2<=g73_r1;g74_r2<=g74_r1;g75_r2<=g75_r1;g76_r2<=g76_r1;g77_r2<=g77_r1;
			
					g11_r3<=g11_r2;g12_r3<=g12_r2;g13_r3<=g13_r2;g14_r3<=g14_r2;g15_r3<=g15_r2;g16_r3<=g16_r2;g17_r3<=g17_r2;
					g21_r3<=g21_r2;g22_r3<=g22_r2;g23_r3<=g23_r2;g24_r3<=g24_r2;g25_r3<=g25_r2;g26_r3<=g26_r2;g27_r3<=g27_r2;
					g31_r3<=g31_r2;g32_r3<=g32_r2;g33_r3<=g33_r2;g34_r3<=g34_r2;g35_r3<=g35_r2;g36_r3<=g36_r2;g37_r3<=g37_r2;
					g41_r3<=g41_r2;g42_r3<=g42_r2;g43_r3<=g43_r2;g44_r3<=g44_r2;g45_r3<=g45_r2;g46_r3<=g46_r2;g47_r3<=g47_r2;
					g51_r3<=g51_r2;g52_r3<=g52_r2;g53_r3<=g53_r2;g54_r3<=g54_r2;g55_r3<=g55_r2;g56_r3<=g56_r2;g57_r3<=g57_r2;
					g61_r3<=g61_r2;g62_r3<=g62_r2;g63_r3<=g63_r2;g64_r3<=g64_r2;g65_r3<=g65_r2;g66_r3<=g66_r2;g67_r3<=g67_r2;
					g71_r3<=g71_r2;g72_r3<=g72_r2;g73_r3<=g73_r2;g74_r3<=g74_r2;g75_r3<=g75_r2;g76_r3<=g76_r2;g77_r3<=g77_r2;
			
					g11_r4<=g11_r3;g12_r4<=g12_r3;g13_r4<=g13_r3;g14_r4<=g14_r3;g15_r4<=g15_r3;g16_r4<=g16_r3;g17_r4<=g17_r3;
					g21_r4<=g21_r3;g22_r4<=g22_r3;g23_r4<=g23_r3;g24_r4<=g24_r3;g25_r4<=g25_r3;g26_r4<=g26_r3;g27_r4<=g27_r3;
					g31_r4<=g31_r3;g32_r4<=g32_r3;g33_r4<=g33_r3;g34_r4<=g34_r3;g35_r4<=g35_r3;g36_r4<=g36_r3;g37_r4<=g37_r3;
					g41_r4<=g41_r3;g42_r4<=g42_r3;g43_r4<=g43_r3;g44_r4<=g44_r3;g45_r4<=g45_r3;g46_r4<=g46_r3;g47_r4<=g47_r3;
					g51_r4<=g51_r3;g52_r4<=g52_r3;g53_r4<=g53_r3;g54_r4<=g54_r3;g55_r4<=g55_r3;g56_r4<=g56_r3;g57_r4<=g57_r3;
					g61_r4<=g61_r3;g62_r4<=g62_r3;g63_r4<=g63_r3;g64_r4<=g64_r3;g65_r4<=g65_r3;g66_r4<=g66_r3;g67_r4<=g67_r3;
					g71_r4<=g71_r3;g72_r4<=g72_r3;g73_r4<=g73_r3;g74_r4<=g74_r3;g75_r4<=g75_r3;g76_r4<=g76_r3;g77_r4<=g77_r3;
		
					g11_r5<=g11_r4;g12_r5<=g12_r4;g13_r5<=g13_r4;g14_r5<=g14_r4;g15_r5<=g15_r4;g16_r5<=g16_r4;g17_r5<=g17_r4;
					g21_r5<=g21_r4;g22_r5<=g22_r4;g23_r5<=g23_r4;g24_r5<=g24_r4;g25_r5<=g25_r4;g26_r5<=g26_r4;g27_r5<=g27_r4;
					g31_r5<=g31_r4;g32_r5<=g32_r4;g33_r5<=g33_r4;g34_r5<=g34_r4;g35_r5<=g35_r4;g36_r5<=g36_r4;g37_r5<=g37_r4;
					g41_r5<=g41_r4;g42_r5<=g42_r4;g43_r5<=g43_r4;g44_r5<=g44_r4;g45_r5<=g45_r4;g46_r5<=g46_r4;g47_r5<=g47_r4;
					g51_r5<=g51_r4;g52_r5<=g52_r4;g53_r5<=g53_r4;g54_r5<=g54_r4;g55_r5<=g55_r4;g56_r5<=g56_r4;g57_r5<=g57_r4;
					g61_r5<=g61_r4;g62_r5<=g62_r4;g63_r5<=g63_r4;g64_r5<=g64_r4;g65_r5<=g65_r4;g66_r5<=g66_r4;g67_r5<=g67_r4;
					g71_r5<=g71_r4;g72_r5<=g72_r4;g73_r5<=g73_r4;g74_r5<=g74_r4;g75_r5<=g75_r4;g76_r5<=g76_r4;g77_r5<=g77_r4;
		
					g11_r6<=g11_r5;g12_r6<=g12_r5;g13_r6<=g13_r5;g14_r6<=g14_r5;g15_r6<=g15_r5;g16_r6<=g16_r5;g17_r6<=g17_r5;
					g21_r6<=g21_r5;g22_r6<=g22_r5;g23_r6<=g23_r5;g24_r6<=g24_r5;g25_r6<=g25_r5;g26_r6<=g26_r5;g27_r6<=g27_r5;
					g31_r6<=g31_r5;g32_r6<=g32_r5;g33_r6<=g33_r5;g34_r6<=g34_r5;g35_r6<=g35_r5;g36_r6<=g36_r5;g37_r6<=g37_r5;
					g41_r6<=g41_r5;g42_r6<=g42_r5;g43_r6<=g43_r5;g44_r6<=g44_r5;g45_r6<=g45_r5;g46_r6<=g46_r5;g47_r6<=g47_r5;
					g51_r6<=g51_r5;g52_r6<=g52_r5;g53_r6<=g53_r5;g54_r6<=g54_r5;g55_r6<=g55_r5;g56_r6<=g56_r5;g57_r6<=g57_r5;
					g61_r6<=g61_r5;g62_r6<=g62_r5;g63_r6<=g63_r5;g64_r6<=g64_r5;g65_r6<=g65_r5;g66_r6<=g66_r5;g67_r6<=g67_r5;
					g71_r6<=g71_r5;g72_r6<=g72_r5;g73_r6<=g73_r5;g74_r6<=g74_r5;g75_r6<=g75_r5;g76_r6<=g76_r5;g77_r6<=g77_r5;	
				end
		end
		
	//---------------------------------------计算SL,SM,SR,A,B-------------------------------------------------------------------
	wire	[9:0]	A,B;
	wire	[10:0]	SL,SM,SR;
	colum_sum	colum_sum_inst(
		.clk	(clk),
		.rst	(julge_start),
		.state	(state_w),
		.p11(g11_r6),	.p12(g12_r6),	.p13(g13_r6),	.p14(g14_r6),	.p15(g15_r6),	.p16(g16_r6),	.p17(g17_r6),
		.p21(g21_r6),	.p22(g22_r6),	.p23(g23_r6),	.p24(g24_r6),	.p25(g25_r6),	.p26(g26_r6),	.p27(g27_r6),
		.p31(g31_r6),	.p32(g32_r6),	.p33(g33_r6),	.p34(g34_r6),	.p35(g35_r6),	.p36(g36_r6),	.p37(g37_r6),
		.p41(g41_r6),	.p42(g42_r6),	.p43(g43_r6),	.p44(g44_r6),	.p45(g45_r6),	.p46(g46_r6),	.p47(g47_r6),
		.p51(g51_r6),	.p52(g52_r6),	.p53(g53_r6),	.p54(g54_r6),	.p55(g55_r6),	.p56(g56_r6),	.p57(g57_r6),
		.p61(g61_r6),	.p62(g62_r6),	.p63(g63_r6),	.p64(g64_r6),	.p65(g65_r6),	.p66(g66_r6),	.p67(g67_r6),
		.p71(g71_r6),	.p72(g72_r6),	.p73(g73_r6),	.p74(g74_r6),	.p75(g75_r6),	.p76(g76_r6),	.p77(g77_r6),
		
		.SL(SL),
		.SM(SM),
		.SR(SR)
	);
	
	compute_AB compute_AB_inst(
		.clk	(clk),
		.rst	(julge_start),
		.state	(state_w),
		.p11(g11_r6),	.p12(g12_r6),	.p13(g13_r6),	.p14(g14_r6),	.p15(g15_r6),	.p16(g16_r6),	.p17(g17_r6),
		.p21(g21_r6),	.p22(g22_r6),	.p23(g23_r6),	.p24(g24_r6),	.p25(g25_r6),	.p26(g26_r6),	.p27(g27_r6),
		.p31(g31_r6),	.p32(g32_r6),	.p33(g33_r6),	.p34(g34_r6),	.p35(g35_r6),	.p36(g36_r6),	.p37(g37_r6),
		.p41(g41_r6),	.p42(g42_r6),	.p43(g43_r6),	.p44(g44_r6),	.p45(g45_r6),	.p46(g46_r6),	.p47(g47_r6),
		.p51(g51_r6),	.p52(g52_r6),	.p53(g53_r6),	.p54(g54_r6),	.p55(g55_r6),	.p56(g56_r6),	.p57(g57_r6),
		.p61(g61_r6),	.p62(g62_r6),	.p63(g63_r6),	.p64(g64_r6),	.p65(g65_r6),	.p66(g66_r6),	.p67(g67_r6),
		.p71(g71_r6),	.p72(g72_r6),	.p73(g73_r6),	.p74(g74_r6),	.p75(g75_r6),	.p76(g76_r6),	.p77(g77_r6),
		
		.A(A),
		.B(B)
	);
	
	//------------------------------------计算a,b-------------------------------------------------------------------------------
	//计算a,b开始的控制信号
	reg	[4:0]	cnt_ab;	
	reg			ab_start_r;
	//wire		ab_start;
	always@(posedge clk or negedge rst)
		if(~rst)
			begin
			 cnt_ab <= 3'h0;
			 ab_start_r <= 1'b0;
			end
		else 
			begin
				if(julge_start)
					begin
					if(cnt_ab<8)
						cnt_ab <= cnt_ab + 1'b1;
					else
						ab_start_r <= 1'b1;
					end
				else
					ab_start_r <= 1'b0;
			end
	assign	ab_start = ab_start_r;
	
	//需要12个时钟周期
	compute_a compute_a_inst(
		.clk	(clk),
	    .rst	(ab_start),
		.SM		(SM),
	    .A		(A),
	    .B		(B),
	    .result_a(result_a),
		.adivbyzero (adivbyzero)
	);
	
	compute_b compute_b_inst(
		.clk	(clk),
		.rst	(ab_start),
		.SL		(SL),
		.SR		(SR),
		.A		(A),
		.B		(B),
		.result_b(result_b),
		.bdivbyzero (bdivbyzero)
	);
	
	/*****************将state_w输出和a,b输出时间一致，即state_w延迟15个周期************/
	reg		[31:0]	state_r;
	reg		[27:0]	state_rr;
	
	always@(posedge clk or negedge rst)
		begin
			if(!rst)
				begin
					state_r  <= 32'd0;
					state_rr <= 32'd0;
				end
			else
				begin
					state_r <= {state_r[27:0],state_w};
					state_rr <={state_rr[23:0],state_r[31:28]};
				end
		end
	
	assign state = state_rr[27:24];
	
endmodule		
	