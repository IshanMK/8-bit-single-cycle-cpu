/*
E / 18 / 173 Kasthuripitiya K.A.I.M.
GROUP 19
*/

`include "reg.v"
`include "ALU.v"
`include "dmem.v"

/*------------------------
        CPU MODULE
-------------------------*/

module cpu (PC,INSTRUCTION,CLK,RESET);
    output[31:0] PC;
    input[31:0] INSTRUCTION;
    input CLK,RESET;
    reg[7:0] OPCODE;
    
    wire[7:0] REGOUT1;
    wire[7:0] REGOUT2;
    reg[7:0] IMMEDIATE;
    reg[7:0] OFFSET;
    wire[7:0] READDATA;

    reg[2:0] READREG1;
    reg[2:0] READREG2;
    reg[2:0] WRITEREG;

    wire WRITE_ENABLE;
    wire NEGATIVE_SIGNAL;
    wire IMMEDIATE_SIGNAL;
    wire DMEM_SIGNAL;
    wire BUSYWAIT;
    wire[2:0] ALUOP;
    
    wire[7:0] NEG;
    wire[7:0] MUX1OUT;
    wire[7:0] MUX2OUT;
    wire[7:0] MUX3OUT;
    wire[7:0] ALURESULT;
    wire[7:0] IN;

    wire BRANCH_ENABLE;
    wire JUMP_ENABLE;
    wire[31:0] EXTENDED;
    wire[9:0] SHIFTED;
    
    always @(INSTRUCTION) begin
        OPCODE = INSTRUCTION[31:24];
        WRITEREG = INSTRUCTION[18:16];
        READREG1 = INSTRUCTION[10:8];
        READREG2 = INSTRUCTION[2:0];
        IMMEDIATE = INSTRUCTION[7:0];
        OFFSET = INSTRUCTION[23:16];
    end

    /*Extended the offset*/
    Extend ex(SHIFTED,EXTENDED);

    /*Shift the offset by 2*/
    ShiftLeft sl(OFFSET,SHIFTED);

    /*Module to update the PC*/
    PCAdder pcadder(PC,CLK,RESET,EXTENDED,BRANCH_ENABLE,ZERO,JUMP_ENABLE,BUSYWAIT);

    /*reg_file instantiation*/
    reg_file register(MUX3OUT,REGOUT1,REGOUT2,WRITEREG,READREG1,READREG2,WRITE_ENABLE,CLK,RESET);

    /*Data memory instantiation*/
    data_memory dmem(CLK,RESET,READ,WRITE,ALURESULT,REGOUT1,READDATA,BUSYWAIT);

    /*Control Unit instantiation*/
    ControlUnit cu(PC,BUSYWAIT,OPCODE,WRITE_ENABLE,NEGATIVE_SIGNAL,IMMEDIATE_SIGNAL,DMEM_SIGNAL,BRANCH_ENABLE,JUMP_ENABLE,ALUOP,READ,WRITE);
    
    /*TWOS compliment module instantiation*/
    TWOS_COMPLIMENT f1(REGOUT2,NEG);

    /*MUX NEGATIVE instantiation */
    MUX m1(REGOUT2,NEG,MUX1OUT,NEGATIVE_SIGNAL);

    /*MUX IMMEDIATE instantiation*/
    MUX m2(MUX1OUT,IMMEDIATE,MUX2OUT,IMMEDIATE_SIGNAL);

    /*MUX DMEM instantiation*/
    MUX m3(ALURESULT,READDATA,MUX3OUT,DMEM_SIGNAL);

    /*ALU module instantiation*/
    ALU alu(REGOUT1,MUX2OUT,ALURESULT,ALUOP,ZERO);  
    
endmodule

/*------------------------
TWOS COMPLIMENT MODULE
-------------------------*/

module TWOS_COMPLIMENT(IN,OUT);
    input[7:0] IN;
    output[7:0] OUT;

    assign #1 OUT = ~IN + 1;
  
endmodule

/*------------------------
        MUX MODULE
-------------------------*/

module MUX (IN1,IN2,OUT,SELECT);
    input[7:0] IN1,IN2;
    input SELECT;
    output reg[7:0] OUT;

    always @(IN1,IN2,SELECT) begin
        case(SELECT)                                   // Select selector bit of multiplexer
            /*If SELECT is high it will select IN1*/
            1'b0    :   assign OUT = IN1;

            /*If SELECT is low it will select IN2*/   
            1'b1    :   assign OUT = IN2;

            /*As the default case this will select IN1*/                            
            default :   assign OUT = IN1;                             

        endcase 
    end
endmodule

/*------------------------
    SHIFT - LEFT  MODULE
-------------------------*/

module  ShiftLeft(SHIFT,SHIFTED);
    input[7:0] SHIFT;
    output signed[9:0] SHIFTED;

    /*Shift the offset by 2*/
    assign SHIFTED = SHIFT << 2;
endmodule

/*------------------------
        EXTEND  MODULE
-------------------------*/

module Extend (EXTEND , EXTENDED);
    input[9:0] EXTEND;
    output signed[31:0] EXTENDED;

    /*Extend the bits upto 32 bits*/
    assign EXTENDED = $signed(EXTEND);

endmodule

/*------------------------
    MUX BRANCH MODULE
-------------------------*/

module MUXBRANCH (IN1,IN2,OUT,SELECT);
    input[31:0] IN1,IN2;
    input SELECT;
    output reg signed[31:0] OUT;

    always @(IN1,IN2,SELECT) begin
        case(SELECT)                                   // Select selector bit of multiplexer
            /*If SELECT is high it will select IN1*/
            1'b0    :   OUT = IN1;

            /*If SELECT is low it will select IN2*/   
            1'b1    :   OUT = IN2;

            /*As the default case this will select IN1*/                            
            default :   OUT = IN1;                             

        endcase 
    end
endmodule

/*------------------------
        TRAGET ADDRESS MODULE
-------------------------*/
module TARGET (PCNEXT,SHIFTED_OFFSET,TARGET);
    input[31:0] PCNEXT,SHIFTED_OFFSET;
    output signed[31:0] TARGET ;

    /*GET the targeted address*/
    assign #2 TARGET = PCNEXT + SHIFTED_OFFSET ;
endmodule

/*------------------------
    PCAdder MODULE
-------------------------*/
module PCAdder (PC,CLK,RESET,SHIFTED_OFFSET,BRANCH_ENABLE,ZERO,JUMP_ENABLE,BUSYWAIT);
    input BUSYWAIT;
    input[31:0] SHIFTED_OFFSET;
    input CLK,RESET,BRANCH_ENABLE,JUMP_ENABLE,ZERO;
    wire[31:0] TARGET_ADDRESS ;
    wire[31:0] MUX1OUT,MUX2OUT;
    reg[31:0] temp ;
    output reg[31:0] PC;
    wire BRACH_SELECT;

    /*PC = PC + 4*/
    always @(PC) begin
        //If BUSYWAIT is low PC will be updated
        //if (BUSYWAIT == 1'b0) begin
        #1 temp = PC + 4;
        //end
    end

    and andmodule(BRACH_SELECT,BRANCH_ENABLE,ZERO);

    /*Module instantiation to get the target address*/
    TARGET target(temp,SHIFTED_OFFSET,TARGET_ADDRESS) ;

    /*If the BRANCH_SELECT is high it will select TARGET_ADDRESS otherwise PC + 4*/
    MUXBRANCH mbr1(temp,TARGET_ADDRESS,MUX1OUT,BRANCH_SELECT) ;

    /*If the JUMP_ENABLE is high it will select TARGET_ADDRESS , otherwise PC + 4*/
    MUXBRANCH mbr2(MUX1OUT,TARGET_ADDRESS,MUX2OUT,JUMP_ENABLE) ;

    /*Get the MUX2OUT value to PC*/
    always @(posedge CLK) begin
        if (RESET) begin
            #1 PC = 32'b0;
        end
        else if (!BUSYWAIT) begin
            #1 PC = MUX2OUT;
        end
    end

endmodule
/*------------------------
    ControlUnit MODULE
-------------------------*/

module ControlUnit (PC,BUSYWAIT,OPCODE,WRITE_ENABLE,NEGATIVE_SIGNAL,IMMEDIATE_SIGNAL,DMEM_SIGNAL,BRANCH_ENABLE,JUMP_ENABLE,ALUOP,READ,WRITE);
    input[7:0] OPCODE;
    input[31:0] PC;
    input BUSYWAIT;
    output reg WRITE_ENABLE;
    output reg NEGATIVE_SIGNAL;
    output reg IMMEDIATE_SIGNAL;
    output reg BRANCH_ENABLE;
    output reg JUMP_ENABLE;
    output reg[2:0] ALUOP;
    output reg DMEM_SIGNAL;              //Selector for READDATA vs.ALURESULT
    output reg READ;                    //Control signal to perform a read operation on the provided address
    output reg WRITE;                   //Control signal to perform a write operation on the provided address

    always @(BUSYWAIT) begin
        if(BUSYWAIT == 1'b0) begin
            assign READ = 1'b0;
            assign WRITE = 1'b0;
        end
    end

    always @(OPCODE,PC) begin
        case (OPCODE) 
            /*LOADI Instruction*/
            8'b0000_0000     :       begin
                                        #1
                                          assign ALUOP = 3'b000;
                                          assign NEGATIVE_SIGNAL = 1'b0;
                                          assign IMMEDIATE_SIGNAL = 1'b1;
                                          assign WRITE_ENABLE = 1'b1;
                                          assign BRANCH_ENABLE = 1'b0;
                                          assign JUMP_ENABLE = 1'b0;
                                          assign READ = 1'b0;
                                          assign WRITE = 1'b0;
                                          assign DMEM_SIGNAL = 1'b0;
                                    end

            /*MOV to specific reg*/
            8'b0000_0001    :       begin
                                        #1
                                          assign ALUOP = 3'b000;
                                          assign NEGATIVE_SIGNAL = 1'b0;
                                          assign IMMEDIATE_SIGNAL = 1'b0;
                                          assign WRITE_ENABLE = 1'b1;
                                          assign BRANCH_ENABLE = 1'b0;
                                          assign JUMP_ENABLE = 1'b0;
                                          assign READ = 1'b0;
                                          assign WRITE = 1'b0;
                                          assign DMEM_SIGNAL = 1'b0;
                                    end

            /*ADD instruction*/
            8'b0000_0010    :       begin
                                        #1
                                          assign ALUOP = 3'b001;
                                          assign NEGATIVE_SIGNAL = 1'b0;
                                          assign IMMEDIATE_SIGNAL = 1'b0;
                                          assign WRITE_ENABLE = 1'b1;
                                          assign BRANCH_ENABLE = 1'b0;  
                                          assign JUMP_ENABLE = 1'b0;
                                          assign READ = 1'b0;
                                          assign WRITE = 1'b0;
                                          assign DMEM_SIGNAL = 1'b0;
                                    end
            
            /*SUB instrcution*/
            8'b0000_0011        :   begin
                                        #1
                                          assign ALUOP = 3'b001;
                                          assign NEGATIVE_SIGNAL = 1'b1;
                                          assign IMMEDIATE_SIGNAL = 1'b0;
                                          assign WRITE_ENABLE = 1'b1;
                                          assign BRANCH_ENABLE = 1'b0;  
                                          assign JUMP_ENABLE = 1'b0;
                                          assign READ = 1'b0;
                                          assign WRITE = 1'b0;
                                          assign DMEM_SIGNAL = 1'b0;
                                    end
            
            /*AND instruction*/
            8'b0000_0100    :       begin
                                        #1
                                          assign ALUOP = 3'b010;
                                          assign NEGATIVE_SIGNAL = 1'b0;
                                          assign IMMEDIATE_SIGNAL = 1'b0;
                                          assign WRITE_ENABLE = 1'b1;
                                          assign BRANCH_ENABLE = 1'b0;  
                                          assign JUMP_ENABLE = 1'b0;
                                          assign READ = 1'b0;
                                          assign WRITE = 1'b0;
                                          assign DMEM_SIGNAL = 1'b0;
                                    end

            /*OR instruction*/
            8'b0000_0101    :       begin
                                        #1
                                          assign ALUOP = 3'b011;
                                          assign NEGATIVE_SIGNAL = 1'b0;
                                          assign IMMEDIATE_SIGNAL = 1'b0;
                                          assign WRITE_ENABLE = 1'b1;
                                          assign BRANCH_ENABLE = 1'b0;  
                                          assign JUMP_ENABLE = 1'b0; 
                                          assign READ = 1'b0;
                                          assign WRITE = 1'b0;
                                          assign DMEM_SIGNAL = 1'b0;
                                    end

            /*JUMP instruction*/
            8'b0000_0110         :       begin
                                        #1
                                         assign ALUOP = 3'b000;
                                         assign NEGATIVE_SIGNAL = 1'b0;
                                         assign IMMEDIATE_SIGNAL = 1'b0;
                                         assign WRITE_ENABLE = 1'b0; 
                                         assign BRANCH_ENABLE = 1'b0;
                                         assign JUMP_ENABLE = 1'b1;
                                         assign READ = 1'b0;
                                         assign WRITE = 1'b0;
                                         assign DMEM_SIGNAL = 1'b0;
                                    end
            
            /*BEQ instruction*/
            8'b0000_0111         :       begin
                                        #1
                                         assign ALUOP = 3'b001;
                                         assign NEGATIVE_SIGNAL = 1'b1;
                                         assign IMMEDIATE_SIGNAL = 1'b0;
                                         assign WRITE_ENABLE = 1'b0; 
                                         assign BRANCH_ENABLE = 1'b1;
                                         assign JUMP_ENABLE = 1'b0;
                                         assign READ = 1'b0;
                                         assign WRITE = 1'b0;
                                         assign DMEM_SIGNAL = 1'b0;
                                    end

            /*LWD instruction*/
            8'b0000_1000         :       begin
                                        #1
                                          assign ALUOP = 3'b000;
                                          assign NEGATIVE_SIGNAL = 1'b0;
                                          assign IMMEDIATE_SIGNAL = 1'b0;
                                          assign WRITE_ENABLE = 1'b1;
                                          assign BRANCH_ENABLE = 1'b0;
                                          assign JUMP_ENABLE = 1'b0;
                                          assign READ = 1'b1;
                                          assign WRITE = 1'b0;
                                          assign DMEM_SIGNAL = 1'b1;
                                    end    

            /*LWI Instruction*/
            8'b0000_1001     :       begin
                                        #1
                                          assign ALUOP = 3'b000;
                                          assign NEGATIVE_SIGNAL = 1'b0;
                                          assign IMMEDIATE_SIGNAL = 1'b1;
                                          assign WRITE_ENABLE = 1'b1;
                                          assign BRANCH_ENABLE = 1'b0;
                                          assign JUMP_ENABLE = 1'b0;
                                          assign READ = 1'b1;
                                          assign WRITE = 1'b0;
                                          assign DMEM_SIGNAL = 1'b1;
                                    end

            /*SWD instruction*/
            8'b0000_1010         :       begin
                                        #1
                                          assign ALUOP = 3'b000;
                                          assign NEGATIVE_SIGNAL = 1'b0;
                                          assign IMMEDIATE_SIGNAL = 1'b0;
                                          assign WRITE_ENABLE = 1'b0;
                                          assign BRANCH_ENABLE = 1'b0;
                                          assign JUMP_ENABLE = 1'b0;
                                          assign READ = 1'b0;
                                          assign WRITE = 1'b1;
                                          assign DMEM_SIGNAL = 1'b1;
                                    end  

            /*SWI Instruction*/
            8'b0000_1011     :       begin
                                        #1
                                          assign ALUOP = 3'b000;
                                          assign NEGATIVE_SIGNAL = 1'b0;
                                          assign IMMEDIATE_SIGNAL = 1'b1;
                                          assign WRITE_ENABLE = 1'b0;
                                          assign BRANCH_ENABLE = 1'b0;
                                          assign JUMP_ENABLE = 1'b0;
                                          assign READ = 1'b0;
                                          assign WRITE = 1'b1;
                                          assign DMEM_SIGNAL = 1'b1;
                                    end                                                                                               
        endcase
    end

endmodule