/*
Group 19
Lab05 - Part01
*/

`include "shifter.v"

/*===========================================================
                    ALU MODULE
=============================================================*/

module ALU (DATA1 , DATA2 , RESULT , SELECT,ZERO,SHIFT_TYPE);
    input[7:0] DATA1,DATA2;
    input[2:0] SELECT ;
    input SHIFT_TYPE;
    output reg signed[7:0] RESULT ;
    output reg ZERO;

    /*Temporaray wires to get the result of each instances*/
    wire[7:0] resultFORWARD , resultADD , resultAND , resultOR , resultShift;

    /*Creating instances*/
    Forward forward1(DATA2,resultFORWARD) ;
    ADD add1(DATA1,DATA2,resultADD) ;
    AND and1(DATA1 , DATA2 , resultAND) ;
    OR or1(DATA1 , DATA2 , resultOR) ;
    Shifter sh(DATA1,resultShift,DATA2,SHIFT_TYPE);

    /*If there is a change is selection this will execute*/
    always @(SELECT,DATA1,DATA2) begin

        case(SELECT)

            /*Case for Forwarding*/
            3'b000 :  assign RESULT = resultFORWARD;

            /*Case for Addition*/
            3'b001 :  assign RESULT = resultADD ;

            /*Case for bitwise AND operation*/
            3'b010 :  assign RESULT = resultAND ;

            /*Case for bitwise OR Operation*/
            3'b011 :  assign RESULT = resultOR ;

            /*Case for shfiting*/
            3'b100 :  assign RESULT = resultShift;
            
            default : assign RESULT = 8'bx;

        endcase
    end

    always @(DATA1,DATA2,SELECT,resultADD) begin
        if(resultADD == 8'b0) begin
            ZERO = 1 ;
        end
        else begin
            ZERO = 0;
        end
    end
endmodule

/*===========================================================
                    FORWARD MODULE
=============================================================*/

module Forward (DATA2,RESULT);
    input [7:0] DATA2;
    output [7:0] RESULT ;

    /**Update the RESULT with the value in DATA2*/
    assign #1 RESULT = DATA2;
    
endmodule

/*=============================================================
                    ADD MODULE
===============================================================*/

module ADD (DATA1 , DATA2 , RESULT);
    
    input [7:0] DATA1 , DATA2 ;
    output signed [7:0] RESULT ;

    /*Update the RESULT with the addition of DATA1 and DATA2*/
    assign #2 RESULT = DATA1 + DATA2 ;
endmodule

/*===============================================================
                        AND MODULE
=================================================================*/

module AND (DATA1 , DATA2 , RESULT);
    input [7:0] DATA1 , DATA2 ;
    output [7:0] RESULT ;

    /*Update the RESULT with the bitwise and operation between DATA1 and DATA2*/
    assign #1 RESULT = DATA1 & DATA2 ;
endmodule

/*===============================================================
                        OR MODULE
=================================================================*/

module OR (DATA1 , DATA2 , RESULT);
    input [7:0] DATA1 , DATA2 ;
    output [7:0] RESULT ;

    /*Update the RESULT with the bitwise and operation between DATA1 and DATA2*/
    assign #1 RESULT = DATA1 | DATA2 ;
endmodule