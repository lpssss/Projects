`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Class: Fundamentals of Digital Logic and Processor
// Designer: Shulin Zeng
// 
// Create Date: 2021/04/30
// Design Name: MultiCycleCPU
// Module Name: MultiCycleCPU
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

module MultiCycleCPU (reset, clk);
    //Input Clock Signals
    input reset;
    input clk;

    //--------------Your code below-----------------------
    
    //control signal
    wire i_PCWrite_s;
    wire i_PCWriteCond_s;       //only for beq
    wire i_MemRead_s;
    wire i_MemWrite_s;
    wire i_IRWrite_s;
    wire i_RegWrite_s;
    wire i_ExtOp_s;             //'0'-zero extension, '1'-signed extension
    wire i_LuiOp_s;             //for lui instruction
    
    wire Sign_s;                // deternime if the operators (reg_a,reg_b) are signed or unsigned
    wire [3:0] i_ALUOp_s;       //signal to control 'alu control'
    wire [4:0] o_alu_conf_s;    //signal to control alu
       
    //special signal    
    wire i_final_PCWrite_s;
    
    //mux control signal
    wire i_IorD_s;
    wire i_MemtoReg_s;
    wire [1:0] i_PCSource_s;
    wire [1:0] i_RegDst_s;
    wire [1:0] i_ALUSrcA_s;
    wire [1:0] i_ALUSrcB_s;
    wire i_CondType_s;
    
    
    //PC input, output
    reg [31:0] mux_PC_input;
    wire [31:0] PC_output;   
    
    //Memory input, output
    reg [31:0] mem_inputaddr;
    wire [31:0] mem_inputdata;      // for writing memory
    wire [31:0] mem_outputdata;     // output of memory, can be instruction or data
    
    //Instruction Register Input, Output
    wire [5:0] o_Opcode_s;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] shamt;
    wire [5:0] funct;
    
    //MDR Input, Output
    wire [31:0] MDR_output;
    
    //Register File Input, Ouput
    reg [4:0] mux_regwrite_addr;
    reg [31:0] mux_regwrite_data;
    wire [31:0] reg_data1;
    wire [31:0] reg_data2;   // output of register file
    
    //Temporary Register A and B Input,Output
    wire [31:0] reg_a;
    wire [31:0] reg_b;   // output of temp reg a and b
    
    //Immediate Process Input, Output
    wire [31:0] Imm_out;
    wire [31:0] ImmShift_out;
    
    //ALU Input, Output
    reg [31:0] mux_ALU_inputA;
    reg [31:0] mux_ALU_inputB;
    wire [31:0] ALUOut;
    wire ALUOut_zero;           //if result == 0, ALUOut_zero=1
    
    //Temporary Register ALU Input, Output
   wire [31:0] ALUOut_Reg;
   
   //upwards name referencing
   wire [15:0] o_t1;
   wire [15:0] o_t0;
   wire [15:0] o_v0;
   
   //initialize all components
   PC PC(.reset(reset), .clk(clk),.PCWrite(i_final_PCWrite_s),.PC_i(mux_PC_input),.PC_o(PC_output));
   
   InstAndDataMemory Memory(.reset(reset), .clk(clk),.Address(mem_inputaddr),.Write_data(mem_inputdata), .MemRead(i_MemRead_s), .MemWrite(i_MemWrite_s), .Mem_data(mem_outputdata));
   
   InstReg InstReg(.reset(reset), .clk(clk), .IRWrite(i_IRWrite_s), .Instruction(mem_outputdata), .OpCode(o_Opcode_s), .rs(rs), .rt(rt), .rd(rd), .Shamt(shamt), .Funct(funct));
   
   Controller Controller(.reset(reset), .clk(clk), .OpCode(o_Opcode_s), .Funct(funct), 
               .PCWrite(i_PCWrite_s), .PCWriteCond(i_PCWriteCond_s), .IorD(i_IorD_s), .MemWrite(i_MemWrite_s), .MemRead(i_MemRead_s),
               .IRWrite(i_IRWrite_s), .MemtoReg(i_MemtoReg_s), .RegDst(i_RegDst_s), .RegWrite(i_RegWrite_s), .ExtOp(i_ExtOp_s), .LuiOp(i_LuiOp_s),
               .ALUSrcA(i_ALUSrcA_s), .ALUSrcB(i_ALUSrcB_s), .ALUOp(i_ALUOp_s), .PCSource(i_PCSource_s),.CondType(i_CondType_s)); 
               
    RegisterFile RegisterFile(.reset(reset), .clk(clk), .RegWrite(i_RegWrite_s), .Read_register1(rs), .Read_register2(rt), .Write_register(mux_regwrite_addr),
                                        .Write_data(mux_regwrite_data), .Read_data1(reg_data1), .Read_data2(reg_data2));
                                        
    RegTemp MDR(.reset(reset),.clk(clk),.Data_i(mem_outputdata),.Data_o(MDR_output));
    RegTemp RegA(.reset(reset),.clk(clk),.Data_i(reg_data1),.Data_o(reg_a));
    RegTemp RegB(.reset(reset),.clk(clk),.Data_i(reg_data2),.Data_o(reg_b));
    RegTemp ALUOutReg(.reset(reset),.clk(clk),.Data_i(ALUOut),.Data_o(ALUOut_Reg));   
           
    ImmProcess ImmProcess(.ExtOp(i_ExtOp_s), .LuiOp(i_LuiOp_s), .Immediate({rd,shamt,funct}), .ImmExtOut(Imm_out), .ImmExtShift(ImmShift_out));
                     
    ALUControl ALUControl(.ALUOp(i_ALUOp_s), .Funct(funct), .ALUConf(o_alu_conf_s), .Sign(Sign_s)); //Sign signal created here
    
    ALU ALU(.ALUConf(o_alu_conf_s),.Sign(Sign_s),.In1(mux_ALU_inputA),.In2(mux_ALU_inputB),.Zero(ALUOut_zero),.Result(ALUOut));
       
                    
   //logic for special PC Write signal
   assign i_final_PCWrite_s=i_CondType_s? (i_PCWrite_s || (i_PCWriteCond_s && ~ALUOut_zero)):(i_PCWrite_s || (i_PCWriteCond_s && ALUOut_zero));  //bne beq
   
   //connect regb and memory input
   assign mem_inputdata=reg_b;
   
   //upwards name referencing
   assign o_t1=RegisterFile.RF_data[9][15:0];
   assign o_t0=RegisterFile.RF_data[8][15:0];
   assign o_v0=RegisterFile.RF_data[2][15:0];
    
   //**** MUX in Datapath***
   //Note: only PC+4 uses ALUOut, other outputs use ALUOut_Reg
   
    //mux for pc input
    always@(*)
    begin
    case (i_PCSource_s)
    2'b00 :mux_PC_input<=ALUOut;      //for PC+4
    2'b01 :mux_PC_input<=reg_a;        // R[rs]
    2'b10 :mux_PC_input<={PC_output[31:28],rs,rt,rd,shamt,funct,2'b00};         
    2'b11: mux_PC_input<=ALUOut_Reg;
    endcase
    end
    
    //mux for memory address input
    always@(*)
    begin
    case (i_IorD_s)
    1'b0    :mem_inputaddr<=PC_output;
    1'b1    :mem_inputaddr<=ALUOut_Reg;
    endcase
    end
    
    //mux for register file address input
    always@(*)
    begin
    case (i_RegDst_s)
        2'b00   : mux_regwrite_addr<= rt;    
        2'b01   : mux_regwrite_addr<= rd;        
        2'b10   : mux_regwrite_addr<= 5'd31;         //$ra 
        default : mux_regwrite_addr<=5'd0 ;          //dont care 
        endcase
    end
    
    //mux for register file data input
    always@(*)
    begin
    case (i_MemtoReg_s)
    1'b0    : mux_regwrite_data<= MDR_output;       // for lw
    1'b1    : mux_regwrite_data<= ALUOut_Reg;        
    endcase
    end
    
    //mux for ALU two inputs
    always@(*)
    begin
    case (i_ALUSrcA_s) 
    2'b00   : mux_ALU_inputA<=reg_a;
    2'b01   : mux_ALU_inputA<={28'd0,shamt};
    2'b10   : mux_ALU_inputA<=PC_output;
    2'b11   : mux_ALU_inputA<=32'd0;
    
    endcase

    case (i_ALUSrcB_s) 
    2'b00   : mux_ALU_inputB<=reg_b;
    2'b01   : mux_ALU_inputB<=32'd4;
    2'b10   : mux_ALU_inputB<=Imm_out;
    2'b11   : mux_ALU_inputB<=ImmShift_out;
    endcase
    end

    //--------------Your code above-----------------------
endmodule