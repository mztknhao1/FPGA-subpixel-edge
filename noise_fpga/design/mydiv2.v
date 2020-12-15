module	mydiv2(
	
	input	clk,
	input	rst_n,

	input	[14:0]	dataa,
	input	[14:0]	datab,
	
	output	[31:0]			result,
	output	[0:0]    		divbyzero
);

	reg				cnt;
	reg		[14:0]	dataa1,dataa2,datab1,datab2;
	wire	[31:0]	result1,result2;
	wire			divbyzero1,divbyzero2;
	reg				divbyzero_r;
	reg		[31:0]	result_r;
	
	always@(posedge clk or negedge	rst_n)
		begin
			if(~rst_n)
				cnt	<= 1'b0;
			else
				cnt	<= cnt + 1;
		end
		
	always@(posedge	clk or negedge	rst_n)
		begin
			if(!rst_n)
				begin
					dataa1 <= 0;
					dataa2 <= 0;
					datab1 <= 0;
					datab2 <= 0;
				end
			else
				begin
					if(cnt == 1'b0)
						begin
							dataa1 <= dataa;
							datab1 <= datab;
						end
					else
						begin
							dataa2 <= dataa;
							datab2 <= datab;
						end
				end
		end


	div2_feng	div1_inst(
			.clk		(clk),
			.rst_n		(rst_n),
			
			.dataa		(dataa1),			//输入两个11位的有符号整数数
			.datab		(datab1),			//	result = dataa/datab
			
			.result 	(result1),			//输出为IEEE754标准的32位浮点数
			.divbyzero  (divbyzero1)
	);
	
	div2_feng	div2_inst(
			.clk		(clk),
			.rst_n		(rst_n),
			
			.dataa		(dataa2),			//输入两个11位的有符号整数数
			.datab		(datab2),			//	result = dataa/datab
			
			.result 	(result2),			//输出为IEEE754标准的32位浮点数
			.divbyzero  (divbyzero2)
	);
	
	always@(cnt)
		begin
			if(cnt == 1'b1)
				begin
					result_r = result1;
					divbyzero_r = divbyzero1;
				end
			else
				begin
					result_r = result2;
					divbyzero_r = divbyzero2;
				end
		end
	
	assign	result = result_r;
	assign	divbyzero = divbyzero_r;
	
endmodule