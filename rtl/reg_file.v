// Company           :   tud                      
// Author            :   aydi294f            
// E-Mail            :   <email>                    
//                    			
// Filename          :   reg_file.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Wed Nov 20 14:35:53 2024 
// Last Change       :   $Date: 2025-02-08 13:57:27 +0100 (Sat, 08 Feb 2025) $
// by                :   $Author: aydi294f $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module reg_file(
    input          clk_i,
    input          rst_i,   // Active high reset
    input          WE3,     // Write enable signal 
    input [4 : 0]  A1,      // Address for Rs1
    input [4 : 0]  A2,      // Address for Rs2
    input [4 : 0]  A3,      // Address_rd
    
    input [63: 0]  WD3,     // Rd                                                                                                    
    
    output [63: 0] RD1,     // Rs1
    output [63: 0] RD2      // Rs2
);

    reg [63:0] Register [31:0]; // 32 registers, each 64 bits wide
    integer i;

    // Write logic with reset
    always @ (posedge clk_i or negedge rst_i)
    begin
        if (!rst_i) begin
            for (i = 0; i < 32; i = i + 1)
                Register[i] <= 64'd0;  // Clear all registers
        end 
        else if (WE3 && A3 != 5'd0) begin
            Register[A3] <= WD3;       // Write data to Register[A3], ignore if A3 == 0
        end
    end

    // Read logic
    assign RD1 = (!rst_i) ? 64'd0 : Register[A1];
    assign RD2 = (!rst_i) ? 64'd0 : Register[A2];

endmodule
