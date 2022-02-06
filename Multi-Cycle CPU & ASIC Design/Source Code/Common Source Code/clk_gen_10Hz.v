module clk_gen_10Hz(
    clk, 
    reset, 
    clk_10Hz//,
    //cnt
);

input           clk;    //sysclk 100MHz
input           reset;
output          clk_10Hz;


reg             clk_10Hz;
reg     [31:0]  count;

parameter CNT=32'd5000000;

//for testing purposes
//output cnt;
//parameter CNT = 16'd4;
//parameter CNT = 16'd2;
//reg [2:0] cnt;


always @(posedge clk or posedge reset)
begin
    if(reset) begin
        clk_10Hz <= 1'b0;    //reset clk_1K and count
        count <= 32'd0;
        //cnt<=1'b0;
    end
    else begin
        count <= (count==CNT-32'd1) ? 32'd0 : count + 32'd1; //reset when count reaches 100000
        clk_10Hz <= (count==32'd0) ? ~clk_10Hz : clk_10Hz;    //generate a 1kHz clock (if base clock is 100MHz)
        
        //cnt <= (cnt==CNT-16'd1) ? 16'd0 : cnt + 16'd1;
        //clk_1K <= (cnt==16'd0) ? ~clk_1K : clk_1K;

    end
end

endmodule
