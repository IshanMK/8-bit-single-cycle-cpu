/*
Module  : Instruction Cache 
Author  : E / 18 / 173 Kasthuripitiya K.A.I.M.
Date    : 
*/
`timescale  1ns/100ps

module icache (
    clock,
    reset,
    address,
    busywait,
    instruction,
    mem_busywait,
    mem_read,
    mem_address,
    mem_readinst
);
    
    /*declaring inputs and outputs*/
    input clock,reset;
    output reg busywait;
    input[9:0] address;
    output reg[31:0] instruction;
   
   
    input mem_busywait;
    output reg mem_read;
    output reg[5:0] mem_address;
    input[127:0] mem_readinst;
    
    
    reg[1:0] offset;
    reg hit ;
    integer i ;

    reg[3:0] OFFSET ;
    reg[2:0] INDEX;
    reg[2:0] CACHETAG;

    reg readaccess;
    reg[31:0] DATA1,DATA2,DATA3,DATA4;
    //reg[127:0] DATABLOCK;
    reg[2:0] tag;
    reg valid ;

    /*declare the instruction cache array*/
    reg[131:0] instruction_array[7:0] ;         //128 bits - 4 instructions + 3 bits - tag + 1 bit - valid bit

    /*Extracting the stored values*/
    always @(address,mem_readinst,instruction_array[INDEX]) begin
        
        #1
        OFFSET = address[3:0];
        INDEX = address[6:4];
        CACHETAG = address[9:7];

        DATA1 = instruction_array[INDEX][31:0];
        DATA2 = instruction_array[INDEX][63:32];
        DATA3 = instruction_array[INDEX][95:64];
        DATA4 = instruction_array[INDEX][127:96];

        //DATABLOCK   = instruction_array[INDEX][127:0];
        tag         = instruction_array[INDEX][130:128];

        /*Check whether cache mem location is empty or not
        if location is empty then valid = 0 otherwise 1*/
        valid    = instruction_array[INDEX][131];
        
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

    // Returning instruction according to the offset
    // This time delay will overlap the it determine delay

    always @(DATA1, DATA2, DATA3, DATA4, OFFSET) begin      // When one of followng changes, Read Data output will be Changed
        offset = OFFSET[3:2];
        #1
        case (offset)           // Determine Read Data output According to the OFFSEt

            2'b00:  instruction = DATA1;
                
            2'b01:  instruction = DATA2;
            
            2'b10:  instruction = DATA3;

            2'b11:  instruction = DATA4;
            
        endcase
    end

    /*Read Hit*/
    always @(*) begin
        if (hit) begin
            busywait = 1'b0;
        end
        else begin
            busywait = 1'b1;
        end
    end

    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001,FETCH_FROM_MEM = 3'b010;
    reg [2:0] state, next_state;

    always @(*) begin
        case (state)
            IDLE:
                if (!hit)  
                    next_state = MEM_READ;
                else
                    next_state = IDLE;
            
            MEM_READ:
                if (!mem_busywait)
                    next_state = FETCH_FROM_MEM;
                else    
                    next_state = MEM_READ;

            FETCH_FROM_MEM:
                next_state = IDLE;        
        endcase
    end

    // combinational output logic
    always @(*) begin
        case (state)
           IDLE:
            begin
                mem_read = 0;
                mem_address = 6'dx;
                busywait = 0;
            end
         
            MEM_READ: 
            begin
                mem_read = 1;
                mem_address = {CACHETAG, INDEX};
                busywait = 1;
            end

            FETCH_FROM_MEM: 
            begin
                mem_read = 1'b0;
                mem_address = 6'bx;
                busywait = 1 ;

               //this writing operation happens in the cache block after fetching the  memory
               //there is 1 time unit delay for this operation
				#1
				instruction_array[INDEX][127:0] = mem_readinst;	//write a data block to the cache
				instruction_array[INDEX][130:128] = CACHETAG ;	
				instruction_array[INDEX][131] = 1'b1;	//valid bit
			
            end
        endcase
    end

    // sequential logic for state transitioning 
    always @(posedge clock, reset)
    begin
        if(reset) begin
            state = IDLE;
            
        end    
        else begin
            state = next_state;
        end    
    end

    
    /* Cache Controller FSM End */

    always @(posedge clock,reset) begin
        if (reset) begin
            busywait = 1'b0;

            /* #1 for (i = 0 ;i < 8 ; i = i+1) begin
                instruction_array[i] <= 0;
            end */
        end
        
    end

    /*Ignore the warnings
    This will also include the values in registers to the same .vcd file*/
    initial begin
        $dumpfile("cpu_wavedata.vcd") ;
        
        for (i = 0;i<8 ; i+=1)
            $dumpvars(1,instruction_array[i]) ;

    end

endmodule