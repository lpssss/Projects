module top(
sysclk,BTNU,
AN,Cathodes,leds
    );
    
input sysclk;
input BTNU;
output [3:0] AN;
output [7:0] Cathodes;
output [7:0] leds;


wire clk_1k;
wire clk_10Hz;


wire [15:0] bcd_input;

clk_gen clk_gen(.clk(sysclk),.reset(BTNU),.clk_1K(clk_1k));
//clk_gen_10Hz clk_gen_10Hz(.clk(sysclk),.reset(BTNU),.clk_10Hz(clk_10Hz));

ASIC ASIC_1(.reset(BTNU), .clk(sysclk),.display_result(bcd_input));

BCD7 BCD7(.clk(clk_1k),.reset(BTNU),.AN(AN),.Cathode(Cathodes),.dgt1(bcd_input[3:0]),.dgt2(bcd_input[7:4]),.dgt3(bcd_input[11:8]),.dgt4(bcd_input[15:12]));

assign leds={6'd0,ASIC_1.curState};
endmodule
