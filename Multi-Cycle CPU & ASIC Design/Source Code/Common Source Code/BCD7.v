`timescale 1ns / 1ps
module BCD7(clk,reset,AN,Cathode,dgt1,dgt2,dgt3,dgt4);
input clk,reset;
input [3:0] dgt1,dgt2,dgt3,dgt4;
output [3:0] AN;
output [7:0] Cathode;
reg [3:0] AN;
reg [7:0] Cathode;
reg [3:0] single_dgt;
reg [1:0] anode_cnt;


always @(posedge clk or posedge reset)
begin
    if(reset)
        anode_cnt<=0;
    else
        begin
        if(anode_cnt==2'b11)
            anode_cnt<=2'b00;
        else
            anode_cnt<=anode_cnt+1;
        end
end

always @(*)
begin
Cathode[7]<=1'b1;
case(anode_cnt)
        2'b00:begin
            AN<=4'b0111;
            single_dgt<=dgt4;
            //Cathode[7]<=1'b1;
            end
        2'b01:begin
            AN<=4'b1011;
            single_dgt<=dgt3;
            //Cathode[7]<=1'b1;
            end
        2'b10:begin
            AN<=4'b1101;
            single_dgt<=dgt2;
            //Cathode[7]<=1'b0;
            end
        2'b11:begin
            AN<=4'b1110;
            single_dgt<=dgt1;
            //Cathode[7]<=1'b1;
            end      
        endcase
case(single_dgt)
	4'b0000:Cathode[6:0]<=7'b1000000;   //0
    4'b0001:Cathode[6:0]<=7'b1111001;   //1
    4'b0010:Cathode[6:0]<=7'b0100100;   //2
    4'b0011:Cathode[6:0]<=7'b0110000;   //3
    4'b0100:Cathode[6:0]<=7'b0011001;   //4
    4'b0101:Cathode[6:0]<=7'b0010010;   //5
    4'b0110:Cathode[6:0]<=7'b0000010;   //6
    4'b0111:Cathode[6:0]<=7'b1111000;   //7
    4'b1000:Cathode[6:0]<=7'b0000000;   //8
    4'b1001:Cathode[6:0]<=7'b0010000;   //9
    
    4'b1010:Cathode[6:0]<=7'b0001000;   //a
    4'b1011:Cathode[6:0]<=7'b0000011;   //b
    4'b1100:Cathode[6:0]<=7'b1000110;   //c
    4'b1101:Cathode[6:0]<=7'b0100001;   //d
    4'b1110:Cathode[6:0]<=7'b0000110;   //e
    4'b1111:Cathode[6:0]<=7'b0001110;   //f
    default: Cathode[6:0]<= 7'b1111111;
endcase
end
endmodule
