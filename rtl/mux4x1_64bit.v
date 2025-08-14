// Company           :   tud                      
// Author            :   vana158e            
// E-Mail            :   <email>                    
//                    			
// Filename          :   mux4x1_64bit.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Tue Jan  7 18:30:09 2025 
// Last Change       :   $Date: 2025-01-07 19:37:35 +0100 (Tue, 07 Jan 2025) $
// by                :   $Author: vana158e $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module mux4x1_64bit (
    input  [63:0] in0,  // Input 0
    input  [63:0] in1,  // Input 1
    input  [63:0] in2,  // Input 2
    input  [63:0] in3,  // Input 3
    input  [1:0] sel,   // 2-bit select signal
    output [63:0] out0   // Output
);
    // MUX logic
    assign out0 = (sel == 2'b00) ? in0 :
                 (sel == 2'b01) ? in1 :
                 (sel == 2'b10) ? in2 :
                                  in3; // Default case: sel == 2'b11
endmodule
