`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Fundamentals of Digital Logic and Processor
// Designer: Shulin Zeng
// 
// Create Date: 2021/04/30
// Design Name: MultiCycleCPU
// Module Name: Controller
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


module Controller(reset, clk, OpCode, Funct, 
                PCWrite, PCWriteCond, IorD, MemWrite, MemRead,
                IRWrite, MemtoReg, RegDst, RegWrite, ExtOp, LuiOp,
                ALUSrcA, ALUSrcB, ALUOp, PCSource, CondType);
//Input Clock Signals
input reset;
input clk;
//Input Signals
input  [5:0] OpCode;
input  [5:0] Funct;
//Output Control Signals
output reg PCWrite;
output reg PCWriteCond;
output reg IorD;
output reg MemWrite;
output reg MemRead;
output reg IRWrite;
output reg MemtoReg;
output reg [1:0] RegDst;
output reg RegWrite;
output reg ExtOp;
output reg LuiOp;
output reg [1:0] ALUSrcA;
output reg [1:0] ALUSrcB;
output reg [3:0] ALUOp;
output reg [1:0] PCSource;
output reg CondType;
      
//--------------Your code below-----------------------
reg [2:0] state;    //current state (cpu in which period)
parameter sIF=3'b000;    //instruction fetch stage
parameter sID=3'b001;    //instruction decode stage 
parameter EX=3'b010;
parameter WB_and_Mem=3'b011;
parameter WB_lw=3'b100;

    
always @(posedge clk or posedge reset)
    begin
    if(reset)
    begin
        state<=sIF;
    end

    else
    begin
         case(state)
         sIF:
         begin
             state<=sID;
         end

         sID:
         begin
             state<=EX;
         end

         EX:
         begin
            if(OpCode==6'h08 || OpCode==6'h09 ||  OpCode==6'h0c || OpCode==6'h0a || OpCode==6'h0b ||    //I type(5)
                OpCode==6'h23 || OpCode==6'h2b ||  OpCode==6'h0f ||                                     //sw, lw, lui                                                  
                (OpCode==6'h00 && (Funct==6'h20 || Funct==6'h21 || Funct==6'h22 ||                      // R type I, R type II
                Funct==6'h23 || Funct==6'h24 || Funct==6'h25 ||
                Funct==6'h26 || Funct==6'h27 || Funct==6'h2a ||
                Funct==6'h2b || Funct==6'h2f ||
                Funct==6'h02 || Funct==6'h00 || Funct==6'h03 )))                               
            begin
                state<=WB_and_Mem;
            end

            else
            begin
                state<=sIF;
            end
         end

         WB_and_Mem:
         begin
            if(OpCode==6'h23)      //lw
            begin
                 state<=WB_lw;
            end

            else
            begin
                state<=sIF;
            end
         end
           
         WB_lw:
         begin
             state<=sIF;
         end 

         default: state<=sIF;
         endcase
    end
end
    // ...

always @(*)
begin
        case (state)
        sIF:
        begin
            //important signal
            PCWrite<=1'b1;
            MemRead<=1'b1;
            IRWrite<=1'b1;

            //important mux signal
            IorD<=1'b0;
            ALUSrcA<=2'b10;         //PC
            ALUSrcB<=2'b01;         //4
            PCSource<=2'b00;        //PC+4
         
            //reset control signal 
            PCWriteCond<=1'b0;
            MemWrite<=1'b0;
            RegWrite<=1'b0;
            ExtOp<=1'b1;
            LuiOp<=1'b0;

            //reset mux 
            MemtoReg<=1'b0;
            RegDst<=2'b00;
            CondType<=1'b0;
        end 

        sID:
        begin
            //important common signal
            ALUSrcA<=2'b10;          //PC
            ALUSrcB<=2'b11;         //ImmShift
            PCSource<=2'b11;

            //reset previous used (IF) control signal
            PCWrite<=1'b0;
            MemRead<=1'b0;
            IRWrite<=1'b0;
         
            //unused control signal
            PCWriteCond<=1'b0;
            MemWrite<=1'b0;
            ExtOp<=1'b1;
            LuiOp<=1'b0;

            //unused mux control signal
            IorD<=1'b0;
            CondType<=1'b0;
         
            //special ID section for jal and jalr

            if(OpCode==6'h03)                       //for jal 
            begin
                RegWrite<=1'b1;
                RegDst<=2'b10;
                MemtoReg<=1'b1;
            end

            else if(OpCode==6'h00 && Funct==6'h09)  //for jalr
            begin
                RegWrite<=1'b1;
                RegDst<=2'b01;
                MemtoReg<=1'b1;
            end

            else        //other
            begin
                RegWrite<=1'b0;
                RegDst<=2'b00;
                MemtoReg<=1'b0;
            end
        end

        EX:
        begin
            if(OpCode==6'h08 || OpCode==6'h09 ||
                OpCode==6'h0a || OpCode==6'h0b || 
                OpCode==6'h23 || OpCode==6'h2b)    //I type I, lw, sw
            begin
                //important signal
                ALUSrcA<=2'b00;
                ALUSrcB<=2'b10;

                //unused signal
                PCWrite<=1'b0;
                PCWriteCond<=1'b0;
                PCSource<=2'b00;
                LuiOp<=1'b0;
                ExtOp<=1'b1;
                CondType<=1'b0;         
            end

            else if (OpCode==6'h0c)
            begin
                 //important signal
                ALUSrcA<=2'b00;
                ALUSrcB<=2'b10;
                ExtOp<=1'b0;

                //unused signal
                PCWrite<=1'b0;
                PCWriteCond<=1'b0;
                PCSource<=2'b00;
                LuiOp<=1'b0; 
                CondType<=1'b0;                 
            end
            
            else if(OpCode==6'h02 || OpCode==6'h03)  //j, jal
            begin
                //important signal
                PCWrite<=1'b1;
                PCSource<=2'b10;

                //unused signal
                PCWriteCond<=1'b0;
                ALUSrcA<=2'b00;          
                ALUSrcB<=2'b00;
                LuiOp<=1'b0;
                ExtOp<=1'b1;
                CondType<=1'b0;                                                                
            end

            else if(OpCode==6'h04)      //beq
            begin
                //important signal
                PCWriteCond<=1'b1; 
                PCSource<=2'b11;
                CondType<=1'b0;

                //unused signal
                PCWrite<=1'b0;            
                ALUSrcA<=2'b00;
                ALUSrcB<=2'b00;
                LuiOp<=1'b0;
                ExtOp<=1'b1;             
            end
            
            else if(OpCode==6'h05)      //bne
            begin
                //important signal
                PCWriteCond<=1'b1; 
                PCSource<=2'b11;
                CondType<=1'b1;

                //unused signal
                PCWrite<=1'b0;            
                ALUSrcA<=2'b00;
                ALUSrcB<=2'b00;
                LuiOp<=1'b0;
                ExtOp<=1'b1;             
            end

            else if(OpCode==6'h0f)      //lui
            begin
                //important signal
                ALUSrcA<=2'b11;
                ALUSrcB<=2'b10;
                LuiOp<=1'b1;

                //unused signal
                PCWrite<=1'b0;
                PCWriteCond<=1'b0;
                PCSource<=2'b00;
                ExtOp<=1'b1;
                CondType<=1'b0;            
            end
                     
            else    //OPcode == 0
            begin
                if(Funct==6'h20 || Funct==6'h21 || Funct==6'h22 ||          // R type 1
                    Funct==6'h23 || Funct==6'h24 || Funct==6'h25 ||
                    Funct==6'h26 || Funct==6'h27 || Funct==6'h2a ||
                    Funct==6'h2f || Funct==6'h2b)
                begin
                    //important signal
                    ALUSrcA<=2'b00;
                    ALUSrcB<=2'b00;

                    //unused signal
                    PCWrite<=1'b0; 
                    PCWriteCond<=1'b0;
                    PCSource<=2'b00;
                    LuiOp<=1'b0;
                    ExtOp<=1'b1;
                    CondType<=1'b0;          
                end
                         
                else if(Funct==6'h02 || Funct==6'h00 || Funct==6'h03)       // sll,srl,sra
                begin
                    //important signal
                    ALUSrcA<=2'b01;
                    ALUSrcB<=2'b00;

                    //unused signal
                    PCWrite<=1'b0;
                    PCWriteCond<=1'b0;
                    PCSource<=2'b11;
                    LuiOp<=1'b0;
                    ExtOp<=1'b1; 
                    CondType<=1'b0;    
                end

                else if(Funct==6'h08 ||  Funct==6'h09)     //jr, jalr
                begin      
                    //important signal  
                    PCWrite<=1'b1;
                    PCSource<=2'b01;

                    //unused signal
                    PCWriteCond<=1'b0;
                    ALUSrcA<=2'b10;    
                    ALUSrcB<=2'b11;
                    LuiOp<=1'b0;
                    ExtOp<=1'b1;
                    CondType<=1'b0;                                                             
                end

                else 
                begin
                    PCWrite<=1'b0;
                    PCWriteCond<=1'b0;
                    ALUSrcA<=2'b00;
                    ALUSrcB<=2'b00; 
                    PCSource<=2'b00;
                    LuiOp<=1'b0;
                    ExtOp<=1'b1;
                    CondType<=1'b0;
                end
            end 

            //important common control signal
            RegWrite<=1'b0;

            //unused commnon mux signal
            IorD<=1'b0;
            RegDst<=2'b00;
            MemtoReg<=1'b0;

            //unused control signal
            MemWrite<=1'b0;
            MemRead<=1'b0;
            IRWrite<=1'b0;           
        end

        WB_and_Mem: 
        begin
            if(OpCode==6'd0 && (Funct==6'h20 || Funct==6'h21 || Funct==6'h22 ||             // R type 1 and Rtype 2
                Funct==6'h23 || Funct==6'h24 || Funct==6'h25 ||
                Funct==6'h26 || Funct==6'h27 || Funct==6'h2a ||
                Funct==6'h2b || Funct==6'h02 || Funct==6'h00 || Funct==6'h2f || Funct==6'h03))
            begin
                //important signal
                RegWrite<=1'b1;
                MemtoReg<=1'b1;                              
                RegDst<=2'b01;

                //unused signal
                MemWrite<=1'b0;
                MemRead<=1'b0;
                IorD<=1'b0;               
            end

            else if(OpCode==6'h08 || OpCode==6'h09 ||
                    OpCode==6'h0c || OpCode==6'h0a || OpCode==6'h0b || OpCode==6'h0f)       //I type and lui
            begin
                //important signal
                RegWrite<=1'b1;
                MemtoReg<=1'b1;                              
                RegDst<=2'b00;

                //unused signal
                MemWrite<=1'b0;
                MemRead<=1'b0;
                IorD<=1'b0;                                         
            end

            else if(OpCode==6'h23)      //lw
            begin
                //important signal
                IorD<=1'b1; 
                MemRead<=1'b1;

                //unused signal
                MemWrite<=1'b0;              
                RegWrite<=1'b0;                   
                MemtoReg<=1'b0;
                RegDst<=2'b00;       
            end
                     
            else if(OpCode==6'h2b)      //sw
            begin
                //important signal
                IorD<=1'b1;
                MemWrite<=1'b1;

                //unused signal             
                MemRead<=1'b0;
                RegWrite<=1'b0;                       
                MemtoReg<=1'b0;
                RegDst<=2'b00;
            end

            else
            begin
                MemWrite<=1'b0;
                MemRead<=1'b0;
                RegWrite<=1'b0;
                IorD<=1'b0;
                MemtoReg<=1'b0;
                RegDst<=2'b00;
            end
            
            //unused control signal
            PCWrite<=1'b0;
            IRWrite<=1'b0;
            PCWriteCond<=1'b0;
            ExtOp<=1'b1;
            LuiOp<=1'b0;
            ALUSrcA<=2'b00;
            ALUSrcB<=2'b00;
            PCSource<=2'b00;  
            CondType<=1'b0; 
        end 

        WB_lw:
        begin
            //important signal
            RegWrite<=1'b1;
            RegDst<=2'b00;
            MemtoReg<=1'b0;

            //unused signal
            PCWrite<=1'b0;
            PCWriteCond<=1'b0;
            IorD<=1'b0;
            MemWrite<=1'b0;
            MemRead<=1'b0;
            IRWrite<=1'b0;
            ExtOp<=1'b1;
            LuiOp<=1'b0;                
            ALUSrcA<=2'b00;
            ALUSrcB<=2'b00;
            PCSource<=2'b00;
            CondType<=1'b0;
        end

        default: 
        begin
            PCWrite<=1'b0;
            PCWriteCond<=1'b0;
            IorD<=1'b0;
            MemWrite<=1'b0;
            MemRead<=1'b0;
            IRWrite<=1'b0;
            MemtoReg<=1'b0;
            RegDst<=2'b00;
            RegWrite<=1'b0;
            ExtOp<=1'b1;        //default sign extension
            LuiOp<=1'b0;
            ALUSrcA<=2'b00;
            ALUSrcB<=2'b00;
            PCSource<=2'b00;
            CondType<=1'b0;
        end
        endcase
    
end

    //--------------Your code above-----------------------


    //ALUOp
    always @(*) begin        ALUOp[3] = OpCode[0];
        if (state == sIF || state == sID) begin
            ALUOp[2:0] = 3'b000;    // (beq and PC+4, use add)
        end else if (OpCode == 6'h00) begin 
            ALUOp[2:0] = 3'b010;    //Opcode all zero, determine in ALU COntrol
        end else if (OpCode == 6'h04 || OpCode==6'h05) begin
            ALUOp[2:0] = 3'b001;    //beq, use subtract
        end else if (OpCode == 6'h0c) begin
            ALUOp[2:0] = 3'b100;    //andi, use and
        end else if (OpCode == 6'h0a || OpCode == 6'h0b) begin
            ALUOp[2:0] = 3'b101;    //slti and sltiu use slt
        end else begin
            ALUOp[2:0] = 3'b000;    //add
        end
    end

endmodule