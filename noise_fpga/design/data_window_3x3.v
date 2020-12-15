`timescale 1ns / 1ps
module data_window_3x3(
    input clk,
    input rst,
    input [7:0] din,
	
    output [7:0] dout1_1,
    output [7:0] dout1_2,
    output [7:0] dout1_3,
    output [7:0] dout2_1,
    output [7:0] dout2_2,
    output [7:0] dout2_3,
    output [7:0] dout3_1,
    output [7:0] dout3_2,
    output [7:0] dout3_3,
	output reg [17:0] raddr
    //output reg data_valid,
    //output reg frame_complete
    );


//**************  wire and registers of FIFO buffer *************//
	wire [7:0] fout1;
	wire [7:0] fout2;
	
	reg rd_en1;
	reg rd_en2;
	
	reg wr_en1;
	reg wr_en2;
	
	wire [7:0] din1;
	wire [7:0] din2;
	
	reg [10:0] cnt1;
	reg [10:0] cnt2;
//******************* FIFO control unit  ************************//
	
	always @(posedge clk or negedge rst)
		if(!rst)
			begin
			 wr_en1<=0;
			 rd_en1<=0;
			 wr_en2<=0;
			 rd_en2<=0;
			 raddr<=0;
			 cnt1<=0;
			 cnt2<=0;
			end
		else
			begin
			 raddr<=raddr+1;
			 wr_en1<=1;
			 if(cnt1<511)
			 	begin
			 	 cnt1<=cnt1+1;
			 	 rd_en1<=0;
			 	end
			 else
			 	begin
			 	 rd_en1<=1;
			 	 wr_en2<=1;
			 	 if(cnt2<511)
			 		begin
			 		 cnt2<=cnt2+1;
			 		 rd_en2<=0;
			 		end
			 	 else
			 		rd_en2<=1;
			 	end
			end
	
	assign din1=din;
	assign din2=fout1;
	
	
//*****************  FIFO line buffer ***************************//

	FIFO512 line_buff1 (
		.clock (clk),	
		.data 	(din1),
		.rdreq (rd_en1),	
		.wrreq (wr_en1),
		.q 	(fout1)		
	);
	
	
		FIFO512 line_buff2 (
		.clock (clk),	
		.data (din2),
		.rdreq (rd_en2),	
		.wrreq (wr_en2),
		.q 	(fout2)		
	);
	//
	 shift_register_3 sr1(.clk(clk),.din(fout2),.rst(rst),.dout0(dout1_3),.dout1(dout1_2),.dout2(dout1_1));
	 //
	 shift_register_3 sr2(.clk(clk),.din(fout1),.rst(rst),.dout0(dout2_3),.dout1(dout2_2),.dout2(dout2_1));
	 //
	 shift_register_3 sr3(.clk(clk),.din(din),.rst(rst),.dout0(dout3_3),.dout1(dout3_2),.dout2(dout3_1));

endmodule
