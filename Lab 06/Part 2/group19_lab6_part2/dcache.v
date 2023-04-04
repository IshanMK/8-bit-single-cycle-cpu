/*
Module  : Data Cache 
Author  : E / 18 / 173 Kasthuripitiya K.A.I.M.
Date    : 

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model. Note that this code is not complete.
*/

`timescale  1ns/100ps

module dcache (
    CLK,
    reset,
    read,
    write,
    address,
    writedata,
    readdata,
    busywait,
    mem_read,
    mem_write,
    mem_address,
    mem_writedata,
    mem_readdata,
    mem_busywait
);
    
    /*declare inputs and outputs*/
    input           CLK;
    input           reset;
    input          read;
    input           write;
    input[7:0]      address;
    input[7:0]      writedata;
    output reg [7:0]readdata;
    output reg      busywait;

    output reg           	mem_read;
    output reg           	mem_write;
    output reg[5:0]      	mem_address;
    output reg[31:0]     	mem_writedata;
    input [31:0]	mem_readdata;
    input    	mem_busywait;

    integer i ;
    reg valid;
    reg dirty;
    reg[1:0] OFFSET;
    reg[2:0] INDEX;
    reg[2:0] CACHETAG;

    reg [7:0] DATA1;
    reg [7:0] DATA2;
    reg [7:0] DATA3;
    reg [7:0] DATA4;
    reg[31:0] DATABLOCK;
    
    reg[2:0] tag;
    reg readaccess;
    reg writeaccess;

    reg hit;

    //Declare memory array 37x8-bits 
    reg [36:0] cache_array [7:0];                   //32bits-block size + 1bit-validbit + 1bit-dirtybit + 3bit-tag
    
    /*Extracting stored values*/
    always @(address,readaccess,writeaccess,writedata,cache_array[INDEX]) begin

        if((readaccess == 1'b1) || (writeaccess == 1'b1)) begin
            /*splitting the CPU given address in to tag,index and offset with a #1 delay*/
            #1
            OFFSET      = address[1:0];
            INDEX       = address[4:2];
            CACHETAG    = address[7:5];

            /*finding the correct cache entry and extracting the stored data block,
            tag,valid and dirty bits 
            This extraction was done based on the index extracted from address given by the CPU
            */

            // Get Relevant Fields from Cache
            // Get words separatley so it can be write easily

            DATA1 = cache_array[INDEX][7:0];
            DATA2 = cache_array[INDEX][15:8];
            DATA3 = cache_array[INDEX][23:16];
            DATA4 = cache_array[INDEX][31:24];

            DATABLOCK   = cache_array[INDEX][31:0];
            tag         = cache_array[INDEX][34:32];

            /*If the dirtybit == 0 then the value cache and the value in memory are same*/
            dirty    = cache_array[INDEX][35];

            /*Check whether cache mem location is empty or not
            if location is empty then valid = 0 otherwise 1*/
            valid    = cache_array[INDEX][36];
        end 
    end

    always @(read,write) begin
         //if read high or write high make busywait high else make low
		busywait = (read || write)? 1 : 0;

        //if read high and write low make readaccess high else make low
		readaccess = (read && !write)? 1 : 0;

        //if read low and write high make writeaccess high else make low
		writeaccess = (!read && write)? 1 : 0;

    end

    /*Tag comparison and validation*/
    always @(tag,valid,CACHETAG) begin

        /*Tag comparison and validation to to determine whether the access is a hit or a miss with delay of #0.9*/
        if ((CACHETAG == tag) && valid == 1'b1) begin

            //If Tag comarison matched and valid bit is high then hit will be high
            #0.9 hit = 1'b1;
        end
        else begin
            #0.9 hit = 1'b0;
        end
    end

    // Returning ReadData according to the offset
    // This time delay will overlap the it determine delay

    always @(DATA1, DATA2, DATA3, DATA4, OFFSET) begin      // When one of followng changes, Read Data output will be Changed
        
        #1
        case (OFFSET)           // Determine Read Data output According to the OFFSEt

            2'b00: readdata = DATA1;
                
            2'b01: readdata = DATA2;
            
            2'b10: readdata = DATA3;

            2'b11: readdata = DATA4;
            
        endcase
    end


    /*==============================================================================================
    =====================================Read Hit===================================================
    =================================================================================================*/
    /*determine the readdata value based on offset*/
    always @(*) begin

        if((readaccess==1'b1) && (hit==1'b1)) begin
            //After the end of the process de-asserts the memory by setting busywait = 1'b0
            busywait = 1'b0;                // De asserting busywait Signal
            readaccess = 1'b0;
            cache_array[INDEX][36] = 1'b1;              //Set the valid bit to 1
        end
    end

    /*==================================================================================================
    ==============================write-Hit=============================================================
    ====================================================================================================*/
    always @(posedge CLK) begin
        if (hit == 1'b1 && writeaccess == 1'b1) begin
            
            busywait = 1'b0;
            #1
            case (OFFSET)
                2'b00   :   cache_array[INDEX][7:0] = writedata;
                2'b01   :   cache_array[INDEX][15:8] = writedata;
                2'b10   :   cache_array[INDEX][23:16] = writedata;
                2'b11   :   cache_array[INDEX][31:24] = writedata;
            endcase

            //After the end of the process de-asserts the memory by setting busywait = 1'b0
            
            cache_array[INDEX][36] = 1'b1;              //Set the valid bit to 1
            cache_array[INDEX][35] = 1'b1;              //Set the dirty bit to 1
            writeaccess = 1'b0;
        end
    end

    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001,MEM_WRITE = 3'b010,FETCH_FROM_MEM = 3'b011;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((read || write) && !dirty && !hit)  
                    next_state = MEM_READ;
                else if ((read || write) && dirty && !hit)
                    next_state = MEM_WRITE;
                else
                    next_state = IDLE;
            
            MEM_READ:
                if (!mem_busywait)
                    next_state = FETCH_FROM_MEM;
                else    
                    next_state = MEM_READ;
            
            MEM_WRITE:
                if (!mem_busywait)
                    next_state = MEM_READ;
                else
                    next_state = MEM_WRITE;

            FETCH_FROM_MEM:
                next_state = IDLE;

        endcase
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin
                mem_read = 0;
                mem_write = 0;
                mem_address = 8'dx;
                mem_writedata = 8'dx;
                //busywait = 0;
            end
         
            MEM_READ: 
            begin
                mem_read = 1;
                mem_write = 0;
                mem_address = {tag, INDEX};
                mem_writedata = 32'dx;
                busywait = 1;
            end
            
            MEM_WRITE:
            begin
                mem_read = 0;
                mem_write = 1;
                mem_address = {tag, INDEX};
                mem_writedata = DATABLOCK;
                busywait = 1;
            end

            FETCH_FROM_MEM: 
            begin
                mem_read = 1'b0;
                mem_write = 1'b0;
                mem_address = 6'bx;
                mem_writedata = 32'bx;
                busywait = 1 ;

               //this writing operation happens in the cache block after fetching the  memory
               //there is 1 time unit delay for this operation
				#1;
				cache_array[INDEX][31:0] = mem_readdata;	//write a data block to the cache
				cache_array[INDEX][34:32] = CACHETAG ;	
				cache_array[INDEX][35] = 1'b0;	//dirty bit=0 since we are writing a data in cache which is also in memory
				cache_array[INDEX][36] = 1'b1;	//valid bit
			
            end
        endcase
    end

    // sequential logic for state transitioning 
    always @(posedge CLK, reset)
    begin
        if(reset) begin
            state = IDLE;
            busywait = 1'b0;
            #1 for (i = 0 ;i < 8 ; i = i+1) begin
                cache_array[i] <= 0;
            end
        end    
        else begin
            state = next_state;
        end    
    end

    /* Cache Controller FSM End */

endmodule