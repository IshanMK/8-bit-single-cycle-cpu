/*
Group 19
Lab05 - Part02
*/

module reg_file (IN , OUT1 , OUT2 , INADDRESS , OUT1ADDRESS , OUT2ADDRESS , WRITE , CLK , RESET);
    
    /*Inputs*/
    input[7:0] IN ;
    input[2:0] INADDRESS ;
    input[2:0] OUT1ADDRESS  , OUT2ADDRESS ;
    input WRITE , CLK , RESET ;

    /*Outputs*/
    output reg[7:0] OUT1 , OUT2 ;
    
    /*Registers from 0 - 7*/
    reg[7:0] register[7:0] ;

    /*Int variable*/
    integer i;

    always @(posedge(CLK)) begin
        
        /*If the RESET is high , all the registers will be set to zero*/
        if (RESET) begin
            #1
            for (i= 0; i <= 7 ;i+=1 ) begin
                register[i] <=  0 ;
            end
        end

        /*If the WRITE_ENABLE is high*/

        else if (WRITE) begin
            #1 register[INADDRESS] <= IN ;
        end
    end

    /*
    If any of the inputs were changed
    */
    
    always @(OUT1ADDRESS,OUT2ADDRESS,register[0],register[1],register[2],register[3],register[4],register[5],register[6],register[7])        
            begin
            #2 OUT1 <= register[OUT1ADDRESS] ;
               OUT2 <= register[OUT2ADDRESS] ; 
    end

    initial
	begin
		#5
		$display("\n\t\t\t==================================================================");
		$display("\t\t\t Change of Register Content Starting from Time #5");
		$display("\t\t\t==================================================================\n");
		$display("\t\ttime\tregs0\tregs1\tregs2\tregs3\tregs4\tregs5\tregs6\tregs7");
		$display("\t\t-------------------------------------------------------------------------------------");
		$monitor($time, "\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d", register[0], register[1], register[2], register[3], register[4], register[5], register[6], register[7]);
	end

    /*Ignore the warnings
    This will also include the values in registers to the same .vcd file*/
    initial begin
        $dumpfile("cpu_wavedata.vcd") ;
        
        for (i = 0;i<8 ; i+=1)
            $dumpvars(1,register[i]) ;
        
    end

endmodule