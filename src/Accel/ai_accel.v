`timescale 1ns/1ps

module multiplier
(
	a,b,R0
);

	input [23:0] a;
	input [23:0] b;
	output [23:0] R0;
	
	wire [15:0] mid_res_0;
	wire [15:0] mid_res_1;
	wire [15:0] mid_res_2;
	
	assign mid_res_0 = a[7:0] * b[7:0];
	assign R0[7:0] = |mid_res_0[15:8] ? 8'hff : mid_res_0[7:0];
	assign mid_res_1 = a[15:8] * b[15:8];
	assign R0[15:8] = |mid_res_1[15:8] ? 8'hff : mid_res_1[7:0];
	assign mid_res_2 = a[23:16] * b[23:16];	
	assign R0[23:16] = |mid_res_2[15:8] ? 8'hff : mid_res_2[7:0];
endmodule

module Adder
(
	R0_A,result
);

	input [23:0] R0_A;
	output [7:0] result;
	
	assign result[7:0]= R0_A[7:0] + R0_A[15:8] + R0_A[23:16];
endmodule

module Normal
(
	res_reg, res_normal, var, avg_out
);

	input [31:0] res_reg;
	output [31:0] res_normal;
	output [18:0] var;
	output [8:0] avg_out;
	
	wire [35:0] sub_val;
	wire [10:0] avg_val;
	wire [35:0] var_val_01;
	wire [35:0] var_val_23;
	wire [20:0] add_var_val;
	assign avg_val = {3'b0,res_reg[7:0]} + {3'b0,res_reg[15:8]} + {3'b0, res_reg[23:16]} + {3'b0, res_reg[31:24]};
	assign sub_val[8:0] = res_reg[7:0] - avg_val[10:2];
	assign res_normal [7:0] = (sub_val[8] == 1'b1) ? 8'h00 : (res_reg[7:0] - avg_val[10:2]);
	assign sub_val[17:9] = res_reg[15:8] - avg_val[10:2];
	assign res_normal [15:8] = (sub_val[17] == 1'b1) ? 8'h00 : (res_reg[15:8] - avg_val[10:2]);
	assign sub_val[26:18] = res_reg[23:16] - avg_val[10:2];
	assign res_normal [23:16] = (sub_val[26] == 1'b1) ? 8'h00 : (res_reg[23:16] - avg_val[10:2]);
	assign sub_val[35:27] = res_reg[31:24] - avg_val[10:2];
	assign res_normal [31:24] = (sub_val[35] == 1'b1) ? 8'h00 : (res_reg[31:24] - avg_val[10:2]);
	
	
	wire [17:0] mul_var_0;
	wire [17:0] mul_var_1;
	wire [17:0] mul_var_2;
	wire [17:0] mul_var_3;
	
	wire [8:0] calc_neg0;
	wire [8:0] calc_neg1;
	wire [8:0] calc_neg2;
	wire [8:0] calc_neg3;
	
	assign calc_neg0 = avg_val[10:2] > {1'b0,res_reg[7:0]};

	assign calc_neg1 = avg_val[10:2] > {1'b0,res_reg[15:8]};

	assign calc_neg2 = avg_val[10:2] > {1'b0,res_reg[23:16]};

	assign calc_neg3 = avg_val[10:2] > {1'b0,res_reg[31:24]};


	wire [8:0] mul0_in1;
	wire [8:0] mul1_in1;
	wire [8:0] mul2_in1;
	wire [8:0] mul3_in1;
	assign mul0_in1 = calc_neg0 ? avg_val[10:2] - {1'b0,res_reg[7:0]} : {1'b0,res_reg[7:0]} - avg_val[10:2];
	assign mul1_in1 = calc_neg1 ? avg_val[10:2] - {1'b0,res_reg[15:8]} : {1'b0,res_reg[15:8]} - avg_val[10:2];
	assign mul2_in1 = calc_neg2 ? avg_val[10:2] - {1'b0,res_reg[23:16]} : {1'b0,res_reg[23:16]} - avg_val[10:2];
	assign mul3_in1 = calc_neg3 ? avg_val[10:2] - {1'b0,res_reg[31:24]} : {1'b0,res_reg[31:24]} - avg_val[10:2];
	
	multiplier mul_sqr0 (.a(mul0_in1), .b(mul0_in1), .R0(mul_var_0 [17:0]));
	multiplier mul_sqr1 (.a(mul1_in1), .b(mul1_in1), .R0(mul_var_1 [17:0]));
	multiplier mul_sqr2 (.a(mul2_in1), .b(mul2_in1), .R0(mul_var_2 [17:0]));
	multiplier mul_sqr3 (.a(mul3_in1), .b(mul3_in1), .R0(mul_var_3 [17:0]));
	
	assign var_val_01 [17:0] = mul_var_0 [17:0];
	assign var_val_01 [35:18] = mul_var_1 [17:0];
	assign var_val_23 [17:0] = mul_var_2 [17:0];
	assign var_val_23 [35:18] = mul_var_3 [17:0];

   assign add_var_val = {3'b0, var_val_01 [17:0]} + {3'b0, var_val_01 [35:18]} + {3'b0, var_val_23 [17:0]} + {3'b0, var_val_23 [35:18]};
	assign var [18:0] = add_var_val [20:2];
	assign avg_out = avg_val [10:2];
	
endmodule


// Module Declaration
module ai_accel
(
        rst_n		,  // Reset Neg
        clk,             // Clk
        addr		,  // Address
		  wr_en,		//Write enable
		  accel_select,
		  data_in,
		  ctr,
        data_out	   // Output Data
    );
	 
	 input rst_n;
	 input clk;
	 input [31:0] addr;
	 input wr_en;
	 input accel_select;
	 input [31:0] data_in;
	 output [31:0] data_out;
	 output [15:0] ctr;
	 
	 
	 reg [31:0] data_out;
 
	 reg go_bit;
	 wire go_bit_in;
	 reg done_bit;
	 wire done_bit_in;

	 reg [15:0] counter;
	 
	 reg [31:0] data_A;
	 reg [31:0] data_B;
	 reg [31:0] data_C;
	 reg [31:0] data_D;
	 reg [31:0] data_E;
	 reg [31:0] data_F;
	 reg [31:0] data_G;
	 wire [31:0] data_R0;
	 wire [23:0] sum_0;
	 wire [23:0] sum_1;
	 wire [23:0] sum_2;
	 wire [23:0] sum_3;
	 wire [31:0] r_out;
	 wire [31:0] r_output;
	 wire [7:0] r_output_last;
	 wire [18:0] r_var;
	 wire [31:0] r_out_org;
	  wire [7:0] r_output_org_last;
	 wire [18:0] calc_var;
	 
//	 reg [7:0] in1, in2;
//	 wire[7:0] out;

	 assign ctr = counter;
	 
	 always @(addr[5:2], data_A, data_B, data_C, data_D, data_E, data_F, data_G, done_bit,r_output,r_avg, r_output_last, r_out_org, r_output_org_last, calc_var, go_bit, counter) begin //mux to display data out
		case(addr[5:2])
		4'b1000: data_out = {done_bit, 30'b0, go_bit};
		4'b1001: data_out = {16'b0, counter}; 
		4'b1010: data_out = data_A;
		4'b1011: data_out = data_B;
		4'b1100: data_out = data_C;
		4'b1101: data_out = data_D;
		4'b1110: data_out = data_E;
		4'b1111: data_out = data_F;
		4'b0000: data_out = data_G;	
		4'b0001: data_out = r_output;
		4'b0010: data_out = r_output_last;
		4'b0011: data_out = r_out_org;
		4'b0100: data_out = r_output_org_last;
		4'b0101: data_out = r_avg;
		4'b0110: data_out = calc_var;
		default: data_out = 32'b0;
		endcase
	 end
	 
	 assign go_bit_in = (wr_en & accel_select & (addr[5:2] == 3'b1000)); //start the process with go bit
	
	 always @(posedge clk or negedge rst_n) //reg to put 1 in go bit
		if(~rst_n) go_bit <= 1'b0;
		else go_bit <=  go_bit_in ? 1'b1 : 1'b0;
		
	 always @(posedge clk or negedge rst_n) //reg for counter 
		if(~rst_n) begin
			counter <=16'b0;
			data_A <= 32'b0;
			data_B <= 32'b0;
			data_C <= 32'b0;
			data_D <= 32'b0;
			data_E <= 32'b0;
			data_F <= 32'b0;
			data_G <= 32'b0;

		end
		else begin
			if (wr_en & accel_select) begin // reg for data in A and reg for data in B
				data_A <= (addr[5:2] == 4'b1010) ? data_in : data_A;
				data_B <= (addr[5:2] == 4'b1011) ? data_in : data_B;
				data_C <= (addr[5:2] == 4'b1100) ? data_in : data_C;
				data_D <= (addr[5:2] == 4'b1101) ? data_in : data_D;
				data_E <= (addr[5:2] == 4'b1110) ? data_in : data_E;
				data_F <= (addr[5:2] == 4'b1111) ? data_in : data_F;
				data_G <= (addr[5:2] == 4'b0000) ? data_in : data_G;

			end
			else begin
				data_A <= data_A;
				data_B <= data_B;
				data_C <= data_C;
				data_D <= data_D;
				data_E <= data_E;
				data_F <= data_F;
				data_G <= data_G;
				
			end
			counter <= go_bit_in? 16'h00 : done_bit_in ? counter : counter +16'h01; //reg for counter
		end
		
	 wire [23:0] data_A0E;
	 wire [23:0] data_B0F;
	 wire [23:0] data_C0G;
	 wire [23:0] data_A1E;
	 wire [23:0] data_B1F;
	 wire [23:0] data_C1G;
	 wire [23:0] data_B0E;
	 wire [23:0] data_C0F;
	 wire [23:0] data_D0G;
	 wire [23:0] data_B1E;
	 wire [23:0] data_C1F;
	 wire [23:0] data_D1G;	 
	 
	 // A[012] * E
	 multiplier mul_A0E(.a(data_A[23:0]), .b(data_E[23:0]), .R0(data_A0E[23:0])); //RA0[0][0] 
	 Adder add_A0E(.R0_A(data_A0E[23:0]), .result(sum_0[7:0]));
	 
	 // B[012] * F
	 multiplier mul_B0F(.a(data_B[23:0]), .b(data_F[23:0]), .R0(data_B0F[23:0])); //RA0[0][0] 
	 Adder add_B0F(.R0_A(data_B0F[23:0]), .result(sum_0[15:8]));
	 
	 // C[012] * G
	 multiplier mul_C0G(.a(data_C[23:0]), .b(data_G[23:0]), .R0(data_C0G[23:0])); //RA0[0][0] 
	 Adder add_C0G(.R0_A(data_C0G[23:0]), .result(sum_0[23:16]));

	 Adder add_00(.R0_A(sum_0[23:0]), .result(r_out[7:0]));
	 //assign data_R0 = 32'b0;
	 //assign sum = 32'b0;	
	
	 // A[123] * E
	 multiplier mul_A1E(.a(data_A[31:8]), .b(data_E[23:0]), .R0(data_A1E[23:0])); //RA0[0][0] 
	 Adder add_A1E(.R0_A(data_A1E[23:0]), .result(sum_1[7:0]));
	 
	 // B[123] * F
	 multiplier mul_B1F(.a(data_B[31:8]), .b(data_F[23:0]), .R0(data_B1F[23:0])); //RA0[0][0] 
	 Adder add_B1F(.R0_A(data_B1F[23:0]), .result(sum_1[15:8]));
	 
	 // C[123] * G
	 multiplier mul_C1G(.a(data_C[31:8]), .b(data_G[23:0]), .R0(data_C1G[23:0])); //RA0[0][0] 
	 Adder add_C1G(.R0_A(data_C1G[23:0]), .result(sum_1[23:16]));
	 
	 
	 Adder add_01(.R0_A(sum_1[23:0]), .result(r_out[15:8]));
	 //assign data_R0 = 32'b0;
	 //assign sum = 32'b0;	
	 
	 // B[012] * E
	 multiplier mul_B0E(.a(data_B[23:0]), .b(data_E[23:0]), .R0(data_B0E[23:0])); //RA0[0][0] 
	 Adder add_B0E(.R0_A(data_B0E[23:0]), .result(sum_2[7:0]));
	 
	 // C[012] * F
	 multiplier mul_C0F(.a(data_C[23:0]), .b(data_F[23:0]), .R0(data_C0F[23:0])); //RA0[0][0] 
	 Adder add_C0F(.R0_A(data_C0F[23:0]), .result(sum_2[15:8]));
	 
	 // D[012] * G
	 multiplier mul_D0G(.a(data_D[23:0]), .b(data_G[23:0]), .R0(data_D0G[23:0])); //RA0[0][0] 
	 Adder add_D0G(.R0_A(data_D0G[23:0]), .result(sum_2[23:16]));

	 Adder add_10(.R0_A(sum_2[23:0]), .result(r_out[23:16]));
	 
	 // B[123] * E
	 multiplier mul_B1E(.a(data_B[31:8]), .b(data_E[23:0]), .R0(data_B1E[23:0])); //RA0[0][0] 
	 Adder add_B1E(.R0_A(data_B1E[23:0]), .result(sum_3[7:0]));
	 
	 // C[123] * F
	 multiplier mul_C1F(.a(data_C[31:8]), .b(data_F[23:0]), .R0(data_C1F[23:0])); //RA0[0][0] 
	 Adder add_C1F(.R0_A(data_C1F[23:0]), .result(sum_3[15:8]));
	 
	 // D[123] * G
	 multiplier mul_D1G(.a(data_D[31:8]), .b(data_G[23:0]), .R0(data_D1G[23:0])); //RA0[0][0] 
	 Adder add_D1G(.R0_A(data_D1G[23:0]), .result(sum_3[23:16]));
	 
	 Adder add_11(.R0_A(sum_3[23:0]), .result(r_out[31:24]));
	 
	 wire [31:0] r_out_normal;
	 wire [8:0] avg_val_out;
	 Normal norm (.res_reg(r_out[31:0]), .res_normal(r_out_normal[31:0]), .var(r_var[18:0]), .avg_out(avg_val_out[8:0]));
	 
	 reg [31:0] result;
	 reg [31:0] result_org;
	 reg [18:0] result_var;
							 
	 always @(posedge clk or negedge rst_n) //reg for the result finale
		if(~rst_n) result <=32'h0;
		else result <= r_out_normal;
		
	always @(posedge clk or negedge rst_n) //reg for the result finale
		if(~rst_n) result_org <=32'h0;
		else result_org <= r_out;
	 	 
	always @(posedge clk or negedge rst_n) //reg for the result finale
		if(~rst_n) result_var <=19'h0;
		else result_var <= r_var;
		
	reg [8:0] avg;
	
	always @(posedge clk or negedge rst_n) //reg for the result finale
		if(~rst_n) avg <=9'h0;
		else avg <= avg_val_out;
		
	wire [8:0] r_avg;
	
	assign r_avg = avg;
	 	 
	 assign r_output = result; //connect the wire data_c and result
	 
	 assign r_out_org = result_org;
	 
	 assign calc_var = result_var;
	 
	 assign r_output_last = result[31:24];	 
	 
	 assign r_output_org_last = r_out_org[31:24];
	 
	 assign done_bit_in = (counter == 16'd1); //put the flag 1 in done bit after 4 clock cycle that we calculate in the mux at '122'
	 
	 always @(posedge clk or negedge rst_n) //reg that send 1 to done bit and tells us that we finished
		if(~rst_n) done_bit <= 1'b0;
		else done_bit <= go_bit_in ? 1'b0 : done_bit_in;
	 
endmodule