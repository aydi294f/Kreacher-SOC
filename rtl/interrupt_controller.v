// Company           :   tud                      
// Author            :   aydi294f            
// E-Mail            :   <email>                    
//                    			
// Filename          :   interrupt_controller.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Thu Feb 13 13:17:06 2025 
// Last Change       :   $Date: 2025-05-31 21:34:20 +0200 (Sat, 31 May 2025) $
// by                :   $Author: aydi294f $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module interrupt_controller (
    input  wire        clk,        // Clock signal
    input  wire        rst_n,      // Active-low reset
    input  wire [1:0]  irq,        // IRQ0, IRQ1 (from external interface)
    input  wire [1:0]  ack,        // ACK0, ACK1
    output reg  [1:0]  irq_active  // Stores active interrupts
);

reg count ;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        irq_active <= 2'b00;
    end else begin
        if (ack) begin
        irq_active <= irq_active & ~ack;
        count <= 1 ;
        end
        else if (count) begin
         irq_active <= 2'b00;
         count <= 1'b0;
         end
        else
        irq_active <= (irq_active | irq);
    end
end

endmodule

