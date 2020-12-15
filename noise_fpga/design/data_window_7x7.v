`timescale 1ns / 1ps
module data_window_7x7(
    input clk,
    input rst,
    input [7:0] din,
	 // data_window
    output [7:0] dout1_1, output [7:0] dout1_2, output [7:0] dout1_3, output [7:0] dout1_4,
    output [7:0] dout1_5, output [7:0] dout1_6, output [7:0] dout1_7,
	 
	output [7:0] dout2_1, output [7:0] dout2_2, output [7:0] dout2_3, output [7:0] dout2_4,
    output [7:0] dout2_5, output [7:0] dout2_6, output [7:0] dout2_7,
	 
	output [7:0] dout3_1, output [7:0] dout3_2, output [7:0] dout3_3, output [7:0] dout3_4,
    output [7:0] dout3_5, output [7:0] dout3_6, output [7:0] dout3_7,
	 
	output [7:0] dout4_1, output [7:0] dout4_2, output [7:0] dout4_3, output [7:0] dout4_4,
    output [7:0] dout4_5, output [7:0] dout4_6, output [7:0] dout4_7,
	 
	output [7:0] dout5_1, output [7:0] dout5_2, output [7:0] dout5_3, output [7:0] dout5_4,
    output [7:0] dout5_5, output [7:0] dout5_6, output [7:0] dout5_7,
	 
	output [7:0] dout6_1, output [7:0] dout6_2, output [7:0] dout6_3, output [7:0] dout6_4,
    output [7:0] dout6_5, output [7:0] dout6_6, output [7:0] dout6_7,
	 
	output [7:0] dout7_1, output [7:0] dout7_2, output [7:0] dout7_3, output [7:0] dout7_4,
    output [7:0] dout7_5, output [7:0] dout7_6, output [7:0] dout7_7,
	 
	output	reg data_valid
    );


//**************  wire and registers of FIFO buffer *************//
	wire [7:0] fout1;
	wire [7:0] fout2;
	wire [7:0] fout3;
	wire [7:0] fout4;
	wire [7:0] fout5;
	wire [7:0] fout6;
	
	reg rd_en1;
	reg rd_en2;
	reg rd_en3;
	reg rd_en4;
	reg rd_en5;
	reg rd_en6;
	
	reg wr_en1;
	reg wr_en2;
	reg wr_en3;
	reg wr_en4;
	reg wr_en5;
	reg wr_en6;
	
	wire [7:0] din1;
	wire [7:0] din2;
	wire [7:0] din3;
	wire [7:0] din4;
	wire [7:0] din5;
	wire [7:0] din6;
	
	reg [10:0] cnt1;
	reg [10:0] cnt2;
	reg [10:0] cnt3;
	reg [10:0] cnt4;
	reg [10:0] cnt5;
	reg [10:0] cnt6;
	
	reg [17:0] raddr;
//******************* FIFO control unit  ************************//
	
	always @(posedge clk or negedge rst)
	begin
		if(!rst)
		begin
			wr_en1<=0;
			wr_en2<=0;
			wr_en3<=0;
			wr_en4<=0;
			wr_en5<=0;
			wr_en6<=0;
			
			rd_en1<=0;
			rd_en2<=0;
			rd_en3<=0;
			rd_en4<=0;
			rd_en5<=0;
			rd_en6<=0;

			raddr<=0;
			
			cnt1<=0;
			cnt2<=0;
			cnt3<=0;
			cnt4<=0;
			cnt5<=0;
			cnt6<=0;
			
			data_valid <= 0;
		end
		else
			begin
				if(raddr < 3078)
					data_valid <= 0;
				else
					data_valid <= 1'b1;
				
				raddr<=raddr+1;
				wr_en1<=1;
				if(cnt1<511)
				begin
					cnt1<=cnt1+1;
					rd_en1<=0;
				end
				else
				begin
					rd_en1<=1;			//enable FIFO2
					wr_en2<=1;
					if(cnt2<511)
					begin
						cnt2<=cnt2+1;
						rd_en2<=0;
					end
					else
					begin
						rd_en2<=1;		//enable FIFO3
						wr_en3<=1;
						if(cnt3<511)
						begin
							cnt3<=cnt3+1;
							rd_en3<=0;
						end
						else
						begin
							rd_en3<=1;	//enable FIFO4
							wr_en4<=1;
							if(cnt4<511)
							begin
								cnt4<=cnt4+1;
								rd_en4<=0;
							end
							else
							begin
								rd_en4<=1;
								wr_en5<=1; //enable FIFO5
								if(cnt5<511)
								begin
									cnt5<=cnt5+1;
									rd_en5<=0;
								end
								else
								begin
									rd_en5<=1;
									wr_en6<=1; //enable FIFO6
									if(cnt6<511)
									begin
										cnt6<=cnt6+1;
										rd_en6<=0;
									end
									else
										rd_en6<=1;
								end
							end
						end
					end
				end
			end
	end
	assign din1=din;
	assign din2=fout1;
	assign din3=fout2;
	assign din4=fout3;
	assign din5=fout4;
	assign din6=fout5;
	
	
//*****************  FIFO line buffer ***************************//

	FIFO512 line_buff1 (
		.clock	(clk), 
		.data	(din1), 
		.wrreq	(wr_en1), 
		.rdreq	(rd_en1), 
		.q		(fout1)
	);
	
	
	FIFO512 line_buff2 (
		.clock	(clk), 
		.data	(din2), 
		.wrreq	(wr_en2), 
		.rdreq	(rd_en2), 
		.q		(fout2) 
	);
	
	FIFO512 line_buff3 (
		.clock	(clk), 
		.data	(din3), 
		.wrreq	(wr_en3), 
		.rdreq	(rd_en3), 
		.q		(fout3) 
	);
	
	FIFO512 line_buff4 (
		.clock	(clk), 
		.data	(din4), 
		.wrreq	(wr_en4), 
		.rdreq	(rd_en4), 
		.q		(fout4) 
	);
	
	FIFO512 line_buff5 (
		.clock	(clk), 
		.data	(din5), 
		.wrreq	(wr_en5), 
		.rdreq	(rd_en5), 
		.q		(fout5) 
	);
	
	FIFO512 line_buff6 (
		.clock	(clk), 
		.data	(din6), 
		.wrreq	(wr_en6), 
		.rdreq	(rd_en6), 
		.q		(fout6) 
	);
	
//********************* shift registers *********************//
	shift_register_7 src1 (.clk(clk), .din(fout6), .rst(rst), 
    .dout0(dout1_7), .dout1(dout1_6),.dout2(dout1_5), .dout3(dout1_4), 
    .dout4(dout1_3), .dout5(dout1_2), .dout6(dout1_1)
    );
	
	shift_register_7 src2 (.clk(clk), .din(fout5), .rst(rst), 
    .dout0(dout2_7), .dout1(dout2_6),.dout2(dout2_5), .dout3(dout2_4), 
    .dout4(dout2_3), .dout5(dout2_2), .dout6(dout2_1)
    );
	
	shift_register_7 src3 (.clk(clk), .din(fout4), .rst(rst), 
    .dout0(dout3_7), .dout1(dout3_6),.dout2(dout3_5), .dout3(dout3_4), 
    .dout4(dout3_3), .dout5(dout3_2), .dout6(dout3_1)
    );
	 
	shift_register_7 src4 (.clk(clk), .din(fout3), .rst(rst), 
    .dout0(dout4_7), .dout1(dout4_6),.dout2(dout4_5), .dout3(dout4_4), 
    .dout4(dout4_3), .dout5(dout4_2), .dout6(dout4_1)
    );
	 
	shift_register_7 src5 (.clk(clk), .din(fout2), .rst(rst), 
    .dout0(dout5_7), .dout1(dout5_6),.dout2(dout5_5), .dout3(dout5_4), 
    .dout4(dout5_3), .dout5(dout5_2), .dout6(dout5_1)
    );
	 
	shift_register_7 src6 (.clk(clk), .din(fout1), .rst(rst), 
    .dout0(dout6_7), .dout1(dout6_6),.dout2(dout6_5), .dout3(dout6_4), 
    .dout4(dout6_3), .dout5(dout6_2), .dout6(dout6_1)
    );
	 
	shift_register_7 src7 (.clk(clk), .din(din), .rst(rst), 
    .dout0(dout7_7), .dout1(dout7_6),.dout2(dout7_5), .dout3(dout7_4), 
    .dout4(dout7_3), .dout5(dout7_2), .dout6(dout7_1)
    );

endmodule
