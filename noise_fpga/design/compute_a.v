/*********************************计算a模块********************************
//a = {2SM - 5(A+B)}/(2(A-B))

***************************************************************************/

module	compute_a(
		input			clk,
		input			rst,
		input	[10:0]	SM,
		input	[9:0]	A,
		input	[9:0]	B,
		
		output	[31:0]	result_a,
		output			adivbyzero

);
	
	
	reg	signed [14:0]	AsubB,AsubB2,AsubB21;

	reg	[14:0]	SM2,SM21;
	
	reg	[14:0]	AaddB,AaddB4,AaddB5;
	
	reg	signed [14:0]	Nu;
	

	always@(posedge	clk	or negedge	rst)
		begin
			if(~rst)
				begin
					AsubB   <= 15'b0;
					AsubB2  <= 15'b0;
					AsubB21 <= 15'b0;
					            
					AaddB   <= 15'b0;
					AaddB4  <= 15'b0;
					AaddB5  <= 15'b0;
					            
					SM2     <= 15'b0;
					SM21	<= 15'b0;
					
					Nu		<= 15'b0;
				end
			else
				begin
					//1级流水线
					
					AsubB   <= A - B;
					
					SM2     <= SM << 1;					//SM * 2
					
					AaddB	<= A + B;					//(A+B)
					AaddB4   <= (A+B)<<2;				//(A+B)*4
					
					//2级流水线
					
					AsubB2  <= AsubB << 1;
					
					SM21    <= SM2;					    //2*SM
					
					AaddB5  <= AaddB4 + AaddB;			//(A+B)*5
					
					//3级流水线
					AsubB21 <= AsubB2;					//(A-B)*2
					Nu      <= SM21 - AaddB5;			//SM*2 - (A+B)*5
				end
		end
		
		mydiv2	mydiv2_inst(
			.clk	(clk),	
			.rst_n	(rst),	
				
			.dataa	(Nu),	
			.datab	(AsubB21),	
				
			.result	(result_a),	
			.divbyzero (adivbyzero)
		);
		

endmodule