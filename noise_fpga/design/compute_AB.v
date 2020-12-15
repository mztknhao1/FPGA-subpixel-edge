/******************************计算A和B值的模块********************************
//状态
//Fy<Fx,且一正一负，（135，180） state == 0001    7*3窗口，右上角和左下角

//Fy<Fx,且两个同号，（0，45）	state == 0010	  7*3窗口，左上角和右下角

//Fy>Fx,且一正一负，（90，135）	state == 0100     3*7窗口，左下角和右上角

//Fy>Fx,且一正一负，（45，90）	state == 1000	  3*7窗口，左上角和右下角

//3级流水线结构
*******************************************************************************/

module	compute_AB(
		input			clk,
		input			rst,
		input	[3:0]	state,
		
		input	[7:0]	p11,p12,p13,p14,p15,p16,p17,
						p21,p22,p23,p24,p25,p26,p27,
						p31,p32,p33,p34,p35,p36,p37,
						p41,p42,p43,p44,p45,p46,p47,
						p51,p52,p53,p54,p55,p56,p57,
						p61,p62,p63,p64,p65,p66,p67,
						p71,p72,p73,p74,p75,p76,p77,
		
		output	[9:0]	A,B
);

	reg	[9:0]	rA,rB;
	reg	[9:0]	tempA1,tempA2,tempA3;
	reg	[9:0]	tempB1,tempB2,tempB3;
	
	
	always@(posedge clk or negedge rst)
		begin
		if(~rst)
			begin
				rA <= 0;
				rB <= 0;
				tempA1 <= 0;
				tempA2 <= 0;
				tempA3 <= 0;
				tempB1 <= 0;
				tempB2 <= 0;
				tempB3 <= 0;
			end
		else
			begin
			 case(state)
			 	4'b0001:						//((p14+p15)/2+p15)
			 		begin
			 		 //一级流水线
			 		 tempB1 <= p14 + p25;
			 		 tempB2 <= p15;
			 		 
			 		 tempA1 <= p63 + p74;
			 		 tempA2 <= p73;
			 		 
			 		 //二级流水线
			 		 tempB3 <= (tempB1>>1) + tempB2;
			 		 tempA3 <= (tempA1>>1) + tempA2;
			 		 
			 		 //三级流水线
			 		 rB		<= (tempB3) >> 1;
			 		 rA     <= (tempA3) >> 1;	
			 		end
			 	4'b0010:
			 		begin
			 		 //一级流水线
			 		 tempB1 <= p14 + p23;
			 		 tempB2 <= p13;
			 		 
			 		 tempA1 <= p65 + p74;
			 		 tempA2 <= p75;
			 		 
			 		 //二级流水线
			 		 tempB3 <= (tempB1>>1) + tempB2;
			 		 tempA3 <= (tempA1>>1) + tempA2;
			 		 
			 		 //三级流水线
			 		 rB		<= (tempB3) >> 1;
			 		 rA     <= (tempA3) >> 1;	
			 		end
			 	4'b0100:
			 		begin
			 		 //一级流水线
			 		 tempB1 <= p41 + p32;
			 		 tempB2 <= p31;
			 		 
			 		 tempA1 <= p56 + p47;
			 		 tempA2 <= p57;
			 		 
			 		 //二级流水线
			 		 tempB3 <= (tempB1>>1) + tempB2;
			 		 tempA3 <= (tempA1>>1) + tempA2;
			 		 
			 		 //三级流水线
			 		 rB		<= (tempB3) >> 1;
			 		 rA     <= (tempA3) >> 1;	
			 		end
			 	4'b1000:
			 		begin
			 		 //一级流水线
			 		 tempB1 <= p36 + p47;
			 		 tempB2 <= p37;
			 		 
			 		 tempA1 <= p52 + p41;
			 		 tempA2 <= p51;
			 		 
			 		 //二级流水线
			 		 tempB3 <= (tempB1>>1) + tempB2;
			 		 tempA3 <= (tempA1>>1) + tempA2;
			 		 
			 		 //三级流水线
			 		 rB		<= (tempB3 >> 1);
			 		 rA     <= (tempA3 >> 1);	
			 		end
			 	default:
			 		begin
			 		 //一级流水线
			 		 tempB1 <= p14 + p23;
			 		 tempB2 <= p13;
			 		 
			 		 tempA1 <= p65 + p74;
			 		 tempA2 <= p75;
			 		 
			 		 //二级流水线
			 		 tempB3 <= (tempB1>>1) + tempB2;
			 		 tempA3 <= (tempA1>>1) + tempA2;
			 		 
			 		 //三级流水线
			 		 rB		<= (tempB3 >> 1);
			 		 rA     <= (tempA3 >> 1);	
			 		end
			 endcase
			end
		end

		assign	A = rA;
		assign  B = rB;
		
endmodule