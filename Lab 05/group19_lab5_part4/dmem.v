/*
Module  : 256x8-bit data memory 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a primitive data memory module for CO224 Lab 6 - Part 1
This memory allows data to be read and written as 1-Byte words
*/

module data_memory(
	clock,
    reset,
    read,
    write,
    address,
    writedata,
    readdata,
    busywait
);
input           clock;
input           reset;
input           read;
input           write;
input[7:0]      address;
input[7:0]      writedata;
output reg [7:0]readdata;
output reg      busywait;

//Declare memory array 256x8-bits 
reg [7:0] memory_array [255:0];

//Detecting an incoming memory access
reg readaccess, writeaccess;
always @(read, write)
begin
	busywait = (read || write)? 1 : 0;
	readaccess = (read && !write)? 1 : 0;
	writeaccess = (!read && write)? 1 : 0;
end

//Reading & writing
always @(posedge clock)
begin
    if(readaccess)
    begin
        readdata = #40 memory_array[address];
        busywait = 0;
		readaccess = 0;
    end
    if(writeaccess)
	begin
        memory_array[address] = #40 writedata;
        busywait = 0;
		writeaccess = 0;
    end
end

integer i;

//Reset memory
always @(posedge reset)
begin
    if (reset)
    begin
        for (i=0;i<256; i=i+1)
            memory_array[i] = 0;
        
        busywait = 0;
		readaccess = 0;
		writeaccess = 0;
    end
end

/*Ignore the warnings
    This will also include the values in registers to the same .vcd file*/
    initial begin
        $dumpfile("cpu_wavedata.vcd") ;
        
        for (i = 0;i<20 ; i+=1)
            $dumpvars(1,memory_array[i]) ;
        
    end
endmodule
