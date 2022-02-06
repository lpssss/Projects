`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2021 20:42:52
// Design Name: 
// Module Name: ASIC
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


module ASIC(
input clk,
input reset,
output reg [15:0] display_result
    );
parameter MAX_CAPACITY=60;
parameter MAX_ITEMNUM=60;
reg [31:0] InputDataWeight[MAX_ITEMNUM-1:0];
reg [31:0] InputDataValue[MAX_ITEMNUM-1:0];
reg [31:0] cache_ptr[MAX_CAPACITY-1:0];
reg [31:0] outerloopVar;
reg [31:0] innerloopVar;
reg [31:0] itemNum;
reg [31:0] totalWeight;
reg [31:0] curItemWeight;
reg [31:0] curItemValue;
integer i;

parameter IDLE=2'b00;
parameter OUTERLOOP=2'b01;
parameter INNERLOOP=2'b10;
parameter DISPLAYRESULT=2'b11;
reg [1:0] curState;


always @(posedge clk or posedge reset)
begin
    if(reset)   
    begin
        curState<=IDLE;
        
                
       for(i=0;i<MAX_CAPACITY;i=i+1)
           cache_ptr[i]<=32'd0;
        
        display_result<=32'd0;    
        outerloopVar<=32'd0;
        innerloopVar<=32'd0;
        totalWeight<=32'd20;
        itemNum<=32'd20;
        curItemWeight<=32'd0;
        curItemValue<=32'd0;
        
        InputDataWeight[0]<=32'd2;
        InputDataWeight[1]<=32'd5;
        InputDataWeight[2]<=32'd10;
        InputDataWeight[3]<=32'd9;
        InputDataWeight[4]<=32'd3;
        InputDataWeight[5]<=32'd6;
        InputDataWeight[6]<=32'd2;
        InputDataWeight[7]<=32'd2;
        InputDataWeight[8]<=32'd6;
        InputDataWeight[9]<=32'd8;
        InputDataWeight[10]<=32'd2;
        InputDataWeight[11]<=32'd3;
        InputDataWeight[12]<=32'd3;
        InputDataWeight[13]<=32'd2;
        InputDataWeight[14]<=32'd9;
        InputDataWeight[15]<=32'd8;
        InputDataWeight[16]<=32'd2;
        InputDataWeight[17]<=32'd10;
        InputDataWeight[18]<=32'd8;
        InputDataWeight[19]<=32'd6;
        
        InputDataValue[0]<=32'd8;
        InputDataValue[1]<=32'd1;
        InputDataValue[2]<=32'd5;
        InputDataValue[3]<=32'd9;
        InputDataValue[4]<=32'd5;
        InputDataValue[5]<=32'd6;
        InputDataValue[6]<=32'd8;
        InputDataValue[7]<=32'd2;
        InputDataValue[8]<=32'd3;
        InputDataValue[9]<=32'd7;
        InputDataValue[10]<=32'd5;
        InputDataValue[11]<=32'd4;
        InputDataValue[12]<=32'd3;
        InputDataValue[13]<=32'd7;
        InputDataValue[14]<=32'd6;
        InputDataValue[15]<=32'd7;
        InputDataValue[16]<=32'd9;
        InputDataValue[17]<=32'd3;
        InputDataValue[18]<=32'd10;
        InputDataValue[19]<=32'd5;

    end    
    else
    begin
        case(curState)
        IDLE: 
        begin
        outerloopVar<=32'd0;    
        curState<=OUTERLOOP;
        end
        
        OUTERLOOP:
        begin
            innerloopVar<=totalWeight;
            curItemWeight<=InputDataWeight[outerloopVar];
            curItemValue<=InputDataValue[outerloopVar];
            outerloopVar<=outerloopVar+32'd1;
            if(outerloopVar>=itemNum)
                curState<=DISPLAYRESULT;
            else
                curState<=INNERLOOP;
        end
        
        INNERLOOP:
         begin
         innerloopVar<=innerloopVar-32'd1;
         
         if(innerloopVar==32'hffffffff)
            curState<=OUTERLOOP;
         else
         begin
         if(innerloopVar>=curItemWeight)
            cache_ptr[innerloopVar]<=(cache_ptr[innerloopVar]>cache_ptr[innerloopVar-curItemWeight]+curItemValue)?cache_ptr[innerloopVar]:cache_ptr[innerloopVar-curItemWeight]+curItemValue;
            curState<=INNERLOOP;
         end
        end
        
        DISPLAYRESULT: 
        begin
        display_result<=cache_ptr[totalWeight][15:0];
        curState<=DISPLAYRESULT;
        end
        endcase
        
    end

end

endmodule
