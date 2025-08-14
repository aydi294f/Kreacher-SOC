// Company           :   tud                      
// Author            :   aydi294f            
// E-Mail            :   <email>                    
//                    			
// Filename          :   csr_reg.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Sun Nov 24 18:04:45 2024 
// Last Change       :   $Date: 2025-05-31 20:58:47 +0200 (Sat, 31 May 2025) $
// by                :   $Author: aydi294f $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module csr_reg (
    input               clk_i,        // Clock signal
    input               rst_i,        // Active-low reset signal
    input      [11:0]   csr_addr_i,   // CSR address
    input      [63:0]   csr_wdata_i,  // Data to write to CSR
    input               csr_we_i,     // Write enable for CSRs
    input		[1:0]	csr_type,
    
    output reg [63:0]   csr_rdata_o   // Data read from CSR
);

    // CSR addresses (12-bit as per RISC-V spec)
    localparam CSR_MSTATUS = 12'h300;
    localparam CSR_MEPC    = 12'h341;
    localparam CSR_MCAUSE  = 12'h342;
    localparam CSR_MISA    = 12'h301;
    localparam CSR_MTVEC   = 12'h305;
    
    localparam CSR_SWAP_TYPE = 2'b00;
    localparam CSR_SET_BIT_TYPE = 2'b01;
    localparam CSR_CLEAR_BIT_TYPE = 2'b10;
    localparam CSR_INTERRUPT = 2'b11;
    
    // Writable bit masks (1 = writable, 0 = read-only)
    localparam [63:0] MSTATUS_MASK = 64'hFFFFFFFFFFFFFFFF;  // Modify based on actual writable bits
    localparam [63:0] MEPC_MASK    = 64'hFFFFFFFFFFFFFFFC;  // Must be 4-byte aligned (last 2 bits are 0)
    localparam [63:0] MCAUSE_MASK  = 64'h800000000000000F;  // Only exception code and interrupt bit writable
    
    // CSR registers
    reg [63:0] mstatus;  // Machine status register
    reg [63:0] mepc;     // Machine exception program counter
    reg [63:0] mcause;   // Machine cause register
    
    // Constant values for misa and mtvec (64-bit)
    localparam [63:0] MISA_VALUE = 64'h2000000000001104;  // RV64IMC
    localparam [63:0] MTVEC_VALUE = 64'h0; // Fixed trap-vector base address
    
    // CSR write logic with bit masking
    always @(posedge clk_i or negedge rst_i) begin
        if (!rst_i) begin
            // Reset all writable CSRs to 0
            mstatus <= 64'b0;
            mepc    <= 64'b0;
            mcause  <= 64'b0;
            csr_rdata_o <= 64'b0;  // Reset the output register
        end else begin
        if (csr_we_i) begin
			case (csr_type) 
				CSR_SWAP_TYPE: case (csr_addr_i)
									CSR_MSTATUS: mstatus <= csr_wdata_i;
									CSR_MEPC:    mepc    <= csr_wdata_i;
									CSR_MCAUSE:  mcause  <= csr_wdata_i;
									default: ;  // Ignore writes to unsupported CSRs
								endcase
				CSR_SET_BIT_TYPE: case (csr_addr_i)
									CSR_MSTATUS: mstatus <= (mstatus | csr_wdata_i);
									CSR_MEPC:    mepc    <= (mepc | csr_wdata_i);
									CSR_MCAUSE:  mcause  <= (mcause | csr_wdata_i);
									default: ;  // Ignore writes to unsupported CSRs
								endcase
				CSR_CLEAR_BIT_TYPE: case (csr_addr_i)
									CSR_MSTATUS: mstatus <= (mstatus & ~csr_wdata_i);
									CSR_MEPC:    mepc    <= (mepc & ~csr_wdata_i);
									CSR_MCAUSE:  mcause  <= (mcause & ~csr_wdata_i);
									default: ;  // Ignore writes to unsupported CSRs
								endcase
			    CSR_INTERRUPT :  mepc    <= csr_wdata_i;
			    
								 
			endcase
        end
        
          case (csr_addr_i)
            CSR_MSTATUS: csr_rdata_o = mstatus & MSTATUS_MASK;
            CSR_MEPC:    csr_rdata_o = 1; //mepc & MEPC_MASK;
            //CSR_MEPC:    csr_rdata_o = mepc;
            CSR_MCAUSE:  csr_rdata_o = mcause & MCAUSE_MASK;
            CSR_MISA:    csr_rdata_o = MISA_VALUE;    // Read-only
            CSR_MTVEC:   csr_rdata_o = MTVEC_VALUE;   // Read-only
            default:     csr_rdata_o = MTVEC_VALUE;         // Unsupported CSRs return 0
        endcase
    end
  end

endmodule
