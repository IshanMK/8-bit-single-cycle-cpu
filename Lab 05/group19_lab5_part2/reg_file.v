/*
Group 19
Lab05 - Part02
*/
module reg_file_tb;
    
    reg [7:0] WRITEDATA;
    reg [2:0] WRITEREG, READREG1, READREG2;
    reg CLK, RESET, WRITEENABLE; 
    wire [7:0] REGOUT1, REGOUT2;
    
    reg_file myregfile(WRITEDATA, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);
       
    initial
    begin
        CLK = 1'b1;
        
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("reg_file_wavedata.vcd");
		$dumpvars(0, reg_file_tb);
        
        // assign values with time to input signals to see output 
        RESET = 1'b0;
        WRITEENABLE = 1'b0;
        
        #4
        RESET = 1'b1;
        READREG1 = 3'd0;
        READREG2 = 3'd4;
        
        #6
        RESET = 1'b0;
        
        #2
        WRITEREG = 3'd2;
        WRITEDATA = 8'd95;
        WRITEENABLE = 1'b1;
        
        #7
        WRITEENABLE = 1'b0;
        
        #1
        READREG1 = 3'd2;
        
        #7
        WRITEREG = 3'd1;
        WRITEDATA = 8'd28;
        WRITEENABLE = 1'b1;
        READREG1 = 3'd1;
        
        #8
        WRITEENABLE = 1'b0;
        
        #8
        WRITEREG = 3'd4;
        WRITEDATA = 8'd6;
        WRITEENABLE = 1'b1;
        
        #8
        WRITEDATA = 8'd15;
        WRITEENABLE = 1'b1;
        
        #10
        WRITEENABLE = 1'b0;
        
        #6
        WRITEREG = -3'd1;
        WRITEDATA = 8'd50;
        WRITEENABLE = 1'b1;
        
        #5
        WRITEENABLE = 1'b0;
        
        #10
        $finish;
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule


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
    
    always @(*)        
            begin
            #2 OUT1 <= register[OUT1ADDRESS] ;
               OUT2 <= register[OUT2ADDRESS] ; 
    end

endmodule