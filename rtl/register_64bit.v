// Company           :   tud                      
// Author            :   vana158e            
// E-Mail            :   <email>                    
//                    			
// Filename          :   register_64bit.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Tue Jan  7 18:32:28 2025 
// Last Change       :   $Date: 2025-01-07 19:37:35 +0100 (Tue, 07 Jan 2025) $
// by                :   $Author: vana158e $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module register_64bit (
    input wire clk,             // Clock signal
    input wire reset,           // Reset signal (active high)
    input wire [63:0] d,        // Data input
    output reg [63:0] q         // Data output
);

    // Sequential logic: Update data on rising clock edge
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            q <= 64'b0;         // Reset the register to 0
        end else begin
            q <= d;             // Update the register value with input data
        end
    end

endmodule
