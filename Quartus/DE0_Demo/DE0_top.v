// --------------------------------------------------------------------
// Copyright (c) 2009 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	DE0 Button Debounce
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
// Ver:| Author : Allen Wang  | Mod. Date : 2010/07/27 | Changes Made:
// --------------------------------------------------------------------

//`include "../../src/top.v"


module DE0_top
	(
		////////////////////	Clock Input	 	////////////////////	 
		CLOCK_50,						//	50 MHz
		CLOCK_50_2,						//	50 MHz
		////////////////////	Push Button		////////////////////
		ORG_BUTTON,						//	Pushbutton[2:0]
		////////////////////	DPDT Switch		////////////////////
		SW,								//	Toggle Switch[9:0]
		////////////////////	7-SEG Dispaly	////////////////////
		HEX0_D,							//	Seven Segment Digit 0
		HEX1_D,							//	Seven Segment Digit 1
		HEX2_D,							//	Seven Segment Digit 2
		HEX3_D,							//	Seven Segment Digit 3
		HEX4_D,							//	Seven Segment Digit 4
		HEX5_D,							//	Seven Segment Digit 5
		LEDG							//	LED Red[9:0]
	);

////////////////////////	Clock Input	 	////////////////////////
input			CLOCK_50;				//	50 MHz
input			CLOCK_50_2;				//	50 MHz
////////////////////////	Push Button		////////////////////////
input	[3:0]	ORG_BUTTON;				//	Pushbutton[2:0]
////////////////////////	DPDT Switch		////////////////////////
input	[9:0]	SW;						//	Toggle Switch[9:0]
////////////////////////	7-SEG Dispaly	////////////////////////
output	[6:0]	HEX0_D;					//	Seven Segment Digit 0
output	[6:0]	HEX1_D;					//	Seven Segment Digit 1
output	[6:0]	HEX2_D;					//	Seven Segment Digit 2
output	[6:0]	HEX3_D;					//	Seven Segment Digit 3
output	[6:0]	HEX4_D;					//	Seven Segment Digit 4
output	[6:0]	HEX5_D;					//	Seven Segment Digit 5

////////////////////////////	LED		////////////////////////////
output 	[9:0]	LEDG;					//	LED Red[9:0]





//==================================================================
//  REG/WIRE declarations
//==================================================================
wire	[3:0]	ORG_BUTTON;         		// Button 

wire            reset_n;        		// Reset
wire            BUTTON[0:2];		// Button after debounce

wire    		counter_1;      		// Counter for Button[1]
wire    		counter_2;      		// Counter for Button[2]

wire    [3:0] 	 iDIG_0;        		// 7SEG 0 
wire    [3:0] 	 iDIG_1;         		// 7SEG 1
wire    [3:0]   iDIG_2;
wire    [3:0]   iDIG_3;
wire    [3:0]   iDIG_4;
wire    [3:0]   iDIG_5;
wire    [3:0] 	 iDIG_0_o;        		// 7SEG 0 
wire    [3:0] 	 iDIG_1_o;         		// 7SEG 1
wire    [3:0]   iDIG_2_o;
wire    [3:0]   iDIG_3_o;
wire    [3:0]   iDIG_4_o;
wire    [3:0]   iDIG_5_o;

reg       		out_BUTTON_1;   		// Button1 Register output
reg       		out_BUTTON_2;   		// Button2 Register output

reg            virtual_clk;       // Virtual clock to slow the processor
wire           clock_to_core;
wire 	[15:0]	ctr;

reg [21:0] count_reg = 0;
reg out_10hz = 0;
//==================================================================
//  Structural coding
//==================================================================

PLL PLL_instance(
	.inclk0(CLOCK_50),
	.c0(PLL_1MHzclock));


