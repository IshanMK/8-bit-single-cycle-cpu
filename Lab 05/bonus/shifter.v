/*Group 19 - Part 05*/

/*=============================
    SHIFTER MODULE
===============================*/

module Shifter (IN,OUT,UNITS,SHIFT_TYPE);
    input [7:0] IN;
    output reg signed[7:0] OUT;
    input[7:0] UNITS;
    reg S0,S1,S2,S3;
    input SHIFT_TYPE ;
    reg[3:0] UNIT ;
    reg signed[7:0]LEFT ,RIGHT;

    /*Get the [3:0] bits*/
    always @(UNITS) begin
        UNIT = UNITS[3:0] ;
    end

    /*No of shifting units is given by UNITS
    The amount of shift is controlled by the binary number S3S2S1S0*/
    
    always @(UNIT) begin
        S0 = UNIT[0] ;
        S1 = UNIT[1] ;
        S2 = UNIT[2] ;
        S3 = UNIT[3] ;
    end

    /*Wires to get the OUTPUT from the SHIFTING_UNITs*/
    wire A1,A2,A3,A4,A5,A6,A7,A8;
    wire B1,B2,B3,B4,B5,B6,B7,B8;
    wire C1,C2,C3,C4,C5,C6,C7,C8;
    wire D1,D2,D3,D4,D5,D6,D7,D8;

    wire U1,U2,U3,U4,U5,U6,U7,U8;
    wire V1,V2,V3,V4,V5,V6,V7,V8;
    wire X1,X2,X3,X4,X5,X6,X7,X8;
    wire Y1,Y2,Y3,Y4,Y5,Y6,Y7,Y8;

    /*----------------------------------LEFT SHIFTING------------------------------------*/
    /*S0*/
    SHIFTING_UNIT L01(IN[0],1'b0,A1,S0) ;
    SHIFTING_UNIT L02(IN[1],IN[0],A2,S0) ;
    SHIFTING_UNIT L03(IN[2],IN[1],A3,S0) ;
    SHIFTING_UNIT L04(IN[3],IN[2],A4,S0) ;
    SHIFTING_UNIT L05(IN[4],IN[3],A5,S0) ;
    SHIFTING_UNIT L06(IN[5],IN[4],A6,S0) ;
    SHIFTING_UNIT L07(IN[6],IN[5],A7,S0) ;
    SHIFTING_UNIT L08(IN[7],IN[6],A8,S0) ;


    /*S1*/
    SHIFTING_UNIT L11(A1,1'b0,B1,S1) ;
    SHIFTING_UNIT L12(A2,1'b0,B2,S1) ;
    SHIFTING_UNIT L13(A3,A1,B3,S1) ;
    SHIFTING_UNIT L14(A4,A2,B4,S1) ;
    SHIFTING_UNIT L15(A5,A3,B5,S1) ;
    SHIFTING_UNIT L16(A6,A4,B6,S1) ;
    SHIFTING_UNIT L17(A7,A5,B7,S1) ;
    SHIFTING_UNIT L18(A8,A6,B8,S1) ;

    /*S2*/
    SHIFTING_UNIT L21(B1,1'b0,C1,S2) ;
    SHIFTING_UNIT L22(B2,1'b0,C2,S2) ;
    SHIFTING_UNIT L23(B3,1'b0,C3,S2) ;
    SHIFTING_UNIT L24(B4,1'b0,C4,S2) ;
    SHIFTING_UNIT L25(B5,B1,C5,S2) ;
    SHIFTING_UNIT L26(B6,B2,C6,S2) ;
    SHIFTING_UNIT L27(B7,B3,C7,S2) ;
    SHIFTING_UNIT L28(B8,B4,C8,S2) ;

    /*S3*/
    SHIFTING_UNIT L31(C1,1'b0,D1,S3) ;
    SHIFTING_UNIT L32(C2,1'b0,D2,S3) ;
    SHIFTING_UNIT L33(C3,1'b0,D3,S3) ;
    SHIFTING_UNIT L34(C4,1'b0,D4,S3) ;
    SHIFTING_UNIT L35(C5,1'b0,D5,S3) ;
    SHIFTING_UNIT L36(C6,1'b0,D6,S3) ;
    SHIFTING_UNIT L37(C7,1'b0,D7,S3) ;
    SHIFTING_UNIT L38(C8,1'b0,D8,S3) ;

    /*----------------------------------RIGHT SHIFTING------------------------------------*/
    
    /*S0*/
    SHIFTING_UNIT R01(IN[0],IN[1],U1,S0) ;
    SHIFTING_UNIT R02(IN[1],IN[2],U2,S0) ;
    SHIFTING_UNIT R03(IN[2],IN[3],U3,S0) ;
    SHIFTING_UNIT R04(IN[3],IN[4],U4,S0) ;
    SHIFTING_UNIT R05(IN[4],IN[5],U5,S0) ;
    SHIFTING_UNIT R06(IN[5],IN[6],U6,S0) ;
    SHIFTING_UNIT R07(IN[6],IN[7],U7,S0) ;
    SHIFTING_UNIT R08(IN[7],1'b0,U8,S0) ;

    /*S1*/
    SHIFTING_UNIT R11(U1,U3,V1,S1) ;
    SHIFTING_UNIT R12(U2,U4,V2,S1) ;
    SHIFTING_UNIT R13(U3,U5,V3,S1) ;
    SHIFTING_UNIT R14(U4,U6,V4,S1) ;
    SHIFTING_UNIT R15(U5,U7,V5,S1) ;
    SHIFTING_UNIT R16(U6,U8,V6,S1) ;
    SHIFTING_UNIT R17(U7,1'b0,V7,S1) ;
    SHIFTING_UNIT R18(U8,1'b0,V8,S1) ;

    /*S2*/
    SHIFTING_UNIT R21(V1,V5,X1,S2) ;
    SHIFTING_UNIT R22(V2,V6,X2,S2) ;
    SHIFTING_UNIT R23(V3,V7,X3,S2) ;
    SHIFTING_UNIT R24(V4,V8,X4,S2) ;
    SHIFTING_UNIT R25(V5,1'b0,X5,S2) ;
    SHIFTING_UNIT R26(V6,1'b0,X6,S2) ;
    SHIFTING_UNIT R27(V7,1'b0,X7,S2) ;
    SHIFTING_UNIT R28(V8,1'b0,X8,S2) ;

    /*S3*/
    SHIFTING_UNIT R31(X1,1'b0,Y1,S3) ;
    SHIFTING_UNIT R32(X2,1'b0,Y2,S3) ;
    SHIFTING_UNIT R33(X3,1'b0,Y3,S3) ;
    SHIFTING_UNIT R34(X4,1'b0,Y4,S3) ;
    SHIFTING_UNIT R35(X5,1'b0,Y5,S3) ;
    SHIFTING_UNIT R36(X6,1'b0,Y6,S3) ;
    SHIFTING_UNIT R37(X7,1'b0,Y7,S3) ;
    SHIFTING_UNIT R38(X8,1'b0,Y8,S3) ;
 

    
    always @(D1,D2,D3,D4,D5,D6,D7,D8) begin
        /**/
        LEFT = {D8,D7,D6,D5,D4,D3,D2,D1} ;
    end
    
    always @(Y1,Y2,Y3,Y4,Y5,Y6,Y7,Y8) begin
        /**/
        RIGHT = {Y8,Y7,Y6,Y5,Y4,Y3,Y2,Y1};
    end

    always @(LEFT,RIGHT,SHIFT_TYPE) begin
        /*If the SHIFT_TYPE is high then it will select LEFT 
        otherwise RIGHT*/

        if(SHIFT_TYPE) begin
            #1 OUT = LEFT ;
        end
        else begin
            #1 OUT = RIGHT ;
        end
    end
endmodule

/*=============================
    SHIFTING UNIT MODULE
===============================*/

module SHIFTING_UNIT (IN1,IN2,OUT,SELECT);
    input IN1;
    input IN2;
    input SELECT;
    output OUT;

    wire OUT1;
    wire OUT2;

    and and1(OUT1,~SELECT,IN1) ;
    and and2(OUT2,SELECT,IN2);

    or OR1(OUT,OUT1,OUT2);
endmodule

