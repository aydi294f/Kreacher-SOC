// Company           :   tud                      
// Author            :   pran972e            
// E-Mail            :   <email>                    
//                    			
// Filename          :   main_decoder.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Sun Dec 29 15:27:42 2024 
// Last Change       :   $Date: 2025-05-31 17:32:42 +0200 (Sat, 31 May 2025) $
// by                :   $Author: vana158e $                  			
//------------------------------------------------------------
`timescale 1ns/10ps

module main_decoder (
    input [31:0] instruction,   // 32-bit RISC-V instruction
    input data_len_control_en,
    input interrupt_en ,
    output reg [3:0] alu_op,    // ALU operation selector
    output reg alu_src,         // ALU source selector (1 for immediate)
    output reg reg_write,       // Register write enable
    output reg mem_read,        // Memory read enable
    output reg mem_write,       // Memory write enable
    output reg branch,          // Branch control signal
    output reg csr_write,        // CSR write enable (for Zicsr instructions)
    output reg is_rtype,      //  R-type instructions
    output reg is_itype,      //  I-type instructions
    output reg is_utype,      //  U-type instructions
    output reg is_mtype,      //  M extension instructions
    output reg is_load_type, // Load instruction
    output reg is_branch_type, // Branch instruction
    output reg is_jump_type, // Jump instruction
    output reg [1:0] csr_type  , // CSR_type
    output [2:0] funct3, //  3-bit funct3 in instruction
    output [6:0] funct7 ,//  7-bit funct7 in instruction
    output [6:0] opcode,        // Opcode field
    output reg [11:0] csr_addr, // CSR address
    output reg [63:0] imm,       // 64-bit sign-extended immediate value
    output [4:0] rs1,           // Address of source register 1
    output [4:0] rs2,           // Address of source register 2
    output [4:0] rd ,            // Address of destination register
    output reg [1:0] access_size, // 2-bit input to specify access size: 00-byte, 01-halfword, 10-word
    output reg     is_unsigned  // 1 for unsigned load, 0 for signed load
);

    // Extracting fields from instruction
    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];
    
    assign rs1 = instruction[19:15];  // Source register 1
    assign rs2 = instruction[24:20];  // Source register 2
    assign rd = instruction[11:7];    // Destination register
        
    // ALU operation encoding for simplicity
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLT  = 4'b0101;
    localparam ALU_SLL  = 4'b0110;
    localparam ALU_SRL  = 4'b0111;
    localparam ALU_MUL  = 4'b1000;
    localparam ALU_DIV  = 4'b1001;
    
    localparam SYSTEM = 7'b1110011;

    always @(instruction or data_len_control_en or interrupt_en ) begin
        // Default values
        alu_op = 4'b0000;
        alu_src = 0;
        reg_write = 0;
        mem_read = 0;
        mem_write = 0;
        branch = 0;
        csr_write = 0;
        is_rtype = 0;
        is_mtype = 0;
        csr_addr = 0;
        imm = 64'b0;
        is_load_type = 0;
        is_itype = 0;
        is_branch_type = 0;
        is_jump_type = 0;
        is_utype = 0;
        access_size = 2'b11;
        is_unsigned = 0;
        csr_type = 2'b00;

        // Determine instruction width (compressed or standard)
        if (instruction[1:0] != 2'b11) begin
            // Compressed instruction (16 bits)
            case (instruction[15:13]) 
                3'b000: begin // C.ADDI4SPN or C.LI
                    if (instruction[11:7] == 5'b00010) begin
                        // C.ADDI4SPN
                        alu_op = 4'b0001;  // Add
                        alu_src = 1;
                        reg_write = 1;
                    end else begin
                        // C.LI
                        alu_op = 4'b0001;  // Add immediate
                        alu_src = 1;
                        reg_write = 1;
                    end
                end
                
                3'b010: begin // C.LW
                    alu_op = 4'b0001;  // Add for address calculation
                    alu_src = 1;
                    mem_read = 1;
                    reg_write = 1;
                end
                3'b110: begin // C.SW
                    alu_op = 4'b0001;  // Add for address calculation
                    alu_src = 1;
                    mem_write = 1;
                end

                3'b001: begin // C.JAL
                    branch = 1;
                    alu_op = 4'b0001;  // Add for PC calculation
                end

                3'b101: begin // C.J
                    branch = 1;
                    alu_op = 4'b0001;  // Add for PC calculation
                end

                3'b011: begin // C.LUI
                    alu_op = 4'b0001;  // Load upper immediate
                    alu_src = 1;
                    reg_write = 1;
                end

                // Add other compressed instruction cases here as needed

                default: begin
                    // Unsupported compressed instruction
                end
            endcase

        end else begin
            case (instruction[6:0])
                // Integer R-Type instructions (opcode = 0b0110011)
                7'b0110011: begin
                    reg_write = 1;
                    is_rtype = 1;
                    if (funct7 == 7'b0000001) begin
                        is_mtype = 1;
                    end
//                    case ({funct7, funct3})
//                        10'b0000000000: alu_op = ALU_ADD;   // add
//                        10'b0100000000: alu_op = ALU_SUB;   // sub
//                        10'b0000000111: alu_op = ALU_AND;   // and
//                        10'b0000000110: alu_op = ALU_OR;    // or
//                        10'b0000000100: alu_op = ALU_XOR;   // xor
//                        10'b0000000010: alu_op = ALU_SLT;   // slt
//                        10'b0000000001: alu_op = ALU_SLL;   // sll
//                        10'b0000000101: alu_op = ALU_SRL;   // srl
//                        10'b0000001000: alu_op = ALU_MUL;   // mul (from M extension)
//                        10'b0000001001: alu_op = ALU_DIV;   // div (from M extension)
//                        default: alu_op = 4'b0000;
//                    endcase
                end

                // Integer I-Type instructions (opcode = 0b0010011)
                7'b0010011: begin
                    reg_write = 1;
                    alu_src = 1;
                    is_itype = 1;
                    // Extract and sign-extend immediate
                    imm = {{52{instruction[31]}}, instruction[31:20]};
                    case (instruction[14:12])
                        3'b000: alu_op = ALU_ADD;           // addi
                        3'b111: alu_op = ALU_AND;           // andi
                        3'b110: alu_op = ALU_OR;            // ori
                        3'b100: alu_op = ALU_XOR;           // xori
                        3'b010: alu_op = ALU_SLT;           // slti
                        3'b001: alu_op = ALU_SLL;           // slli
                        3'b101: alu_op = (funct7[5]) ? ALU_SRL : ALU_SRL; // srli / srai
                        default: alu_op = 4'b0000;
                    endcase
                end
                
                // JALR I-Type instructions (opcode = 0b1100111)
                7'b1100111: begin
                    is_jump_type = 1;
                    // Extract and sign-extend immediate
                    imm = {{52{instruction[31]}}, instruction[31:20]};
                end

                // Load instructions (opcode = 0b0000011)
                7'b0000011: begin
                    reg_write = 1;
                    mem_read = 1;
                    alu_src = 1;
                    alu_op = ALU_ADD; // Using add to calculate address
                    is_load_type = 1;
                    imm = {{52{instruction[31]}},instruction[31:20]};
                    if (data_len_control_en) begin
						case (instruction[14:12])
							3'b000: begin 
									access_size = 2'b00 ;
									is_unsigned = 1'b0 ; 
									end        // lb
							3'b001: begin 
									access_size = 2'b01 ;
									is_unsigned = 1'b0 ; 
									end               // lh
							3'b010: begin 
									access_size = 2'b10 ;
									is_unsigned = 1'b0 ; 
									end               // lw
							3'b011: begin 
									access_size = 2'b11 ;
									is_unsigned = 1'b0 ; 
									end               // ld
							3'b100: begin 
									access_size = 2'b00 ;
									is_unsigned = 1'b1 ; 
									end               // lbu
							3'b101: begin 
									access_size = 2'b01 ;
									is_unsigned = 1'b1 ; 
									end               // lhu
							3'b110: begin 
									access_size = 2'b10 ;
									is_unsigned = 1'b1 ; 
									end               // lwu
							default: begin 
									access_size = 2'b11 ;
									is_unsigned = 1'b0 ; 
									end    
						endcase
                    end
                end

                // Store instructions (opcode = 0b0100011)
                7'b0100011: begin
                    mem_write = 1;
                    alu_src = 1;
                    alu_op = ALU_ADD; // Using add to calculate address
                    is_load_type = 1;
                    imm = {{52{instruction[31]}}, instruction[31:25], instruction[11:7]};
                    if (data_len_control_en) begin
						case (instruction[14:12])
							3'b000: begin 
									access_size = 2'b00 ;
									is_unsigned = 1'b0 ; 
									end        // sb
							3'b001: begin 
									access_size = 2'b01 ;
									is_unsigned = 1'b0 ; 
									end               // sh
							3'b010: begin 
									access_size = 2'b10 ;
									is_unsigned = 1'b0 ; 
									end               // sw
							3'b011: begin 
									access_size = 2'b11 ;
									is_unsigned = 1'b0 ; 
									end               // sd
							default: begin 
									access_size = 2'b11 ;
									is_unsigned = 1'b0 ; 
									end    
						endcase
                    end
                end
               // Branch instructions (opcode = 0b1100011)
                7'b1100011: begin
                    branch = 1;
                    // Extract and sign-extend immediate
                    imm = {{51{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                    is_branch_type = 1;
                    case (instruction[14:12])
                        3'b000: alu_op = ALU_SUB;           // beq
                        3'b001: alu_op = ALU_SUB;           // bne
                        3'b100: alu_op = ALU_SLT;           // blt
                        3'b101: alu_op = ALU_SLT;           // bge
                        3'b110: alu_op = ALU_SLT;           // bltu
                        3'b111: alu_op = ALU_SLT;           // bgeu
                        default: alu_op = 4'b0000;
                    endcase
                end
                
                // U-Type instructions
                7'b0110111, 7'b0010111: begin
                    reg_write = 1;
                    alu_src = 1;
                    is_utype = 1;
                    // Extract and sign-extend immediate
                    imm = {{32{instruction[31]}}, instruction[31:12], 12'b0};
                end

                // J-Type instructions
                7'b1101111: begin
                    reg_write = 1;
                    branch = 1;
                    is_jump_type = 1;
                    // Extract and sign-extend immediate
                    imm = {{43{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                end

                // CSR Instructions (Zicsr extension, opcode = 0b1110011)
                SYSTEM: begin
                    csr_write = 1;
                    csr_addr = instruction[31:20];
                    imm = {{59{1'b0}}, instruction[19:15]};
                    case (instruction[14:12])
                        3'b001,3'b101: csr_type = 2'b00 ;          // CSRRW (CSR Read-Write)
                        3'b010,3'b110: csr_type = 2'b01;         // CSRRS (CSR Read-Set)
                        3'b011,3'b111:  csr_type = 2'b10 ;         // CSRRC (CSR Read-Clear)
                        default:  csr_type = 2'b00;
                    endcase
                end

                // Default case for other opcodes
                default: begin
                    alu_op = 4'b0000;
                    reg_write = 0;
                    mem_read = 0;
                    mem_write = 0;
                    branch = 0;
                    csr_write = 0;
                end
            endcase
			 // Add Interrupt instructions like MRET (Machine Return from Trap), WFI (Wait For Interrupt).
        end
		if (interrupt_en == 1'b1 )begin
		      csr_type = 2'b11 ;
		      //csr_addr = 12'h341;
		      csr_addr = 12'h305;
		end                         
    end
endmodule
