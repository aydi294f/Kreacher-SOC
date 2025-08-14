// Company           :   tud                      
// Author            :   vana158e            
// E-Mail            :   <email>                    
//                    			
// Filename          :   mux2x1.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Tue Jan  7 18:29:32 2025 
// Last Change       :   $Date: 2025-01-07 19:37:35 +0100 (Tue, 07 Jan 2025) $
// by                :   $Author: vana158e $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module mux2x1 (
    input wire [63:0] a,        // Input 1
    input wire [63:0] b,        // Input 2
    input wire sel,      // Select signal
    output wire [63:0] y        // Output
);

    // MUX logic: y = (sel == 0) ? a : b
    assign y = (sel) ? b : a;

endmodule
