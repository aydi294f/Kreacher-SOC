// Company           :   tud                      
// Author            :   vana158e            
// E-Mail            :   <email>                    
//                    			
// Filename          :   inst_rom.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Tue Jan  7 18:23:54 2025 
// Last Change       :   $Date: 2025-02-12 19:43:47 +0100 (Wed, 12 Feb 2025) $
// by                :   $Author: pran972e $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module inst_rom (
    input            clk,
    input            prog_en_h,
    input            w_en,
    input      [15:0] adr_p_mem,  // 16-bit address input
    input      [63:0] data_in,    // 64-bit data input for write operations
    input      [1:0]  access_size, // 2-bit input to specify access size: 00-byte, 01-halfword, 10-word
    input             is_unsigned,  // 1 for unsigned load, 0 for signed load
    output   reg  [63:0] dr_int      // 64-bit data output for read operations
);

    parameter INITFILE_LOW = "none_low";  // Initialization file for low 32 bits
    parameter INITFILE_HIGH = "none_high"; // Initialization file for high 32 bits

    // Split 64-bit data input into high and low 32-bit parts
    wire [31:0] data_in_low = data_in[31:0];
    wire [31:0] data_in_high = data_in[63:32];

    // Outputs from the two memory blocks
    wire [31:0] dr_low;
    wire [31:0] dr_high;

    // Combine the outputs of the two memories into a 64-bit output
    //	assign dr_int = {dr_high, dr_low};

    // Byte mask generation logic
    wire [3:0] byte_sel_low = (adr_p_mem[1:0] == 2'b00) ? 4'b0001 :
                              (adr_p_mem[1:0] == 2'b01) ? 4'b0010 :
                              (adr_p_mem[1:0] == 2'b10) ? 4'b0100 :
                              4'b1000;

    wire [3:0] byte_sel_high = (adr_p_mem[1:0] == 2'b00) ? 4'b0001 :
                               (adr_p_mem[1:0] == 2'b01) ? 4'b0010 :
                               (adr_p_mem[1:0] == 2'b10) ? 4'b0100 :
                               4'b1000;

    wire [31:0] byte_mask_low = (access_size == 2'b00) ? {8{byte_sel_low[3], byte_sel_low[2], byte_sel_low[1], byte_sel_low[0]}} :
                                (access_size == 2'b01) ? (adr_p_mem[1] == 1'b0 ? 32'h0000FFFF : 32'hFFFF0000) :
                                32'hFFFFFFFF;

    wire [31:0] byte_mask_high = (access_size == 2'b00) ? {8{byte_sel_high[3], byte_sel_high[2], byte_sel_high[1], byte_sel_high[0]}} :
                                 (access_size == 2'b01) ? (adr_p_mem[1] == 1'b0 ? 32'h0000FFFF : 32'hFFFF0000) :
                                 32'hFFFFFFFF;

    // Instance for lower 32 bits
    HM_1P_GF28SLP_1024x32_1cr #(
        .INITFILE(INITFILE_LOW)
    ) memory_low (
        .CLK_I  (clk),                 // Clock input
        .ADDR_I (adr_p_mem[9:0]),     // Address input (ignoring lowest 2 bits for word alignment)
        .DW_I   (data_in_low),         // Data input for write
        .BM_I   (byte_mask_low),       // Byte mask
        .WE_I   (w_en && prog_en_h),   // Write enable
        .RE_I   (prog_en_h),           // Read enable
        .CS_I   (prog_en_h),           // Chip select
        .DR_O   (dr_low),              // Data output for lower 32 bits
        .DLYL   (2'h0),                // Delay low (unused)
        .DLYH   (2'h0),                // Delay high (unused)
        .DLYCLK (2'h0)                 // Delay clock (unused)
    );

    // Instance for higher 32 bits
    HM_1P_GF28SLP_1024x32_1cr #(
        .INITFILE(INITFILE_HIGH)
    ) memory_high (
        .CLK_I  (clk),                 // Clock input
        .ADDR_I (adr_p_mem[9:0]),     // Address input (same as lower memory)
        .DW_I   (data_in_high),        // Data input for write
        .BM_I   (byte_mask_high),      // Byte mask
        .WE_I   (w_en && prog_en_h),   // Write enable
        .RE_I   (prog_en_h),           // Read enable
        .CS_I   (prog_en_h),           // Chip select
        .DR_O   (dr_high),             // Data output for higher 32 bits
        .DLYL   (2'h0),                // Delay low (unused)
        .DLYH   (2'h0),                // Delay high (unused)
        .DLYCLK (2'h0)                 // Delay clock (unused)
    );
    
    // Read data selection logic based on access size and signed/unsigned
    always @(access_size or dr_low or dr_high) begin
        case (access_size)
            2'b00: // Byte
                dr_int = (is_unsigned) ? {56'b0, dr_low[7:0]} : {{56{dr_low[7]}}, dr_low[7:0]};
            2'b01: // Half-Word
                dr_int = (is_unsigned) ? {48'b0, dr_low[15:0]} : {{48{dr_low[15]}}, dr_low[15:0]};
            2'b10: // Word
                dr_int = {32'b0, dr_low}; // Zero-extend lower 32 bits to 64 bits
            2'b11: // Double Word
                dr_int = {dr_high, dr_low}; // Full 64-bit data
            default:
                dr_int = 64'b0;
        endcase
    end

endmodule

