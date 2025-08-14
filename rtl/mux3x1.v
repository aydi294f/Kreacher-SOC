// Company           :   tud                      
// Author            :   aydi294f            
// E-Mail            :   <email>                    
//                    			
// Filename          :   mux3x1.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Sat May 31 16:31:33 2025 
// Last Change       :   $Date: 2025-05-31 18:41:30 +0200 (Sat, 31 May 2025) $
// by                :   $Author: aydi294f $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module mux3x1 (
    input  wire [63:0] a,    // Input 0
    input  wire [63:0] b,    // Input 1
    input  wire [63:0] c,    // Input 2
    input  wire [1:0]  sel,  // 2-bit select signal
    output wire [63:0] y     // Output
);

    assign y = (sel == 2'b00) ? a :
               (sel == 2'b01) ? b :
               (sel == 2'b10) ? c :
               64'd0; // Undefined for other sel values

endmodule
