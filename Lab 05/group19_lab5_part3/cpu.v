`include "reg.v"
`include "ALU.v"

/*------------------------
        CPU MODULE
-------------------------*/

module cpu (PC,INSTRUCTION,CLK,RESET);
    output [31:0] PC;
    input[31:0] INSTRUCTION;
    input CLK,RESET;
    reg[7:0] OPCODE;
    wire[31:0] PC_NEXT;

    reg[7:0] IN;
    wire[7:0] OUT1;
    wire[7:0] OUT2;
    reg[7:0] IMMEDIATE;

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

    /*Addder module instantiation*/

    adder add(PC,CLK,RESET);

    always @(INSTRUCTION) begin
        OPCODE = INSTRUCTION[31:24];
        WRITEREG = INSTRUCTION[18:16];
        READREG1 = INSTRUCTION[10:8];
        READREG2 = INSTRUCTION[2:0];
        IMMEDIATE = INSTRUCTION[7:0];
    end

    /*reg_file instantiation*/
    reg_file register(ALURESULT,OUT1,OUT2,WRITEREG,READREG1,READREG2,WRITE_ENABLE,CLK,RESET);

    /*Control Unit instantiation*/
    ControlUnit cu(OPCODE,WRITE_ENABLE,MUX1SELECT,MUX2SELECT,ALUOP);

    /*TWOS compliment module instantiation*/
    TWOS_COMPLIMENT f1(OUT2,NEG);

    /*MUX 1 instantiation */
    MUX m1(OUT2,NEG,MUX1OUT,MUX1SELECT);

    /*MUX2 instantiation*/
    MUX m2(IMMEDIATE,MUX1OUT,MUX2OUT,MUX2SELECT);

    /*ALU module instantiation*/
    ALU alu(OUT1,MUX2OUT,ALURESULT,ALUOP);  
    

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
        if (SELECT) begin
            OUT = IN1;
        end
        else begin
            OUT = IN2;
        end
    end
endmodule

/*------------------------
        adder MODULE
-------------------------*/

module adder (PC,CLK,RESET);
    output reg[31:0] PC;
    input CLK,RESET;
    reg[31:0] PC_OUT;
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
    ControlUnit MODULE
-------------------------*/

module ControlUnit (OPCODE,WRITE_ENABLE,MUX1SELECT,MUX2SELECT,ALUOP);
    input[7:0] OPCODE;

    output reg WRITE_ENABLE;
    output reg MUX1SELECT;
    output reg MUX2SELECT;
    output reg[2:0] ALUOP;
    
    always @(OPCODE) begin
        case (OPCODE) 
            /*Forward Instruction*/
            8'b0000_0000     :       begin
                                        #1
                                         ALUOP = 3'b000;
                                         MUX1SELECT = 1'b1;
                                         MUX2SELECT = 1'b1;
                                         WRITE_ENABLE = 1'b1;

                                    end

            /*MOV to specific reg*/
            8'b0000_0001    :       begin
                                        #1
                                         ALUOP = 3'b000;
                                         MUX1SELECT = 1'b1;
                                         MUX2SELECT = 1'b0;
                                         WRITE_ENABLE = 1'b1;
                                    end

            /*ADD instruction*/
            8'b0000_0010    :       begin
                                        #1
                                         ALUOP = 3'b001;
                                         MUX1SELECT = 1'b1;
                                         MUX2SELECT = 1'b0;
                                         WRITE_ENABLE = 1'b1;  
                                    end
            
            /*SUB instrcution*/
            8'b0000_0011        :   begin
                                        #1
                                         ALUOP = 3'b001;
                                         MUX1SELECT = 1'b0;
                                         MUX2SELECT = 1'b0;
                                         WRITE_ENABLE = 1'b1;  
                                    end
            
            /*AND instruction*/
            8'b0000_0100    :       begin
                                        #1
                                         ALUOP = 3'b010;
                                         MUX1SELECT = 1'b1;
                                         MUX2SELECT = 1'b0;
                                         WRITE_ENABLE = 1'b1;  
                                    end

            /*OR instruction*/
            8'b0000_0101    :       begin
                                        #1
                                         ALUOP = 3'b011;
                                         MUX1SELECT = 1'b1;
                                         MUX2SELECT = 1'b0;
                                         WRITE_ENABLE = 1'b1;   
                                    end

            /* default         :       begin
                                        #1
                                        ALUOP = 3'b000;
                                        MUX1SELECT = 1'b1;
                                        MUX2SELECT = 1'b0;
                                        WRITE_ENABLE = 1'b1; 
                                    end */
                                     
        endcase
    end

endmodule