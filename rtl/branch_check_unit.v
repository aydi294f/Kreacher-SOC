// Company           :   tud                      
// Author            :   pran972e            
// E-Mail            :   <email>                    
//                    			
// Filename          :   branch_check_unit.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Sat Feb  8 16:50:55 2025 
// Last Change       :   $Date: 2025-02-08 19:45:36 +0100 (Sat, 08 Feb 2025) $
// by                :   $Author: pran972e $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module branch_check_unit (
	input  wire [31:0] rs1_data,       // Data from source register 1
    input  wire [31:0] rs2_data,       // Data from source register 2
    input  wire [2:0]  funct3,         // funct3 field from the instruction to identify the branch type
    output reg         branch_taken    // Control signal: 1 if branch is taken, 0 otherwise
);

	// funct3 encoding for RISC-V branch instructions
    localparam BEQ  = 3'b000;  // Branch if Equal
    localparam BNE  = 3'b001;  // Branch if Not Equal
    localparam BLT  = 3'b100;  // Branch if Less Than (signed)
    localparam BGE  = 3'b101;  // Branch if Greater Than or Equal (signed)
    localparam BLTU = 3'b110;  // Branch if Less Than (unsigned)
    localparam BGEU = 3'b111;  // Branch if Greater Than or Equal (unsigned)

    always @(rs1_data or rs2_data or funct3) begin
        case (funct3)
            BEQ:  branch_taken = (rs1_data == rs2_data);                              // Equal
            BNE:  branch_taken = (rs1_data != rs2_data);                              // Not Equal
            BLT:  branch_taken = ($signed(rs1_data) < $signed(rs2_data));             // Signed Less Than
            BGE:  branch_taken = ($signed(rs1_data) >= $signed(rs2_data));            // Signed Greater Than or Equal
            BLTU: branch_taken = (rs1_data < rs2_data);                               // Unsigned Less Than
            BGEU: branch_taken = (rs1_data >= rs2_data);                              // Unsigned Greater Than or Equal
            default: branch_taken = 1'b0;                                             // Default: No branch
        endcase
    end

endmodule
