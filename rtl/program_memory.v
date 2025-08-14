// Company           :   tud                      
// Author            :   yash913e            
// E-Mail            :   <email>                    
//                    			
// Filename          :   program_memory.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Wed Jan  8 17:12:24 2025 
// Last Change       :   $Date: 2025-01-08 18:15:11 +0100 (Wed, 08 Jan 2025) $
// by                :   $Author: yash913e $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module program_memory (
    input            clk,
    input            prog_en_h,
    input            w_en,
    input      [15:0] adr_p_mem,  // 16-bit address input
    input      [63:0] data_in,    // 64-bit data input for write operations
    output     [63:0] data_out    // 64-bit data output for read operations
);

    parameter INITFILE_LOW [7:0] = {
        "none_0_low", "none_1_low", "none_2_low", "none_3_low",
        "none_4_low", "none_5_low", "none_6_low", "none_7_low"
    };

    parameter INITFILE_HIGH [7:0] = {
        "none_0_high", "none_1_high", "none_2_high", "none_3_high",
        "none_4_high", "none_5_high", "none_6_high", "none_7_high"
    };

    // Split 16-bit address into block select and local address within a block
    wire [2:0] block_sel = adr_p_mem[12:10];  // Select among 8 blocks
    wire [9:0] local_addr = adr_p_mem[9:0];   // Address within each block

    // Split 64-bit data input into 32-bit chunks for each bank
    wire [31:0] data_in_low = data_in[31:0];
    wire [31:0] data_in_high = data_in[63:32];

    // Combine 32-bit outputs from the active block
    wire [31:0] dr_low [7:0];
    wire [31:0] dr_high [7:0];

    // Multiplex outputs from the active memory block
    assign data_out = {dr_high[block_sel], dr_low[block_sel]};

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : memory_blocks
            HM_1P_GF28SLP_1024x32_1cr #(
                .INITFILE(INITFILE_LOW[i])
            ) memory_low (
                .CLK_I  (clk),                 // Clock input
                .ADDR_I (local_addr),          // Local address
                .DW_I   (data_in_low),         // Data input for write
                .BM_I   (32'hFFFFFFFF),        // Byte mask (full mask for all bytes)
                .WE_I   (w_en && prog_en_h && (block_sel == i)), // Write enable for this block
                .RE_I   (prog_en_h),           // Read enable
                .CS_I   (prog_en_h && (block_sel == i)), // Chip select for this block
                .DR_O   (dr_low[i]),           // Data output for lower 32 bits
                .DLYL   (2'h0),                // Delay low (unused)
                .DLYH   (2'h0),                // Delay high (unused)
                .DLYCLK (2'h0)                 // Delay clock (unused)
            );

            HM_1P_GF28SLP_1024x32_1cr #(
                .INITFILE(INITFILE_HIGH[i])
            ) memory_high (
                .CLK_I  (clk),                 // Clock input
                .ADDR_I (local_addr),          // Local address
                .DW_I   (data_in_high),        // Data input for write
                .BM_I   (32'hFFFFFFFF),        // Byte mask (full mask for all bytes)
                .WE_I   (w_en && prog_en_h && (block_sel == i)), // Write enable for this block
                .RE_I   (prog_en_h),           // Read enable
                .CS_I   (prog_en_h && (block_sel == i)), // Chip select for this block
                .DR_O   (dr_high[i]),          // Data output for higher 32 bits
                .DLYL   (2'h0),                // Delay low (unused)
                .DLYH   (2'h0),                // Delay high (unused)
                .DLYCLK (2'h0)                 // Delay clock (unused)
            );
        end
    endgenerate

endmodule
