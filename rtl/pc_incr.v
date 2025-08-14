// Company           :   tud                      
// Author            :   vana158e            
// E-Mail            :   <email>                    
//                    			
// Filename          :   pc_incr.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Tue Jan  7 18:31:11 2025 
// Last Change       :   $Date: 2025-01-07 19:37:35 +0100 (Tue, 07 Jan 2025) $
// by                :   $Author: vana158e $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module pc_incr (
    input wire clk,             // Clock signal
    input wire reset,           // Reset signal (active high)
    input wire [63:0] pc_in,
    output reg [63:0] pc        // Program counter output
);

    // On each clock cycle, increment the counter by 4
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            pc <= 64'b0;        // Reset the counter to 0
        end else begin
            pc <= pc_in + 64'd1;   // Increment the counter by 4
        end
    end

endmodule
