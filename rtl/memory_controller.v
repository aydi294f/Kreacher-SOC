// Company           :   tud                      
// Author            :   vana158e            
// E-Mail            :   <email>                    
//                    			
// Filename          :   memory_controller.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Tue Jan  7 18:28:29 2025 
// Last Change       :   $Date: 2025-02-12 19:43:47 +0100 (Wed, 12 Feb 2025) $
// by                :   $Author: pran972e $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module memory_controller (
    input wire clk,                       // System clock
    input wire reset_n,                   // Active low reset

    // Core Interface
    input wire [63:0] core_addr,          // 64-bit address from the RISC-V core
    input wire [63:0] core_data_in,       // Data input from core
    input wire core_we,                   // Write enable signal from core
    input wire core_re,                   // Read enable signal from core
    input [1:0] access_size_in,
    input is_unsigned_in,
    output wire [63:0] core_data_out,     // Data output to core
    output reg data_valid,                // Signal for synchronization
    output reg ready,                     // Controller is free
    output reg mem_read_done,             // Signal to mark end of mem read

    // Init-Controller Interface
    input wire init_sel,                  // Init-Controller's SRAM/External select signal
    input wire [63:0] init_data_in,       // Data input from Init-Controller
    input wire [15:0] init_addr,          // Address input from Init-Controller
    input wire init_we,                   // Write enable signal from Init-Controller
    output wire [63:0] init_data_out,     // Data output to Init-Controller

    // SRAM Interface
    output wire sram_we,                  // Write enable to SRAM
    output wire sram_re,                  // Read enable to SRAM
    output wire [15:0] sram_addr,         // Address to SRAM
    output wire [63:0] sram_data_out,     // Data output to SRAM
    input wire [63:0] sram_data_in,       // Data input from SRAM
    output [1:0] access_size,
    output is_unsigned,

    // SPI Interface
    output wire spi_start,                // Start signal for SPI transaction
    input wire spi_ready,                 // SPI ready signal for new transaction
    output wire spi_we,                   // Write enable for SPI transaction
    output wire [16:0] spi_addr,          // Address for SPI transaction
    output wire [63:0] spi_data_out,      // Data to be sent over SPI
    input wire [63:0] spi_data_in         // Data received from SPI
);

    // Address decoding for Core
    // Extract lower 18 bits of the core's address. The upper 46 bits are ignored.
    wire [17:0] core_local_addr = core_addr[17:0];
    wire core_is_external_access = core_local_addr[17];  // External SPI access if bit 17 is set
    wire [15:0] core_sram_addr = core_local_addr[15:0];  // On-chip SRAM address

    // Address decoding for Init-Controller
    wire init_is_external_access = init_sel;             // Based on init_sel for SPI or SRAM
    wire [17:0] init_mapped_addr = {2'b00, init_addr};   // Init-Controller address mapped to 18-bits

    // Data Multiplexing for Init-Controller
    reg [63:0] selected_init_data_out;
    always @(init_is_external_access) begin
        if (init_is_external_access) begin
            selected_init_data_out = spi_data_in;        // Init-Controller accesses SPI
        end else begin
            selected_init_data_out = sram_data_in;       // Init-Controller accesses SRAM
        end
    end

    // SRAM Control Signals
    assign sram_we = (init_we && !init_is_external_access) || (core_we && !core_is_external_access);
    assign sram_re = 1;
    assign sram_addr = (init_we && !init_is_external_access) ? init_mapped_addr[15:0] : core_sram_addr;
    assign sram_data_out = (init_we && !init_is_external_access) ? init_data_in : core_data_in;
    assign access_size = access_size_in;
    assign is_unsigned = is_unsigned_in;
    reg [2:0] mem_read_wait;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            mem_read_wait <= 0;
        end else if (core_re) begin
            mem_read_wait <= mem_read_wait + 1; // Increment wait counter
            if (mem_read_wait >= 0) begin
                mem_read_done <= 1;
                mem_read_wait <= 0;
            end
        end else begin
            mem_read_done <= 0; // Deassert signal
        end
    end
    // SPI Transaction Initiation
    reg start_transaction;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            start_transaction <= 0;
        end else if ((core_we && core_is_external_access && spi_ready) ||
                     (init_we && init_is_external_access && spi_ready)) begin
            start_transaction <= 1; // Start SPI transaction
        end else if (spi_ready) begin
            start_transaction <= 0; // Clear the start signal once SPI is ready
        end
    end

    // SPI Interface Signals
    assign spi_start = start_transaction;
    assign spi_we = (init_we && init_is_external_access) || (core_we && core_is_external_access);
    assign spi_addr = (init_we && init_is_external_access) ? init_mapped_addr[16:0] : core_local_addr[16:0];
    assign spi_data_out = (init_we && init_is_external_access) ? init_data_in : core_data_in;

    // Data Output to Core
    assign core_data_out = core_is_external_access ? spi_data_in : sram_data_in;

    // Data Output to Init-Controller
    assign init_data_out = selected_init_data_out;

    // Synchronization and Status
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_valid <= 0;
            ready <= 1;
        end else begin
            data_valid <= (core_we || init_we);
            ready <= spi_ready; // Ready when SPI is not busy
        end
    end

endmodule
