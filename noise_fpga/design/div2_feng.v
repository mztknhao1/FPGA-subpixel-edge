	//两个时钟出一个正确的数，所以数据需要保持两个时钟不变。
	//进入数据后延迟5个时钟。
	//输入两个15位的有符号数
	
module	div2_feng(
		input					 clk,
		input					 rst_n,
		
		input  wire signed[14:0] dataa,			//输入两个15位的有符号整数数
		input  wire signed[14:0] datab,			//	result = dataa/datab
		
		output wire signed[31:0] result, 		//输出为IEEE754标准的32位浮点数
		output wire		  [0:0]	 divbyzero
	);
	
	reg	[13:0]	dataain;		                //绝对值
	reg	[13:0]	databin;
	reg signed [14:0]	signed_a;
	reg signed [14:0]	signed_b;
	reg	  		        signed_result1;
	reg			        signed_result2;
	reg	  [31:0]	    data_mu_r1,data_mu_r2,data_mu_r3,data_mu_r4;	//同步时序
	
	reg					flag_div_0;
	
	//取符号和取值
	always@(posedge clk or negedge rst_n)
	begin
	if(!rst_n)
		begin
		signed_result1	<=	1'b0;
		signed_result2	<=	1'b0;
		signed_a		<=	15'b0;
		signed_b		<=	15'b0;
		end
	else
		begin
		signed_result1	<=	dataa[14];
		signed_result2	<=	datab[14];
		signed_a		<=	dataa;
		signed_b		<=	datab;
		end
	end
	
	/****************计算结果的符号位，即result[31]**************************************/
	reg		signed_result_r;
	always@(posedge clk or negedge rst_n)
	begin
	if(!rst_n)
		signed_result_r	<=	0;
	else	
		signed_result_r	<=	(signed_result1^signed_result2);//用异或来判断两个数的正负
	end
	
	reg	[5:0]	signed_result_rr;	//同步时序
	always@(posedge clk or negedge rst_n)
	begin
	if(!rst_n)
		signed_result_rr	<=	0;
	else	
		signed_result_rr	<=	{signed_result_rr[4:0],signed_result_r};
	end
	
	
	/****************************计算绝对值，使用div_lpm IP core************************/
	always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			begin
			dataain	<=	14'd0;
			end
		else if(signed_a < 0)
			begin								//负数的存储格式为：绝对值二进制取反加1
			dataain	<=	~signed_a[13:0] + 1'b1;	//负数原码取反加1即变为正数（绝对值）
			end
		else if((signed_a > 0)	||	(signed_a == 0))
			begin
			dataain	<=	signed_a[13:0];	
			end
		else
			begin
			dataain	<=	dataain;	
			end
	end	

	always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			begin
			databin	<=	14'd0;
			end
		else if(signed_b < 0)
			begin
			databin	<=	~signed_b[13:0] + 1'b1;	//负数补码取反加1即变为绝对值
			end
		else if((signed_b > 0)	||	(signed_b == 0))
			begin
			databin	<=	signed_b[13:0];	
			end
		else
			begin
			databin	<=	databin;	
			end
	end	
	

	reg	signed[31:0] data_zi;
	reg signed[31:0] data_mu;
	wire	  [31:0] quotient;
	wire	  [31:0] remain;
	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n)
				begin
					data_zi	= 	32'b0;
					data_mu	=	32'b0;
				end
			else
				begin
					data_zi	=	dataain << 17;	//左移17位，相当于放大2^17倍
					data_mu	=	databin;
				end
		end
	
	div_lpm 	u_div_lpm	//调用LPM_DIVIDE ip Core
	(
		.clken		(rst_n),
		.clock		(clk),
		.denom		(data_mu_r1),
		.numer		(data_zi),
		.quotient	(quotient),
		.remain		(remain)
	);
	
	wire signed	[30:0] 	flag = quotient[30:0];
	reg			[30:0]	dataout;
	reg			[22:0]	a;
	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n)
				begin
					dataout	<=	31'b0;
					a		<=	23'b0;	
				end
			else
				begin
					casez(flag)
						31'b1???_????_????_????_????_????_????_???:		begin dataout	<=	{flag[29:7],8'd0};          flag_div_0 <= 1'b0; end
						31'b01??_????_????_????_????_????_????_???:		begin dataout	<=	{flag[28:6],8'd1};          flag_div_0 <= 1'b0; end
						31'b001?_????_????_????_????_????_????_???:		begin dataout	<=	{flag[27:5],8'd2};          flag_div_0 <= 1'b0; end
						31'b0001_????_????_????_????_????_????_???:		begin dataout	<=	{flag[26:4],8'd3};          flag_div_0 <= 1'b0; end
						31'b0000_1???_????_????_????_????_????_???:		begin dataout	<=	{flag[25:3],8'd4};          flag_div_0 <= 1'b0; end
						31'b0000_01??_????_????_????_????_????_???:		begin dataout	<=	{flag[24:2],8'd5};          flag_div_0 <= 1'b0; end
						31'b0000_001?_????_????_????_????_????_???:		begin dataout	<=	{flag[23:1],8'd7};          flag_div_0 <= 1'b0; end
						31'b0000_0001_????_????_????_????_????_???:		begin dataout	<=	{flag[22:0],8'd8};          flag_div_0 <= 1'b0; end
						31'b0000_0000_1???_????_????_????_????_???:		begin dataout	<=	{flag[21:0],a[0],8'd9};     flag_div_0 <= 1'b0; end
						31'b0000_0000_01??_????_????_????_????_???:		begin dataout	<=	{flag[20:0],a[1:0],8'd10};  flag_div_0 <= 1'b0; end
						31'b0000_0000_001?_????_????_????_????_???:		begin dataout	<=	{flag[19:0],a[2:0],8'd11};  flag_div_0 <= 1'b0; end
						31'b0000_0000_0001_????_????_????_????_???:		begin dataout	<=	{flag[18:0],a[3:0],8'd12};  flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_1???_????_????_????_???:		begin dataout	<=	{flag[17:0],a[4:0],8'd13};  flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_01??_????_????_????_???:		begin dataout	<=	{flag[16:0],a[5:0],8'd14};  flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_001?_????_????_????_???:		begin dataout	<=	{flag[15:0],a[6:0],8'd15};  flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_0001_????_????_????_???:		begin dataout	<=	{flag[14:0],a[7:0],8'd16};  flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_0000_1???_????_????_???:		begin dataout	<=	{flag[13:0],a[8:0],8'd17};  flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_0000_01??_????_????_???:		begin dataout	<=	{flag[12:0],a[9:0],8'd18};  flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_0000_001?_????_????_???:		begin dataout	<=	{flag[11:0],a[10:0],8'd19}; flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_0000_0001_????_????_???:		begin dataout	<=	{flag[10:0],a[11:0],8'd20}; flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_0000_0000_1???_????_???:		begin dataout	<=	{flag[9:0],a[12:0],8'd21};  flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_0000_0000_01??_????_???:		begin dataout	<=	{flag[8:0],a[13:0],8'd22};  flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_0000_0000_001?_????_???:		begin dataout	<=	{flag[7:0],a[14:0],8'd23};  flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_0000_0000_0001_????_???:		begin dataout	<=	{flag[6:0],a[15:0],8'd24};  flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_0000_0000_0000_1???_???:		begin dataout	<=	{flag[5:0],a[16:0],8'd25};  flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_0000_0000_0000_01??_???:		begin dataout	<=	{flag[4:0],a[17:0],8'd26};  flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_0000_0000_0000_001?_???:		begin dataout	<=	{flag[3:0],a[18:0],8'd27};  flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_0000_0000_0000_0001_???:		begin dataout	<=	{flag[2:0],a[19:0],8'd28};  flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_0000_0000_0000_0000_1??:		begin dataout	<=	{flag[1:0],a[20:0],8'd29};  flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_0000_0000_0000_0000_01?:		begin dataout	<=	{flag[0],a[21:0],8'd30};    flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_0000_0000_0000_0000_001:		begin dataout	<=	{a[22:0],8'd31};            flag_div_0 <= 1'b0; end
						31'b0000_0000_0000_0000_0000_0000_0000_000:     begin dataout   <=	{a[22:0],8'd141};           flag_div_0 <= 1'b0; end
						default									  :		begin dataout   <=	{a[22:0],8'd141};           flag_div_0 <= 1'b1; end
					endcase                                                                                              
				end
		end	
	

	
	/************************************计算exp2,根据data_mu和exp1*************************/
	
	reg	  [7:0]       exp1;
	reg   [7:0] 	  exp2;	
	
	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n)
				exp1 <=	8'b0;	
			else	
				exp1 <=	dataout[7:0];	
		end	
	
	
	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n)
				begin
					data_mu_r1	<=	0;
					data_mu_r2  <=  0;
				end
			else	
				{data_mu_r4,data_mu_r3,data_mu_r2,data_mu_r1}<={data_mu_r3,data_mu_r2,data_mu_r1,data_mu};
		end

	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n)
				begin
					exp2 <=	8'b0;
				end
			else  if(data_mu_r4)
				begin
					exp2 <=	8'd141 -	exp1;			//141 = 14 + 127
				end
			else
					exp2 <=	8'b0;
		end
	
	
	/********************************计算小数位******************************************/
	reg	[31:0]	dataout_r;
	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n)
				dataout_r <= 32'b0;
			else
				dataout_r <= dataout;
		end
	
	
	reg	[22:0]	dataout_rr;				
	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n)
				dataout_rr		<=	23'b0;     
			else	
				dataout_rr		<=	dataout_r[30:8];
		end	
		
	/*****************************除以0的标志位******************************************/
	reg	  [1:0]		    flag_div_r;
	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n)
				flag_div_r	<=	2'b0;
			else	
				flag_div_r	<=	{flag_div_r[0:0],flag_div_0};
	end
	
	/*********************************将32位结果连出************************************/
	assign	result[31]		=	signed_result_rr[5];
	assign	result[30:23]	=	exp2;
	assign	result[22:0]	=	dataout_rr;		
	assign	divbyzero       =   flag_div_r[1];
	
	
endmodule	