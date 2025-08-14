// Company           :   tud                      
// Author            :   aydi294f            
// E-Mail            :   <email>                    
//                    			
// Filename          :   demux1x2.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Sat May 31 16:24:00 2025 
// Last Change       :   $Date: 2025-05-31 18:41:30 +0200 (Sat, 31 May 2025) $
// by                :   $Author: aydi294f $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module demux1x2 (
    input  wire [63:0] a,
    input  wire sel,
    output wire [63:0] y0,
    output wire [63:0] y1
);

    assign y0 = (~sel) ? a : 64'b0;
    assign y1 = ( sel) ? a : 64'b0;

endmodule
