// Company           :   tud                      
// Author            :   vana158e            
// E-Mail            :   <email>                    
//                    			
// Filename          :   core.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Tue Jan  7 18:19:25 2025 
// Last Change       :   $Date: 2025-05-31 21:34:20 +0200 (Sat, 31 May 2025) $
// by                :   $Author: aydi294f $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module core
   (input clk_0, input[1:0] External_Interruptrequest , input reset_0, output reg[1:0]  External_Interruptacknowledge);

  wire [63:0]IRE_q;
  wire [63:0]IR_q;
  wire [63:0]alu_0_result;
  wire [4:0]alu_decoder_0_operation;
  wire [63:0]alu_out_reg_q;
  wire clk_0_1;
  wire [63:0]csr_reg_0_csr_rdata_o;
  wire [63:0]csr_reg_0_csr_rd;
  wire [1:0]ctrl_fsm_0_csr_mux_sel;
  wire [63:0] csr_mux_0_y;
  wire ctrl_fsm_0_addr_mux_sel;
  wire ctrl_fsm_0_alu_src_1_sel;
  wire ctrl_fsm_0_alu_src_2_sel;
  wire ctrl_fsm_0_csr_w_en;
  wire ctrl_fsm_0_ir_w_en;
  wire ctrl_fsm_0_mem_r_en;
  wire ctrl_fsm_0_mem_w_en;
  wire ctrl_fsm_0_pc_en;
  wire ctrl_fsm_0_pc_curr_en;
  wire [1:0] ctrl_fsm_0_pc_src_sel;
  wire ctrl_fsm_0_clear_lsb;
  wire ctrl_fsm_0_data_len_control_en;
  wire [2:0]ctrl_fsm_0_rd_mux_sel;
  wire ctrl_fsm_0_read_mux_sel;
  wire ctrl_fsm_0_rd_w_en;
  wire ctrl_fsm_interrupt_signal;
  wire csr_reg_0_sel;
  wire [63:0]inst_rom_0_dr_int;
  wire [1:0] inst_rom_0_access_size;
  wire inst_rom_0_is_unsigned;
  wire [11:0]main_decoder_0_csr_addr;
  wire [2:0]main_decoder_0_funct3;
  wire [6:0]main_decoder_0_funct7;
  wire [63:0]main_decoder_0_imm;
  wire main_decoder_0_is_itype;
  wire main_decoder_0_is_utype;
  wire main_decoder_0_is_load_type;
  wire main_decoder_0_is_mtype;
  wire main_decoder_0_is_rtype;
  wire main_decoder_0_is_jump_type;
  wire [1:0] main_decoder_0_csr_type ;
  wire [1:0] main_decoder_0_access_size;
  wire main_decoder_0_is_unsigned;
  wire [6:0]main_decoder_0_opcode;
  wire [4:0]main_decoder_0_rd;
  wire [4:0]main_decoder_0_rs1;
  wire [4:0]main_decoder_0_rs2;
  wire [63:0]memory_controller_0_core_data_out;
  wire memory_controller_0_mem_read_done;
  wire [15:0]memory_controller_0_sram_addr;
  wire [63:0]memory_controller_0_sram_data_out;
  wire memory_controller_0_sram_re;
  wire memory_controller_0_sram_we;
  wire [63:0]mux2x1_0_y;
  wire [63:0]mux2x1_1_y;
  wire [63:0]mux2x1_2_y;
  wire [63:0]mux2x1_3_y;
  wire [63:0]mux5x1_64bit_0_out0;
  wire [63:0]pc_incr_0_pc;
  wire [63:0]program_counter_q;
  wire [63:0]program_counter_current_q;
  wire [63:0]reg_file_0_RD1;
  wire [63:0]reg_file_0_RD2;
  wire branch_check_unit_0_branch_taken;
  wire main_decoder_0_is_branch_type;
  wire reset_0_1;
  wire [2:0] interrupt_controller_irq_active;
  wire [2:0] interrupt_ack_signal ;
  wire [63:0] demux_csr_rdata_o;
  wire [63:0] demux_csr_pc;
  
  assign clk_0_1 = clk_0;
  assign reset_0_1 = reset_0;
  register_with_we IR
       (.clk(clk_0_1),
        .d(memory_controller_0_core_data_out),
        .q(IR_q),
        .reset(reset_0_1),
        .write_enable(ctrl_fsm_0_ir_w_en));

  alu alu_0
       (.operand_a(mux2x1_0_y),
        .operand_b(mux2x1_1_y),
        .operation(alu_decoder_0_operation),
        .clear_lsb(ctrl_fsm_0_clear_lsb),
        .result(alu_0_result),
        .error());
  alu_decoder alu_decoder_0
       (.funct3(main_decoder_0_funct3),
        .funct7(main_decoder_0_funct7),
        .is_itype(main_decoder_0_is_itype),
        .is_utype(main_decoder_0_is_utype),
        .is_load_type(main_decoder_0_is_load_type),
        .is_branch_type(main_decoder_0_is_branch_type),
        .is_jump_type(main_decoder_0_is_jump_type),
        .is_mtype(main_decoder_0_is_mtype),
        .is_rtype(main_decoder_0_is_rtype),
        .operation(alu_decoder_0_operation));
  register_64bit alu_out_reg
       (.clk(clk_0_1),
        .d(alu_0_result),
        .q(alu_out_reg_q),
        .reset(reset_0_1));
  csr_reg csr_reg_0
       (.clk_i(clk_0_1),
        .csr_addr_i(main_decoder_0_csr_addr),
        .csr_rdata_o(csr_reg_0_csr_rdata_o),
        .csr_wdata_i(csr_mux_0_y),
        .csr_type(main_decoder_0_csr_type) ,
        .csr_we_i(ctrl_fsm_0_csr_w_en),
        .rst_i(reset_0_1));

  ctrl_fsm ctrl_fsm_0
       (.a_reset_l(reset_0_1),
        .addr_mux_sel(ctrl_fsm_0_addr_mux_sel),
        .alu_src_1_sel(ctrl_fsm_0_alu_src_1_sel),
        .alu_src_2_sel(ctrl_fsm_0_alu_src_2_sel),
        .clk(clk_0_1),
        .csr_w_en(ctrl_fsm_0_csr_w_en),
        .ir_w_en(ctrl_fsm_0_ir_w_en),
        .mem_r_en(ctrl_fsm_0_mem_r_en),
        .mem_read_done(memory_controller_0_mem_read_done),
        .data_len_control_en(ctrl_fsm_0_data_len_control_en),
        .interrupt_en(ctrl_fsm_interrupt_signal) , 
		.alu_result(alu_0_result),
		.funct3(main_decoder_0_funct3),
		.branch_taken(branch_check_unit_0_branch_taken),
		.irq_active(interrupt_controller_irq_active),
        .mem_w_en(ctrl_fsm_0_mem_w_en),
        .opcode(main_decoder_0_opcode),
        .pc_en(ctrl_fsm_0_pc_en),
        .pc_curr_en(ctrl_fsm_0_pc_curr_en),
        .pc_src_sel(ctrl_fsm_0_pc_src_sel),
        .rd_mux_sel(ctrl_fsm_0_rd_mux_sel),
        .clear_lsb(ctrl_fsm_0_clear_lsb),
        .rd_w_en(ctrl_fsm_0_rd_w_en),
        .csr_mux_sel(ctrl_fsm_0_csr_mux_sel),
        .csr_read_mux_sel(ctrl_fsm_0_read_mux_sel),
        .csr_reg_0_sel(csr_reg_0_sel),
        .irq_ack(interrupt_ack_signal));
        
 inst_rom #(.INITFILE_LOW("./mem_low.txt"),
 	    .INITFILE_HIGH("./mem_high.txt"))inst_rom_0
       (.adr_p_mem(memory_controller_0_sram_addr),
        .clk(clk_0_1),
        .data_in(memory_controller_0_sram_data_out),
        .access_size(inst_rom_0_access_size),
        .is_unsigned(inst_rom_0_is_unsigned),
        .dr_int(inst_rom_0_dr_int),
        .prog_en_h(memory_controller_0_sram_re),
        .w_en(memory_controller_0_sram_we));
        
  main_decoder main_decoder_0
       (.csr_addr(main_decoder_0_csr_addr),
        .funct3(main_decoder_0_funct3),
        .funct7(main_decoder_0_funct7),
        .imm(main_decoder_0_imm),
        .instruction(IR_q[31:0]),
        .data_len_control_en(ctrl_fsm_0_data_len_control_en),
        .interrupt_en(ctrl_fsm_interrupt_signal) , 
        .is_itype(main_decoder_0_is_itype),
        .is_utype(main_decoder_0_is_utype),
        .is_load_type(main_decoder_0_is_load_type),
        .is_mtype(main_decoder_0_is_mtype),
        .is_rtype(main_decoder_0_is_rtype),
        .is_branch_type(main_decoder_0_is_branch_type),
        .is_jump_type(main_decoder_0_is_jump_type),
        .csr_type (main_decoder_0_csr_type) ,
        .opcode(main_decoder_0_opcode),
        .rd(main_decoder_0_rd),
        .rs1(main_decoder_0_rs1),
        .rs2(main_decoder_0_rs2),
        .access_size(main_decoder_0_access_size),
        .is_unsigned(main_decoder_0_is_unsigned));
        
  memory_controller memory_controller_0
       (.clk(clk_0_1),
        .core_addr(mux2x1_2_y),
        .core_data_in(reg_file_0_RD2),
        .core_data_out(memory_controller_0_core_data_out),
        .core_re(ctrl_fsm_0_mem_r_en),
        .core_we(ctrl_fsm_0_mem_w_en),
        .access_size_in(main_decoder_0_access_size),
        .is_unsigned_in(main_decoder_0_is_unsigned),
        .init_addr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .init_data_in({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .init_sel(1'b0),
        .init_we(1'b0),
        .mem_read_done(memory_controller_0_mem_read_done),
        .reset_n(reset_0_1),
        .spi_data_in({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .spi_ready(1'b0),
        .sram_addr(memory_controller_0_sram_addr),
        .sram_data_in(inst_rom_0_dr_int),
        .sram_data_out(memory_controller_0_sram_data_out),
        .sram_re(memory_controller_0_sram_re),
        .sram_we(memory_controller_0_sram_we),
        .access_size(inst_rom_0_access_size),
        .is_unsigned(inst_rom_0_is_unsigned));
        
  mux2x1 mux2x1_0 // Mux RS1 and PC to ALU
       (.a(reg_file_0_RD1),
        .b(program_counter_current_q),
        .sel(ctrl_fsm_0_alu_src_1_sel),
        .y(mux2x1_0_y));
        
  mux3x1 mux3x1_0 // Mux RS1 and main decoder and PC to CSR reg
       (.a(reg_file_0_RD1),
        .b(main_decoder_0_imm),
        .c(program_counter_current_q),
        .sel(ctrl_fsm_0_csr_mux_sel),
        .y(csr_mux_0_y));
        
  mux2x1 mux2x1_1 // Mux RS2 and Main decoder ( Immediate ) to ALU
       (.a(reg_file_0_RD2),
        .b(main_decoder_0_imm),
        .sel(ctrl_fsm_0_alu_src_2_sel),
        .y(mux2x1_1_y));
        
  mux2x1 mux2x1_2 // Mux ALU out  and PC next to Mem controller
       (.a(alu_out_reg_q),
        .b(program_counter_q),
        .sel(ctrl_fsm_0_addr_mux_sel),
        .y(mux2x1_2_y));

      
  demux1x2 demux1x2_0  // Demux the read out from CSR reg to PC and rv reg
	   (.y0(demux_csr_pc),
		.y1(demux_csr_rdata_o),
		.sel(csr_reg_0_sel),
		.a(csr_reg_0_csr_rdata_o));
        
  mux5x1_64bit mux5x1_64bit_0 // Main mux to RV reg
       (.in0(demux_csr_rdata_o),
        .in1(program_counter_q),
        .in2(memory_controller_0_core_data_out),
        .in3(alu_out_reg_q),
        .in4(main_decoder_0_imm),
        .out0(mux5x1_64bit_0_out0),
        .sel(ctrl_fsm_0_rd_mux_sel));
  pc_incr pc_incr_0
       (.clk(clk_0_1),
        .pc(pc_incr_0_pc), // look
        .pc_in(program_counter_q),
        .reset(reset_0_1));
  register_with_we program_counter
       (.clk(clk_0_1),
        .d(mux2x1_3_y),
        .q(program_counter_q),
        .reset(reset_0_1),
        .write_enable(ctrl_fsm_0_pc_en));
        
  mux3x1 mux3x1_1 // Mux CSR , increment and alu out  to PC next
       (.a(pc_incr_0_pc),
        .b(alu_0_result),
        .c(demux_csr_pc),
        .sel(ctrl_fsm_0_pc_src_sel),
        .y(mux2x1_3_y));
        
        
   register_with_we program_counter_current
       (.clk(clk_0_1),
        .d(program_counter_q),
        .q(program_counter_current_q),
        .reset(reset_0_1),
        .write_enable(ctrl_fsm_0_pc_curr_en));
  reg_file reg_file_0
       (.A1(main_decoder_0_rs1),
        .A2(main_decoder_0_rs2),
        .A3(main_decoder_0_rd),
        .RD1(reg_file_0_RD1),
        .RD2(reg_file_0_RD2),
        .WD3(mux5x1_64bit_0_out0),
        .WE3(ctrl_fsm_0_rd_w_en),
        .clk_i(clk_0_1),
        .rst_i(reset_0_1));
  branch_check_unit branch_check_unit_0
		(.rs1_data(reg_file_0_RD1),
		.rs2_data(reg_file_0_RD2),
		.funct3(main_decoder_0_funct3),
		.branch_taken(branch_check_unit_0_branch_taken)
		);
 interrupt_controller interrupt_controller_0 (
    .clk(clk_0_1), 
    .rst_n(reset_0),
    .irq(External_Interruptrequest),        
    .ack(interrupt_ack_signal),        
    .irq_active(interrupt_controller_irq_active)  
);
endmodule 

