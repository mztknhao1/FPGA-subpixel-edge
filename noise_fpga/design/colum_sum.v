/******************************计算A和B值的模块********************************
//状态
//Fy<Fx,且一正一负，（135，180） state == 0001    7*3窗口，右上角和左下角

//Fy<Fx,且两个同号，（0，45）	state == 0010	  7*3窗口，左上角和右下角

//Fy>Fx,且一正一负，（90，135）	state == 0100     3*7窗口，左下角和右上角

//Fy>Fx,且一正一负，（45，90）	state == 1000	  3*7窗口，左上角和右下角

//2级流水线结构
*******************************************************************************/

module	colum_sum(
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
		
		output	[10:0]	SL,SM,SR
);

	reg	[10:0]	rSL,rSM,rSR;
	reg [10:0]	tempL1,tempL2,tempL3,tempL4,tempL5;
	reg [10:0]	tempM1,tempM2,tempM3,tempM4,tempM5;
	reg	[10:0]	tempR1,tempR2,tempR3,tempR4,tempR5;

	always@(posedge clk or negedge rst)
		if(~rst)
			begin
				tempL1 <= 0;
				tempL2 <= 0;
				tempL3 <= 0;
				tempL4 <= 0;
				tempL5 <= 0;
				tempM1 <= 0;
				tempM2 <= 0;
				tempM3 <= 0;
				tempM4 <= 0;
				tempM5 <= 0;
				tempR1 <= 0;
				tempR2 <= 0;
				tempR3 <= 0;
				tempR4 <= 0;
				tempR5 <= 0;
				rSL <= 0;
				rSM <= 0;
				rSR <= 0;
			end
		else
			begin
			 case(state)
				4'b0001:
					begin
					 //SL
					 tempL1 <= p13 + p23; 
					 tempL2 <= p33 + p43;
					 tempL3 <= p53;
					 
					 tempL4 <= tempL1 + tempL2;
					 tempL5 <= tempL3;
					 
					 rSL   <= tempL4 + tempL5;
					 
					 //SM
					 tempM1 <= p24 + p34; 
					 tempM2 <= p44 + p54;
					 tempM3 <= p64;
					 
					 tempM4 <= tempM1 + tempM2;
					 tempM5 <= tempM3;
					 
					 rSM   <= tempM4 + tempM5;
					 
					 //SR
					 tempR1 <= p35 + p45; 
					 tempR2 <= p55 + p65;
					 tempR3 <= p75;
					 
					 tempR4 <= tempR1 + tempR2;
					 tempR5 <= tempR3;
					 
					 rSR   <= tempR4 + tempR5;
					end
				4'b0010:
					begin
					 //SL
					 tempL1 <= p33 + p43; 
					 tempL2 <= p53 + p63;
					 tempL3 <= p73;
					 
					 tempL4 <= tempL1 + tempL2;
					 tempL5 <= tempL3;
					 
					 rSL   <= tempL4 + tempL5;
					 
					 //SM
					 tempM1 <= p24 + p34; 
					 tempM2 <= p44 + p54;
					 tempM3 <= p64;
					 
					 tempM4 <= tempM1 + tempM2;
					 tempM5 <= tempM3;
					 
					 rSM   <= tempM4 + tempM5;
					 
					 //SR
					 tempR1 <= p15 + p25; 
					 tempR2 <= p35 + p45;
					 tempR3 <= p55;
					 
					 tempR4 <= tempR1 + tempR2;
					 tempR5 <= tempR3;
					 
					 rSR   <= tempR4 + tempR5;
					end
				4'b0100:
					begin
					 //SL
					 tempL1 <= p31 + p32; 
					 tempL2 <= p33 + p34;
					 tempL3 <= p35;
					 
					 tempL4 <= tempL1 + tempL2;
					 tempL5 <= tempL3;
					 
					 rSL   <= tempL4 + tempL5;
					 
					 //SM
					 tempM1 <= p42 + p43; 
					 tempM2 <= p44 + p45;
					 tempM3 <= p46;
					 
					 tempM4 <= tempM1 + tempM2;
					 tempM5 <= tempM3;
					 
					 rSM   <= tempM4 + tempM5;
					 
					 //SR
					 tempR1 <= p53 + p54; 
					 tempR2 <= p55 + p56;
					 tempR3 <= p57;
					 
					 tempR4 <= tempR1 + tempR2;
					 tempR5 <= tempR3;
					 
					 rSR   <= tempR4 + tempR5;
					end
				4'b1000:
					begin
					 //SL
					 tempL1 <= p33 + p34; 
					 tempL2 <= p35 + p36;
					 tempL3 <= p37;
					 
					 tempL4 <= tempL1 + tempL2;
					 tempL5 <= tempL3;
					 
					 rSL   <= tempL4 + tempL5;
					 
					 //SM
					 tempM1 <= p42 + p43; 
					 tempM2 <= p44 + p45;
					 tempM3 <= p46;
					 
					 tempM4 <= tempM1 + tempM2;
					 tempM5 <= tempM3;
					 
					 rSM   <= tempM4 + tempM5;
					 
					 //SR
					 tempR1 <= p51 + p52; 
					 tempR2 <= p53 + p54;
					 tempR3 <= p55;
					 
					 tempR4 <= tempR1 + tempR2;
					 tempR5 <= tempR3;
					 
					 rSR   <= tempR4 + tempR5;
					end
				default:
					begin
					 //SL
					 tempL1 <= p33 + p43; 
					 tempL2 <= p53 + p63;
					 tempL3 <= p73;
					 
					 tempL4 <= tempL1 + tempL2;
					 tempL5 <= tempL3;
					 
					 rSL   <= tempL4 + tempL5;
					 
					 //SM
					 tempM1 <= p24 + p34; 
					 tempM2 <= p44 + p54;
					 tempM3 <= p64;
					 
					 tempM4 <= tempM1 + tempM2;
					 tempM5 <= tempM3;
					 
					 rSM   <= tempM4 + tempM5;
					 
					 //SR
					 tempR1 <= p15 + p25; 
					 tempR2 <= p35 + p45;
					 tempR3 <= p55;
					 
					 tempR4 <= tempR1 + tempR2;
					 tempR5 <= tempR3;
					 
					 rSR   <= tempR4 + tempR5;
					end
			 endcase	
			end
		
	assign SL = rSL;
	assign SM = rSM;
	assign SR = rSR;
	
endmodule