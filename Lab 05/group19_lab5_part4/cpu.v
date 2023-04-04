`include "reg.v"
`include "ALU.v"

/*------------------------
        CPU MODULE
-------------------------*/

module cpu (PC,INSTRUCTION,CLK,RESET);
    output[31:0] PC;
    input[31:0] INSTRUCTION;
    input CLK,RESET;
    reg[7:0] OPCODE;

    wire[7:0] OUT1;
    wire[7:0] OUT2;
    reg[7:0] IMMEDIATE;
    reg[7:0] OFFSET;

    reg[2:0] READREG1;
    reg[2:0] READREG2;
    reg[2:0] WRITEREG;

    wire WRITE_ENABLE;
    wire MUX1SELECT;
    wire MUX2SELECT;
    wire[2:0] ALUOP;
    
    wire[7:0] NEG;
    wire[7:0] MUX1OUT;
    wire[7:0] MUX2OUT;
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
    BranchAdder beqadder(PC,CLK,RESET,EXTENDED,BRANCH_SELECT,JUMP_ENABLE);

    /*Module to get the BRACH_SELECT value*/
    ANDMODULE andmodule(ZERO,BRANCH_ENABLE,BRANCH_SELECT);
    
    /*reg_file instantiation*/
    reg_file register(ALURESULT,OUT1,OUT2,WRITEREG,READREG1,READREG2,WRITE_ENABLE,CLK,RESET);

    /*Control Unit instantiation*/
    ControlUnit cu(OPCODE,WRITE_ENABLE,MUX1SELECT,MUX2SELECT,BRANCH_ENABLE,JUMP_ENABLE,ALUOP);
    
    /*TWOS compliment module instantiation*/
    TWOS_COMPLIMENT f1(OUT2,NEG);

    /*MUX 1 instantiation */
    MUX m1(OUT2,NEG,MUX1OUT,MUX1SELECT);

    /*MUX2 instantiation*/
    MUX m2(IMMEDIATE,MUX1OUT,MUX2OUT,MUX2SELECT);

    /*ALU module instantiation*/
    ALU alu(OUT1,MUX2OUT,ALURESULT,ALUOP,ZERO);  
    
endmodule

/*------------------------
        AND MODULE
-------------------------*/

module ANDMODULE (IN1,IN2,OUT);
    input IN1;
    input IN2;
    output reg OUT;

    always @(IN1,IN2) begin
        if(IN1 & IN2) begin
            OUT = 1'b1;
        end
        else begin
            OUT = 1'b0;
        end
    end
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
            1'b1    :   assign OUT = IN1;

            /*If SELECT is low it will select IN2*/   
            1'b0    :   assign OUT = IN2;

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
            1'b1    :   assign OUT = IN1;

            /*If SELECT is low it will select IN2*/   
            1'b0    :   assign OUT = IN2;

            /*As the default case this will select IN1*/                            
            default :   assign OUT = IN1;                             

        endcase 
    end
endmodule

/*------------------------
        adder MODULE
-------------------------*/

module adder (PC,CLK,RESET);
    output reg signed[31:0] PC;
    input CLK,RESET;
    reg signed[31:0] PC_OUT;
    always @(posedge(CLK)) begin
        if (RESET) begin
            #1 PC = 0;
        end
        else begin
            #1 PC = PC_OUT;
        end  
    end
 
    always @(PC) begin
       #1 PC_OUT = PC + 4;
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
    BranchAdder MODULE
-------------------------*/
module BranchAdder (PC,CLK,RESET,SHIFTED_OFFSET,BRANCH_SELECT,JUMP_ENABLE);
    input[31:0] SHIFTED_OFFSET;
    input CLK,RESET,BRANCH_SELECT,JUMP_ENABLE;
    wire[31:0] TARGET_ADDRESS ;
    wire[31:0] MUX1OUT,MUX2OUT;
    reg[31:0] temp ;
    output reg[31:0] PC;

    /*At the positive edge of the clock PC = 0 */
    always @(posedge(CLK)) begin
        if (RESET) begin
            #1 PC <= 0;
        end

    end
    
    /*PC = PC + 4*/
    always @(PC) begin
       #1 temp <= PC + 4;
    end

    /*Module instantiation to get the target address*/
    TARGET target(temp,SHIFTED_OFFSET,TARGET_ADDRESS) ;

    /*If the BRANCH_SELECT is high it will select TARGET_ADDRESS otherwise PC + 4*/
    MUXBRANCH mbr1(TARGET_ADDRESS,temp,MUX1OUT,BRANCH_SELECT) ;

    /*If teh JUMP_ENABLE is high it will select TARGET_ADDRESS , otherwise PC + 4*/
    MUXBRANCH mbr2(TARGET_ADDRESS,MUX1OUT,MUX2OUT,JUMP_ENABLE) ;

    /*Get the MUX2OUT value to PC*/
    always @(posedge CLK) begin
        PC <= MUX2OUT;
    end
