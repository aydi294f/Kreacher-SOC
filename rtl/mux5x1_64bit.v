// Company           :   tud                      
// Author            :   pran972e            
// E-Mail            :   <email>                    
//                    			
// Filename          :   mux5x1_64bit.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Sun Feb  9 17:51:52 2025 
// Last Change       :   $Date: 2025-02-09 22:02:41 +0100 (Sun, 09 Feb 2025) $
// by                :   $Author: pran972e $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module mux5x1_64bit (
    input  [63:0] in0,  // Input 0
    input  [63:0] in1,  // Input 1
    input  [63:0] in2,  // Input 2
    input  [63:0] in3,  // Input 3
    input  [63:0] in4,  // Input 4
    input  [2:0] sel,   // 3-bit select signal
    output [63:0] out0  // Output
);
    // MUX logic
    assign out0 = (sel == 3'b000) ? in0 :
                  (sel == 3'b001) ? in1 :
                  (sel == 3'b010) ? in2 :
                  (sel == 3'b011) ? in3 :
                  (sel == 3'b100) ? in4 :
                  64'b0; // Default case: if sel > 4, output zero
endmodule
