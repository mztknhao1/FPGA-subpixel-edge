/*****************************顶层测试模块**************************************
//（1）从p11到p55输入，到state输出需要6个周期
//（2）这个时候输入p11到p55和state,则p11到p55需要延时6周期，
//（3）即输入p11_r6到p55_r6和此时state
//     到SL,SM,SR,A_next,B_next模块，然后需要3个周期
//（4）将SL,SM,SR,A_next,B_next输入到compute_a,b,c模块中
//（5）经过10个周期以后输出result_a,result_b,result_c

//测试结果：阈值设定不合理。
********************************************************************************/


`timescale	1ns/1ps
module	tb_noise;

	reg	clk,rst;
	reg	  [7:0]	 din;
	wire  [31:0] a,b;
	wire  [3:0]	 state;
	wire    	 adivbyzero,bdivbyzero;
	wire		 ab_start;
	wire  [7:0]	 gin;
	wire		 window_7x7_start;
	reg   [7:0]  image_data [163839:0];
	
	//图像像素索引
	reg [31:0] index;
	reg			empty;
	
	integer  fp1,fp2,fp3,fp4;

	initial begin
		//初始化激励
		clk = 0;
		rst = 0;
		din = 0;
		
		//等待100ns全局初始化
		#100
		rst = 1;
	end
	
	//产生时钟信号
	always
	# 5 clk=~clk;
	
	//读存储着的图像数据
	initial begin
		index = 32'b0;
		#50
		$readmemb ("medinoise.txt",image_data);
	end
	
	//连接输出数据的文件
	initial 
		begin
			fp1 = $fopen("medinoise_a.txt");
			fp2 = $fopen("medinoise_b.txt");
			fp3 = $fopen("medinoise_state.txt");
			fp4 = $fopen("medinoise_gaussian.txt");
		end
	
	//依次读入图像数据
	always @(posedge clk or negedge rst)
		if(~rst)
			begin
				index <= 32'd0;
			end
		else
			begin
				din <= image_data[index];
				index <= index + 32'd1;
			end
	
	
	top_noise top_noise_inst(
		.clk			(clk),
		.rst			(rst),
		
		.din			(din),
		
		.window_7x7_start (window_7x7_start),
		.gin			(gin),
		
		.result_a		(a),
		.adivbyzero		(adivbyzero),
		.result_b		(b),
		.bdivbyzero		(bdivbyzero),
		
		.ab_start		(ab_start),
		.state			(state),
		.frame_complete (frame_complete)	
	);  

	//输出结果
	always @(posedge clk or posedge ab_start)
		if(~ab_start)
			//$display("please wait data valid\n");
			empty <= 1'b0;
		else
			begin
				$fdisplay(fp1,"%h",a);
				$fdisplay(fp2,"%h",b);
				$fdisplay(fp3,"%b",state);
			end
		
	reg		[0:0]	empty2;
	always @(posedge clk or posedge ab_start)
		if(~window_7x7_start)
			//$display("please wait data valid\n");
			empty2 <= 1'b0;
		else
			begin
				$fdisplay(fp4,"%b",gin);
			end
	
	
endmodule