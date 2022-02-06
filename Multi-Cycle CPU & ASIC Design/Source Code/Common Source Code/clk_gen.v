module clk_gen(
    clk, 
    reset, 
    clk_1K//,
    //cnt
);

input           clk;    //sysclk 100MHz
input           reset;
output          clk_1K;


reg             clk_1K;
reg     [16:0]  count;

parameter CNT=16'd50000;

//for testing purposes
//output cnt;
//parameter CNT = 16'd4;
//parameter CNT = 16'd2;
//reg [2:0] cnt;


always @(posedge clk or posedge reset)
begin
    if(reset) begin
        clk_1K <= 1'b0;    //reset clk_1K and count
        count <= 17'd0;
        //cnt<=1'b0;
    end
    else begin
        count <= (count==CNT-16'd1) ? 16'd0 : count + 16'd1; //reset when count reaches 100000
        clk_1K <= (count==16'd0) ? ~clk_1K : clk_1K;    //generate a 1kHz clock (if base clock is 100MHz)
        
        //cnt <= (cnt==CNT-16'd1) ? 16'd0 : cnt + 16'd1;
        //clk_1K <= (cnt==16'd0) ? ~clk_1K : clk_1K;

    end
end

endmodule
