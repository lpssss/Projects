`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Fundamentals of Digital Logic and Processor
// Designer: Shulin Zeng
// 
// Create Date: 2021/04/30
// Design Name: MultiCycleCPU
// Module Name: InstAndDataMemory
// Project Name: Multi-cycle-cpu
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module InstAndDataMemory(reset, clk, Address, Write_data, MemRead, MemWrite, Mem_data);
	//Input Clock Signals
	input reset;
	input clk;
	//Input Data Signals
	input [31:0] Address;
	input [31:0] Write_data;
	//Input Control Signals
	input MemRead;
	input MemWrite;
	//Output Data
	output [31:0] Mem_data;
	
	parameter RAM_SIZE = 512;
	parameter RAM_SIZE_BIT = 9;
	parameter RAM_INST_SIZE = 64;
	
	reg [31:0] RAM_data[RAM_SIZE - 1: 0];

	//read data
	assign Mem_data = MemRead? RAM_data[Address[RAM_SIZE_BIT + 1:2]]: 32'h00000000;
	
	//write data
	integer i;
	always @(posedge reset or posedge clk) begin
		if (reset) begin
		    // init instruction memory
            RAM_data[9'd0] <= 32'h2010_0100;    //addi
            RAM_data[9'd1] <= 32'h2011_01a8;    //addi                   
            RAM_data[9'd2] <= 32'h8e08_0000;    //lw
            RAM_data[9'd3] <= 32'h8e09_0004;    //lw
            RAM_data[9'd4] <= 32'h2210_0008;    //addi
            RAM_data[9'd5] <= 32'h0000_5020;    //add
                    
            //outer loop 
            RAM_data[9'd6] <= 32'h0149_582a;    //slt          
            RAM_data[9'd7] <= 32'h1160_001c;    //beq
            RAM_data[9'd8] <= 32'h8e0c_0000;    //lw
            RAM_data[9'd9] <= 32'h8e0d_0004;    //lw
            RAM_data[9'd10] <= 32'h2210_0008;   //addi
            RAM_data[9'd11] <= 32'h214a_0001;   //addi
            RAM_data[9'd12] <= 32'h0100_7020;   //add
                    
           //inner loop
            RAM_data[9'd13] <= 32'h01c0_582a;   //slt          
            RAM_data[9'd14] <= 32'h1560_0014;   //bne
            RAM_data[9'd15] <= 32'h01cc_582a;   //slt          
            RAM_data[9'd16] <= 32'h1560_0010;   //bne
            RAM_data[9'd17] <= 32'h000e_c880;   //sll
            RAM_data[9'd18] <= 32'h0239_8820;   //add
            RAM_data[9'd19] <= 32'h8e2f_0000;   //lw
            RAM_data[9'd20] <= 32'h0239_8822;   //sub
            RAM_data[9'd21] <= 32'h01cc_5822;   //sub
                    
            RAM_data[9'd22] <= 32'h000b_c880;   //sll
            RAM_data[9'd23] <= 32'h0239_8820;   //add
            RAM_data[9'd24] <= 32'h8e38_0000;   //lw
            RAM_data[9'd25] <= 32'h0239_8822;   //sub
                    
            RAM_data[9'd26] <= 32'h030d_c020;   //add
            RAM_data[9'd27] <= 32'h030f_582a;   //slt
            RAM_data[9'd28] <= 32'h1560_0004;   //bne
            RAM_data[9'd29] <= 32'h000e_c880;   //sll
            RAM_data[9'd30] <= 32'h0239_8820;   //add
            RAM_data[9'd31] <= 32'hae38_0000;   //sw
            RAM_data[9'd32] <= 32'h0239_8822;   //sub
            RAM_data[9'd33] <= 32'h21ce_ffff;   //addi
            RAM_data[9'd34] <= {6'h02, 26'd13}; //j
            RAM_data[9'd35] <= {6'h02, 26'd6};  //j
                    
            RAM_data[9'd36] <= 32'h0008_c880;   //sll
            RAM_data[9'd37] <= 32'h0239_8820;   //add
            RAM_data[9'd38] <= 32'h8e22_0000;   //lw
                    
            //infinite loop
            RAM_data[9'd39] <= 32'h1000_ffff;   //beq
            
            //knapsack test set
            RAM_data[9'd64]<=32'd20;
            RAM_data[9'd65]<=32'd20;
            
            RAM_data[9'd66]<=32'd2;
            RAM_data[9'd68]<=32'd5;
            RAM_data[9'd70]<=32'd10;
            RAM_data[9'd72]<=32'd9;
            RAM_data[9'd74]<=32'd3;
            RAM_data[9'd76]<=32'd6;
            RAM_data[9'd78]<=32'd2;
            RAM_data[9'd80]<=32'd2;
            RAM_data[9'd82]<=32'd6;
            RAM_data[9'd84]<=32'd8;
            RAM_data[9'd86]<=32'd2;
            RAM_data[9'd88]<=32'd3;
            RAM_data[9'd90]<=32'd3;
            RAM_data[9'd92]<=32'd2;
            RAM_data[9'd94]<=32'd9;
            RAM_data[9'd96]<=32'd8;
            RAM_data[9'd98]<=32'd2;
            RAM_data[9'd100]<=32'd10;
            RAM_data[9'd102]<=32'd8;
            RAM_data[9'd104]<=32'd6;
            
            RAM_data[9'd67]<=32'd8;
            RAM_data[9'd69]<=32'd1;
            RAM_data[9'd71]<=32'd5;
            RAM_data[9'd73]<=32'd9;
            RAM_data[9'd75]<=32'd5;
            RAM_data[9'd77]<=32'd6;
            RAM_data[9'd79]<=32'd8;
            RAM_data[9'd81]<=32'd2;
            RAM_data[9'd83]<=32'd3;
            RAM_data[9'd85]<=32'd7;
            RAM_data[9'd87]<=32'd5;
            RAM_data[9'd89]<=32'd4;
            RAM_data[9'd91]<=32'd3;
            RAM_data[9'd93]<=32'd7;
            RAM_data[9'd95]<=32'd6;
            RAM_data[9'd97]<=32'd7;
            RAM_data[9'd99]<=32'd9;
            RAM_data[9'd101]<=32'd3;
            RAM_data[9'd103]<=32'd10;
            RAM_data[9'd105]<=32'd5;
            
            //reset data memory		  
			for (i = 106; i < RAM_SIZE; i = i + 1)
				RAM_data[i] <= 32'h00000000;
		end else if (MemWrite) begin
			RAM_data[Address[RAM_SIZE_BIT + 1:2]] <= Write_data;
		end
	end

endmodule
