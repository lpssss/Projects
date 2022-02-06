`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2021 21:49:46
// Design Name: 
// Module Name: test_asic
// Project Name: 
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


module test_asic(

    );
    
    reg reset;
        reg clk;
        
        ASIC ASIC_1(.reset(reset), .clk(clk));
        
        initial begin
            reset = 1;
            clk = 1;
            #100 reset = 0;
        end
        
        always #50 clk = ~clk;
endmodule
