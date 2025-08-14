// Company           :   tud                      
// Author            :   aydi294f            
// E-Mail            :   <email>                    
//                    			
// Filename          :   spimaster.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Fri Nov 15 10:22:22 2024 
// Last Change       :   $Date: 2025-05-30 13:49:38 +0200 (Fri, 30 May 2025) $
// by                :   $Author: aydi294f $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module spi_master (
    input             clk,
    input             reset,
    input             start, 
    input             rw,                // 0 for read, 1 for write
    input  [15:0]     address,           // 16-bit address
    input  [63:0]     data_in,           // Data to write
    input             MISO,              // Master In Slave Out
    
    output reg        SCLK,              // SPI clock
    output reg        MOSI,              // Master Out Slave In
    output reg        SS,                // Slave Select
    output reg [63:0] data_out,          // Data read from slave
    output reg        done               // Transaction complete
);

  // State Encoding

   reg [2:0] 	current_state;
   reg [2:0] 	next_state;
    
   parameter S_IDLE                    = 3'b000;
   parameter S_SEND_CMD                = 3'b001;
   parameter S_TRANSFER_DATA           = 3'b010;
   parameter S_DONE                    = 3'b011;


    // Internal Registers
    reg [15:0]  command_packet;
    reg [6:0]   bit_count;       // Tracks bit transmission count


    always @(posedge clk or posedge reset) begin
        if (reset== 1'b1) begin
            current_state <= S_IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // State Machine
    always @(current_state)
     begin         
        SS = 1;     // Deactivate slave
        SCLK = 0;   // Default clock state
        MOSI = 0;
        done = 0;
     
        case (current_state)
	
            S_IDLE: begin
                if (start) begin
                    next_state = S_SEND_CMD;
                end 
            end

            S_SEND_CMD: begin
	   
                SS = 0; // Activate slave
		
                command_packet = {rw, address[15:2], 1'b0};
		
                if (bit_count < 16) begin
                    MOSI = command_packet[15 - bit_count]; // Send MSB first
                    SCLK = ~SCLK; // Toggle clock
                end else begin
                    next_state = S_TRANSFER_DATA;
                end
            end

            S_TRANSFER_DATA: begin
	    
	        SS = 0; // Keep slave active
		
                if (rw == 0) begin   // Read operation
                    if (bit_count < 64) begin
                        data_out[63 - bit_count] = MISO; // Receive data
                        SCLK = ~SCLK; // Toggle clock
                    end else begin
                        next_state = S_DONE;
                    end
                end 
		
		
		else begin    // Write operation
                    if (bit_count < 64) begin
                        MOSI = data_in[63 - bit_count]; // Send data
                        SCLK = ~SCLK; // Toggle clock
                    end else begin
                        next_state = S_DONE;
                    end
                end
            end


            S_DONE: begin
                SS = 1; // Deactivate slave
                done = 1;
                next_state = S_IDLE; // Return to idle
            end

            
	    default: next_state = S_IDLE;
        
	endcase
    end

endmodule
