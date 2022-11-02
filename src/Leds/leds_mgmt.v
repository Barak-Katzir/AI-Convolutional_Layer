`timescale 1ns/1ps



module leds_mgmt
(
        rst_n		,  // Reset Neg
        clk,             // Clk
        addr		,  // Address
	   wr_en,		//Write enable
	   select,
        data_in,
        leds_out,
		  sevseg0,
		  sevseg1,
		  sevseg2,
		  sevseg3,
		  sevseg4,
		  sevseg5
    );
	 
	 input rst_n;
	 input clk;
	 input [31:0] addr;
	 input wr_en;
	 input select;
	 input [31:0] data_in;
	 output [9:0] leds_out;
	 output [3:0] sevseg0;
	 output [3:0] sevseg1;
	 output [3:0] sevseg2;
	 output [3:0] sevseg3;
	 output [3:0] sevseg4;
	 output [3:0] sevseg5;

	 
	 reg [9:0] leds_out;
	 reg [3:0] sevseg0;
	 reg [3:0] sevseg1;
	 reg [3:0] sevseg2;
	 reg [3:0] sevseg3;
	 reg [3:0] sevseg4;
	 reg [3:0] sevseg5;
	 
	 wire sevseg_le;
	 assign sevseg_le = (wr_en & select & (addr[4:2] == 3'b101));
 
	always @(posedge clk or negedge rst_n)
		if(~rst_n) begin
			leds_out <=10'h000;
			sevseg0 <= 4'b0;
			sevseg1 <= 4'b0;
			sevseg2 <= 4'b0; 
			sevseg3 <= 4'b0;
			sevseg4 <= 4'b0;
			sevseg5 <= 4'b0;
		end
		else begin
			leds_out <= (wr_en & select & (addr[4:2] == 3'b100)) ? data_in[9:0] : leds_out;
			sevseg0 <= sevseg_le ? data_in[3:0] : sevseg0;
			sevseg1 <= sevseg_le ? data_in[7:4] : sevseg1;
			sevseg2 <= sevseg_le ? data_in[11:8] : sevseg2;
			sevseg3 <= sevseg_le ? data_in[15:12] : sevseg3;
			sevseg4 <= sevseg_le ? data_in[19:16] : sevseg4;
			sevseg5 <= sevseg_le ? data_in[23:20] : sevseg5;
		end
	 
endmodule