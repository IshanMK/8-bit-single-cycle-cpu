/*
Group 19
Lab05 - Part01
*/


/*===========================================================
                    TESTBENCH MODULE
=============================================================*/
module moduleName() ;
    reg[7:0] data1,data2 ;
    reg[2:0] select ;
    wire[7:0] result ;

    /*Create the alu instance*/
    ALU alu1(data1 , data2 , result , select) ;
    
    initial begin
        $monitor($time , "data1 = %b , data2 = %b  , result = %b , select = %b\n" , data1,data2,result , select) ;
        select = 3'b000;
        data1 = 8'b0001_0111;
        data2 = 8'b0001_0100 ;

        #5 select = 3'b001 ;
        #5 select = 3'b010 ;
        #5 select = 3'b011 ; 
        #30 $finish;
    end

    /* always @(result) begin */
        /*After each 3 time units update the selector*/
       /*  #5 select  = select + 3'b001;
    end */

        
endmodule


/*===========================================================
                    ALU MODULE
=============================================================*/

module ALU (DATA1 , DATA2 , RESULT , SELECT);
    input[7:0] DATA1,DATA2;
    input[2:0] SELECT ;
    output reg[7:0] RESULT ;

    /*Temporaray wires to get the result of each instances*/
    wire[7:0] resultFORWARD , resultADD , resultAND , resultOR;

    /*Creating instances*/
    Forward forward1(DATA2,resultFORWARD) ;
    ADD add1(DATA1,DATA2,resultADD) ;
    AND and1(DATA1 , DATA2 , resultAND) ;
    OR or1(DATA1 , DATA2 , resultOR) ;

    /*If there is a change is selection this will execute*/
    always @(SELECT,DATA1,DATA2) begin

        case(SELECT)

            /*Case for Forwarding*/
            3'b000 : assign RESULT = resultFORWARD;

            /*Case for Addition*/
            3'b001 : assign RESULT = resultADD ;

            /*Case for bitwise AND operation*/
            3'b010 : assign RESULT = resultAND ;

            /*Case for bitwise OR Operation*/
            3'b011 : assign RESULT = resultOR ;

        endcase

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
    output [7:0] RESULT ;

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