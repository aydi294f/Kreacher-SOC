// Company           :   tud                      
// Author            :   vana158e            
// E-Mail            :   <email>                    
//                    			
// Filename          :   alu_decoder.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   The alu_decoder module is responsible for decoding the ALU specific instructions           
//
// Create Date       :   Sat Jan  4 13:07:51 2025 
// Last Change       :   $Date: 2025-02-09 22:02:41 +0100 (Sun, 09 Feb 2025) $
// by                :   $Author: pran972e $                  			
//------------------------------------------------------------
`timescale 1ns/10ps

module alu_decoder (
    input is_rtype,      //  R-type instructions
    input is_itype,      //  I-type instructions
    input is_utype,      //  U-type instructions
    input is_mtype,      //  M extension instructions
    input is_load_type, // load instruction
    input is_branch_type, // branch instruction
    input is_jump_type, // jump instruction
    input [2:0] funct3, //  3-bit funct3 in instruction
    input [6:0] funct7, //  7-bit funct7 in instruction
    output reg [4:0] operation //  determines the operation
);

    //  parameter definition for different instructions

    // 32-bit I extension instructions
    
    //  R-type arithmetic operations
    localparam ALU_ADD  = 5'b00000;
    localparam ALU_SUB  = 5'b00001;

    //  R-type logical operations
    localparam ALU_AND  = 5'b00010;
    localparam ALU_OR   = 5'b00011;
    localparam ALU_XOR  = 5'b00100;
    
    //  R-type comparison operations
    localparam ALU_SLT  = 5'b00101;
    localparam ALU_SLTU = 5'b00110;
    
    //  R-type shift operations
    localparam ALU_SLL  = 5'b00111;
    localparam ALU_SRL  = 5'b01000;
    localparam ALU_SRA  = 5'b01001;
    
    // 32-bit M extension operations

    // Multiplication operations
    localparam ALU_MUL  = 5'b01010;
    localparam ALU_MULH  = 5'b01011;
    localparam ALU_MULHSU  = 5'b01100;
    localparam ALU_MULHU  = 5'b01101;

    //  Division operations
    localparam ALU_DIV  = 5'b01110;
    localparam ALU_DIVU  = 5'b01111;

    //  Remainder operations
    localparam ALU_REM  = 5'b10000;
    localparam ALU_REMU  = 5'b10001;

    // 64-bit I extension operations
    
    //  R-type arithmetic operations
    localparam ALU_ADDW  = 5'b10010;
    localparam ALU_SUBW  = 5'b10011;

    //  R-type shift operations  
    localparam ALU_SLLW  = 5'b10100;
    localparam ALU_SRLW  = 5'b10101;
    localparam ALU_SRAW  = 5'b10110;

    // 64-bit M extension operations

    // Multiplication operation
    localparam ALU_MULW  = 5'b10111;

    //  Division operations
    localparam ALU_DIVW  = 5'b11000;
    localparam ALU_DIVUW  = 5'b11001;

    //  Remainder operations
    localparam ALU_REMW  = 5'b11010;
    localparam ALU_REMUW  = 5'b11011;
    
    always @(is_rtype or is_itype or is_mtype or is_load_type or is_jump_type or funct3 or funct7) begin

        if (is_rtype) begin
            if (funct3 == 3'b000 && funct7 == 7'b0000000) begin
                operation = ALU_ADD;
            end
            else if (funct3 == 3'b000 && funct7 == 7'b0100000) begin
                operation = ALU_SUB;
            end
            else if (funct3 == 3'b001 && funct7 == 7'b0000000) begin
                operation = ALU_SLL;
            end
            else if (funct3 == 3'b010 && funct7 == 7'b0000000) begin
                operation = ALU_SLT;
            end
            else if (funct3 == 3'b011 && funct7 == 7'b0000000) begin
                operation = ALU_SLTU;
            end
            else if (funct3 == 3'b100 && funct7 == 7'b0000000) begin
                operation = ALU_XOR;
            end
            else if (funct3 == 3'b101 && funct7 == 7'b0000000) begin
                operation = ALU_SRL;
            end
            else if (funct3 == 3'b101 && funct7 == 7'b0100000) begin
                operation = ALU_SRA;
            end
            else if (funct3 == 3'b110 && funct7 == 7'b0000000) begin
                operation = ALU_OR;
            end
            else if (funct3 == 3'b111 && funct7 == 7'b0000000) begin
                operation = ALU_AND;
            end
            else begin
                operation = 5'bXXXXX;    // default case for undefined operation
            end
        end

        else if (is_itype) begin
            if (funct3 == 3'b000) begin
                operation = ALU_ADD;     // ADDI operation
            end
            else if (funct3 == 3'b010) begin
                operation = ALU_SLT;     // SLTI operation
            end
            else if (funct3 == 3'b011) begin
                operation = ALU_SLTU;    // SLTIU operation
            end
            else if (funct3 == 3'b100) begin
                operation = ALU_XOR;     // XORI operation
            end
            else if (funct3 == 3'b110) begin
                operation = ALU_OR;      // ORI operation
            end
            else if (funct3 == 3'b111) begin
                operation = ALU_AND;     // ANDI operation
            end
            else if (funct3 == 3'b001 && funct7 == 7'b0000000) begin
                operation = ALU_SLL;     // SLLI operation
            end
            else if (funct3 == 3'b101 && funct7 == 7'b0000000) begin
                operation = ALU_SRL;     // SRLI operation
            end
            else if (funct3 == 3'b101 && funct7 == 7'b0100000) begin
                operation = ALU_SRA;     // SRAI operation
            end
            else begin
                operation = 5'bXXXXX;    // default case for undefined operation
            end
        end

        else if (is_mtype) begin
            if (funct3 == 3'b000) begin
                operation = ALU_MUL;
            end
            else if (funct3 == 3'b001) begin
                operation = ALU_MULH;
            end
            else if (funct3 == 3'b010) begin
                operation = ALU_MULHSU;
            end
            else if (funct3 == 3'b011) begin
                operation = ALU_MULHU;
            end
            else if (funct3 == 3'b100) begin
                operation = ALU_DIV;
            end
            else if (funct3 == 3'b101) begin
                operation = ALU_DIVU;
            end
            else if (funct3 == 3'b110) begin
                operation = ALU_REM;
            end
            else if (funct3 == 3'b111) begin
                operation = ALU_REMU;
            end
            else begin
                operation = 5'bXXXXX;    // default case for undefined operation
                end
        end
        
        else if (is_load_type) begin
            operation = ALU_ADD;
        end
        
        else if (is_branch_type) begin
            operation = ALU_ADD;
        end
        
        else if (is_jump_type) begin
            operation = ALU_ADD;
        end
        
        else if (is_utype) begin
            operation = ALU_ADD;
        end

        else begin
            operation = 5'bXXXXX;    // default case for undefined operation
        end

    end

endmodule
    
    