// This is BUTTON[0] Debounce Circuit //
button_debouncer	button_debouncer_inst0(
	.clk     (PLL_1MHzclock),
	.rst_n   (1'b1),
	.data_in (ORG_BUTTON[0]),
	.data_out(BUTTON[0])			
	);
	
// This is BUTTON[1] Debounce Circuit //
button_debouncer	button_debouncer_inst1(
	.clk     (PLL_1MHzclock),
	.rst_n   (1'b1),
	.data_in (ORG_BUTTON[1]),
	.data_out(BUTTON[1])			
	);
	
// This is BUTTON[2] Debounce Circuit //
button_debouncer	button_debouncer_inst2(
	.clk     (PLL_1MHzclock),
	.rst_n   (1'b1),
	.data_in (ORG_BUTTON[2]),
	.data_out(BUTTON[2])			
	);

// This is SEG0 Display//
SEG7_LUT	SEG0(
				 .oSEG   (HEX0_D),
				 .oSEG_DP(),
				 .iDIG   (iDIG_0)
				 );
				 
// This is SEG1 Display//
SEG7_LUT	SEG1(
				 .oSEG   (HEX1_D),
				 .oSEG_DP(),
				 .iDIG   (iDIG_1)
				 );
				 
// This is SEG2 Display//
SEG7_LUT	SEG2(
				 .oSEG   (HEX2_D),
				 .oSEG_DP(),
				 .iDIG   (iDIG_2)
				 );
				 
// This is SEG3 Display//				 
SEG7_LUT	SEG3(
				 .oSEG   (HEX3_D),
				 .oSEG_DP(),
				 .iDIG   (iDIG_3)
				  );	
				  
// This is SEG3 Display//				 
SEG7_LUT	SEG4(
				 .oSEG   (HEX4_D),
				 .oSEG_DP(),
				 .iDIG   (iDIG_4)
				  );
				  
				  // This is SEG3 Display//				 
SEG7_LUT	SEG5(
				 .oSEG   (HEX5_D),
				 .oSEG_DP(),
				 .iDIG   (iDIG_5)
				  );


`ifdef CUSTOM_DEFINE
		  parameter ADDR_WIDTH = `MEM_ADDR_WIDTH;
		  parameter I_ADDR_WIDTH = `I_MEM_ADDR_WIDTH;
        parameter DATA_WIDTH = `REG_DATA_WIDTH;
        parameter TRANSFER_WIDTH = `MEM_TRANSFER_WIDTH;
`else
		  parameter ADDR_WIDTH = 10;
		  parameter I_ADDR_WIDTH = 15;
        parameter DATA_WIDTH = 32;
        parameter TRANSFER_WIDTH = 4;
`endif

    wire we_mem_data;
    wire [ADDR_WIDTH-1 : 0] addr_mem_data;
    wire [DATA_WIDTH-1 : 0] val_mem_data_write;
    wire [DATA_WIDTH-1 : 0] val_mem_data_read;
	 wire [DATA_WIDTH-1 : 0] val_mem_data_read_ram;
    wire [I_ADDR_WIDTH-1 : 0] addr_mem_prog;
	 //wire [ADDR_WIDTH-1 : 0] addr_mem_prog;
    wire [DATA_WIDTH-1 : 0] val_mem_prog;
    wire  [TRANSFER_WIDTH-1:0] write_transfer;
	 wire PLL_1MHzclock;
	 wire ai_accel_select;
	 wire [31:0] ai_accel_data_out;


assign val_mem_data_read = ai_accel_select ? ai_accel_data_out : val_mem_data_read_ram;

//assign val_mem_data_read = val_mem_data_read_ram;

core core_de0(
        .clk (clock_to_core),
        .rst_n (reset_n),
        .we_mem_data_o (we_mem_data),
        .addr_mem_data_o (addr_mem_data),
        .val_mem_data_read_i (val_mem_data_read),
        .val_mem_data_write_o (val_mem_data_write),
        .addr_mem_prog_o (addr_mem_prog),
        .val_mem_prog_i (val_mem_prog),
        .write_transfer_mem_data_o (write_transfer)
    );
//set LOAD_MEMS to true to load mems

//`define MEM

`ifdef MEM

ram mem_data_de0 (
        .clock		(clock_to_core)	,
        .wren			(we_mem_data)	,  // Write Enable
        .address		(addr_mem_data[ADDR_WIDTH-1 : 2])	,  // Address
        .data	(val_mem_data_write),  //  Data in
        .byteena (write_transfer), // write Byte mask
		  .q   (val_mem_data_read_ram)  //data out 
    );

`else

dataMem mem_data_de0 (
        .rst_n		(reset_n)			,  // Reset Neg
        .clk		(clock_to_core)	,
        .we			(we_mem_data)	,  // Write Enable
        .addr		(addr_mem_data)	,  // Address
        .data_in	(val_mem_data_write),  //  Data in
        .data_out   (val_mem_data_read_ram),  //data out
        .write_transfer_i (write_transfer) // write Byte mask
    );
`endif

	

`ifdef MEM

prog mem_prog_de0 (
	.address(addr_mem_prog[ADDR_WIDTH-1 : 2]),
	.clock (clock_to_core),
	.q (val_mem_prog)
	);
	 
`else
progMem mem_prog_de0 (
        .rst_n (reset_n)		,  // Reset Neg
        .clk (clock_to_core),             // Clk
        .addr (addr_mem_prog)		,  // Address
        .data_out (val_mem_prog)	   // Output Data
    );

`endif


assign iDIG_0    = SW[2] ? iDIG_0_o : addr_mem_prog[3:0];
assign iDIG_1    = SW[2] ? iDIG_1_o : addr_mem_prog[7:4];
assign iDIG_2    = SW[2] ? iDIG_2_o : addr_mem_prog[11:8]; 
assign iDIG_3    = SW[2] ? iDIG_3_o : addr_mem_prog[I_ADDR_WIDTH-1:12];
assign iDIG_4    = SW[2] ? iDIG_4_o : 4'h0;
assign iDIG_5    = SW[2] ? iDIG_5_o : clock_to_core ? 4'b1 : 4'b0;

assign reset_n   = BUTTON[0]; 			 		 
assign clock_to_core = SW[0] ?  (SW[1])? out_10hz:PLL_1MHzclock :virtual_clk;  // SW[0] ? CLOCK_50:PLL_1MHzclock;  //

//====================================================================
// After debounce output with register
//====================================================================
always @ (posedge PLL_1MHzclock )
	begin
		out_BUTTON_1 <= BUTTON[1];
		out_BUTTON_2 <= BUTTON[2];
	end

	
always @ (negedge out_BUTTON_2 )
	begin
		if (virtual_clk) virtual_clk = 1'b0;
		else virtual_clk = 1'b1;
	end

`define LEDS_ADDR_START 32'h010
`define LEDS_ADDR_LAST  32'h014
wire leds_select;

assign leds_select = (addr_mem_data>=`LEDS_ADDR_START) & (addr_mem_data<=`LEDS_ADDR_LAST);

leds_mgmt leds_mgmt_display
(
        .rst_n(reset_n)		,
        .clk(clock_to_core),
        .addr(addr_mem_data),
		  .wr_en(we_mem_data),
		  .select(leds_select),
		  .data_in(val_mem_data_write),
        .leds_out(LEDG),
		  .sevseg0(iDIG_0_o),
		  .sevseg1(iDIG_1_o),
		  .sevseg2(iDIG_2_o),
		  .sevseg3(iDIG_3_o),
		  .sevseg4(iDIG_4_o),
		  .sevseg5(iDIG_5_o)
    );

// generate 100 Hz from 50 MHz



always @(posedge PLL_1MHzclock or negedge reset_n) begin
    if (!reset_n) begin
        count_reg <= 0;
        out_10hz <= 0;
    end else begin
        if (count_reg < 599999) begin
            count_reg <= count_reg + 1;
        end else begin
            count_reg <= 0;
            out_10hz <= ~out_10hz;
        end
    end
end


`define AI_ADDR_START 32'h020
`define AI_ADDR_LAST  32'h060
assign ai_accel_select = (addr_mem_data>=`AI_ADDR_START) & (addr_mem_data<=`AI_ADDR_LAST);


ai_accel ai_accelerator
(
        .rst_n(reset_n),
        .clk(clock_to_core),
        .addr(addr_mem_data),
		  .data_in(val_mem_data_write),
        .data_out(ai_accel_data_out),
		  .accel_select(ai_accel_select),
		  .wr_en(we_mem_data),
		  .ctr(ctr)
    );
endmodule