endmodule
/*------------------------
    ControlUnit MODULE
-------------------------*/

module ControlUnit (OPCODE,WRITE_ENABLE,MUX1SELECT,MUX2SELECT,BRANCH_ENABLE,JUMP_ENABLE,ALUOP);
    input[7:0] OPCODE;

    output reg WRITE_ENABLE;
    output reg MUX1SELECT;
    output reg MUX2SELECT;
    output reg BRANCH_ENABLE;
    output reg JUMP_ENABLE;
    output reg[2:0] ALUOP;
    
    always @(OPCODE) begin
        case (OPCODE) 
            /*LOADI Instruction*/
            8'b0000_0000     :       begin
                                        #1
                                          ALUOP = 3'b000;
                                          MUX1SELECT = 1'b1;
                                          MUX2SELECT = 1'b1;
                                          WRITE_ENABLE = 1'b1;
                                          BRANCH_ENABLE = 1'b0;
                                          JUMP_ENABLE = 1'b0;
                                    end

            /*MOV to specific reg*/
            8'b0000_0001    :       begin
                                        #1
                                          ALUOP = 3'b000;
                                          MUX1SELECT = 1'b1;
                                          MUX2SELECT = 1'b0;
                                          WRITE_ENABLE = 1'b1;
                                          BRANCH_ENABLE = 1'b0;
                                          JUMP_ENABLE = 1'b0;
                                    end

            /*ADD instruction*/
            8'b0000_0010    :       begin
                                        #1
                                          ALUOP = 3'b001;
                                          MUX1SELECT = 1'b1;
                                          MUX2SELECT = 1'b0;
                                          WRITE_ENABLE = 1'b1;
                                          BRANCH_ENABLE = 1'b0;  
                                          JUMP_ENABLE = 1'b0;
                                    end
            
            /*SUB instrcution*/
            8'b0000_0011        :   begin
                                        #1
                                          ALUOP = 3'b001;
                                          MUX1SELECT = 1'b0;
                                          MUX2SELECT = 1'b0;
                                          WRITE_ENABLE = 1'b1;
                                          BRANCH_ENABLE = 1'b0;  
                                          JUMP_ENABLE = 1'b0;
                                    end
            
            /*AND instruction*/
            8'b0000_0100    :       begin
                                        #1
                                          ALUOP = 3'b010;
                                          MUX1SELECT = 1'b1;
                                          MUX2SELECT = 1'b0;
                                          WRITE_ENABLE = 1'b1;
                                          BRANCH_ENABLE = 1'b0;  
                                          JUMP_ENABLE = 1'b0;
                                    end

            /*OR instruction*/
            8'b0000_0101    :       begin
                                        #1
                                          ALUOP = 3'b011;
                                          MUX1SELECT = 1'b1;
                                          MUX2SELECT = 1'b0;
                                          WRITE_ENABLE = 1'b1;
                                          BRANCH_ENABLE = 1'b0;  
                                          JUMP_ENABLE = 1'b0; 
                                    end

            /*JUMP instruction*/
            8'b0000_0110         :       begin
                                        #1
                                         ALUOP = 3'b000;
                                         MUX1SELECT = 1'b1;
                                         MUX2SELECT = 1'b0;
                                         WRITE_ENABLE = 1'b0; 
                                         BRANCH_ENABLE = 1'b0;
                                         JUMP_ENABLE = 1'b1;
                                    end
            
            /*BEQ instruction*/
            8'b0000_0111         :       begin
                                        #1
                                         ALUOP = 3'b001;
                                         MUX1SELECT = 1'b0;
                                         MUX2SELECT = 1'b0;
                                         WRITE_ENABLE = 1'b0; 
                                         BRANCH_ENABLE = 1'b1;
                                         JUMP_ENABLE = 1'b0;
                                    end
                                     
        endcase
    end

endmodule