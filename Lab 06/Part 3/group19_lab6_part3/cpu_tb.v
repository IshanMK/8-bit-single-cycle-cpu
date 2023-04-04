// Computer Architecture (CO224) - Lab 05
// Design: Testbench of Integrated CPU of SMEMple Processor
// Author: Isuru Nawinne
`include "CPU.v"
`include "imem.v"
`include "icache.v"
`timescale 1ns/100ps

module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;
    wire [5:0] MEM_ADDRESS;
    wire [127:0] MEM_READINST;
    wire MEM_BUSYWAIT;
    wire MEM_READ;
    wire BUSYWAIT;
    
   
    instruction_memory imem(CLK, MEM_READ, MEM_ADDRESS, MEM_READINST, MEM_BUSYWAIT);     
    icache icachemem(CLK, RESET, PC[9:0],BUSYWAIT ,INSTRUCTION , MEM_BUSYWAIT,MEM_READ, MEM_ADDRESS, MEM_READINST);     

    /* 
    -----
     CPU
    -----
    */
    cpu mycpu(PC, INSTRUCTION, CLK, RESET,BUSYWAIT);

    initial
    begin
    
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
        
        CLK = 1'b0;
        //RESET = 1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        
        RESET = 1'b0;
        #2
        RESET = 1'b1;
        #10
        RESET = 1'b0;

        #2000
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;
        

endmodule