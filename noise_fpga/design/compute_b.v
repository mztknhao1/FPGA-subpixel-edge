/**********************************计算b模块**************************************
//b = {(SR-SL) + 2*(A-B)}/(2*(A-B))  m=1
	= {(SR-SL) - 2(A-B))}/2*(A-B)
//测试结果，从输入SR,SL,A,B后得到稳定输出结果需要 个时钟
**********************************************************************************/

module	compute_b(
	input	clk,
	input	rst,
	input	[3:0]	state,
	input	[10:0]	SL,
	input	[10:0]	SR,
	input	[9:0]	A,
	input	[9:0]	B,
	output	[31:0]	result_b,
	output			bdivbyzero
);

	reg	[14:0]	AsubB;
	reg	[14:0]	AsubB2;
	reg	[14:0]	RsubL,RsubL2;
	reg	[14:0]	zi,mu;
	reg	[14:0]	SR2,SL2;
	
	wire		m;
	assign		m = (state[3] | state[1]);
	
	always@(posedge	clk	or	negedge	rst)
		begin
			if(!rst)
				begin
					AsubB    <= 15'b0;
					AsubB2   <= 15'b0;
					RsubL    <=	15'b0;
					RsubL2   <= 15'b0;
					SR2		 <= 15'b0;
					SL2		 <=	15'b0;
				end
			else
				begin
				 if(m)
				 	begin
				 	 //一级流水线
				 	 AsubB    <= (A-B);
				 	 SR2      <= SR << 1;
				 	 SL2      <= SL << 1;
				 	 RsubL    <= SR - SL;
				 	 
				 	 
				 	 //二级流水线
				 	 AsubB2  <= AsubB << 1;			//(A-B)*2
				 	 RsubL2  <= RsubL;			  //(R-L)*2 + (R-L)
				 	 
				 	 //三级流水线
				 	 zi		<=	RsubL2 + AsubB2;
				 	 mu		<=	AsubB2;
				 	end	
				 else
				 	begin
				 	 //一级流水线
				 	 AsubB    <= (A-B);
				 	 SR2      <= SR << 1;
				 	 SL2      <= SL << 1;
				 	 RsubL    <= SR - SL;
				 	 
				 	 
				 	 //二级流水线
				 	 AsubB2  <= AsubB << 1;			//(A-B)*2
				 	 RsubL2  <= RsubL;			  //(R-L)*2 + (R-L)
				 	 
				 	 //三级流水线
				 	 zi		<=	RsubL2 - AsubB2;
				 	 mu		<=	AsubB2;
				 	end
				end
		end
		
	mydiv2	mydiv_inst(
	
			.clk	(clk),
			.rst_n	(rst),
			
			.dataa	(zi),
			.datab	(mu),
			
			.result	(result_b),
			.divbyzero (bdivbyzero)
	);

endmodule