
// Company           :   tud                      
// Author            :   aydi294f            
// E-Mail            :   <email>                    
//                    			
// Filename          :   ctrl_fsm.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Thu Dec 12 11:33:50 2024 
// Last Change       :   $Date: 2025-05-31 21:34:20 +0200 (Sat, 31 May 2025) $
// by                :   $Author: aydi294f $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module ctrl_fsm (       
	input		    clk,
	input		    a_reset_l,
	input [6:0] 	opcode,
	input           mem_read_done,
	input [63:0]    alu_result,
	input [2:0]     funct3,
	input           branch_taken,
    input [1:0]     irq_active ,
    
	output reg             pc_en,
	output reg             pc_curr_en,
	output reg             alu_src_1_sel,
	output reg             alu_src_2_sel,
	output reg  [2:0]      rd_mux_sel,
	output reg             rd_w_en,
	output reg             mem_w_en,
	output reg             mem_r_en,
	output reg   [1:0]     pc_src_sel,
	output reg             ir_w_en,
	output reg             addr_mux_sel,
	output reg			   clear_lsb,
	output reg             csr_w_en,
	output reg             data_len_control_en,
	output reg             interrupt_en , 
	output reg   [1:0]     csr_mux_sel  ,       
	output reg             csr_read_mux_sel , // remove later is floating now 
	output reg             csr_reg_0_sel ,
	output reg    [1:0]    irq_ack  );

   reg [4:0] 	current_state;
   reg [4:0] 	next_state;
   
   reg branch_or_jump_taken;
   reg count ;
   
   parameter S_INIT                = 5'b00000;
   parameter S_FETCH               = 5'b00001; 
   parameter S_DECODE              = 5'b00010; 
   parameter S_EXEC_R_TYPE         = 5'b00011;
   parameter S_EXEC_I_TYPE         = 5'b00100;
   parameter S_EXEC_LOAD           = 5'b00101;
   parameter S_EXEC_STORE          = 5'b00110;
   parameter S_EXEC_BRANCH         = 5'b00111;
   parameter S_EXEC_JAL            = 5'b01000;
   parameter S_EXEC_JALR           = 5'b01001;
   parameter S_EXEC_CSR_READ       = 5'b01010;
   parameter S_MEM_READ            = 5'b01011;
   parameter S_MEM_WRITE           = 5'b01100;
   parameter S_WRITEBACK           = 5'b01101;
   parameter S_BRANCH_CHECK        = 5'b01111;
   parameter S_EXEC_LUI        	   = 5'b10000;
   parameter S_EXEC_AUIPC      	   = 5'b10001;
   parameter S_EXEC_CSR_WRITE      = 5'b10010;
   parameter S_INTERRUPT_ZERO      = 5'b10011;
   parameter S_INTERRUPT_ONE       = 5'b10100;
   parameter S_INTERRUPT_ZERO_LOAD_ADDRESS = 5'b10101;
   parameter S_INTERRUPT_ONE_LOAD_ADDRESS = 5'b10110;
   
   always @(posedge clk or negedge a_reset_l)
	 begin
		if (a_reset_l == 1'b0)
		  begin
			 current_state <= S_INIT;
		  end
		else
		  begin
			 current_state <= next_state;
		  end
	 end
   
   always @(current_state or opcode or mem_read_done or irq_active)
	 begin
			pc_en         = 1'b0;
			alu_src_1_sel = 1'b0;
			alu_src_2_sel = 1'b0;
			rd_mux_sel    = 3'b000;
			rd_w_en       = 1'b0;
			mem_w_en      = 1'b0;
			mem_r_en      = 1'b0;
			pc_src_sel    = 2'b00;
			ir_w_en       = 1'b0;
			addr_mux_sel  = 1'b0;
            csr_w_en      = 1'b0;
            pc_curr_en    = 1'b0;
            clear_lsb	  = 1'b0;
            csr_mux_sel   = 2'b00;
			csr_read_mux_sel = 1'b0;
            interrupt_en  = 1'b0;
            csr_reg_0_sel = 1'b1;
            irq_ack       = 2'b00;
           
  
           next_state = current_state;
	   
  
           case (current_state)
	         S_INIT: 
		          begin
                             data_len_control_en = 1'b0;
                             next_state = S_FETCH;
                          end
			 S_FETCH :
					  begin
				                 csr_mux_sel   = 2'b00;
								 addr_mux_sel= 1'b1; 
								 mem_r_en = 1;
								 pc_en = 1'b0;
								 pc_curr_en = 1'b1;
								 rd_w_en = 0;
								 data_len_control_en = 1'b0;	// look later
								 interrupt_en  = 1'b0;
													 
								if (irq_active != 2'b00) begin
								         pc_curr_en = 1'b1;
								         mem_r_en = 1'b0;
								         
								         interrupt_en  = 1'b1;
								        
										case (irq_active)
										    2'b01:       begin
										                 if(count) next_state = S_INTERRUPT_ONE ;
										                 else  next_state = S_INTERRUPT_ONE_LOAD_ADDRESS;  
										                 end
											2'b10, 2'b11: begin
											             if(count) next_state = S_INTERRUPT_ZERO ;
										                 else  next_state = S_INTERRUPT_ZERO_LOAD_ADDRESS;  
										                 end
											default:      next_state = S_FETCH; 
										endcase
								end

								 else if (mem_read_done == 1) begin
											next_state = S_DECODE;
											mem_r_en = 0;
											rd_w_en = 1'b0;
											ir_w_en     = 1'b1;
											pc_en = 1'b1;
											pc_curr_en = 1'b0;
											if (!branch_or_jump_taken) begin
												pc_en = 1'b1; // Increment PC only if no branch or jump was taken
											end
											branch_or_jump_taken = 1'b0; // Reset the flag
											pc_src_sel    = 2'b00; // look later
								 end      
							  end
			 S_DECODE : 
				  begin
				   pc_en       = 1'b0;  
				   data_len_control_en = 1'b1;
				   ir_w_en     = 1'b0;
				case (opcode)
							   7'h00: next_state = S_DECODE; // Wait for valid opcode
							   7'h33: next_state = S_EXEC_R_TYPE; // R-type (0110011)
							   7'h13: next_state = S_EXEC_I_TYPE; // I-type (0010011)
							   7'h03: next_state = S_EXEC_LOAD;   // Load    (0000011)
							   7'h23: next_state = S_EXEC_STORE;  // Store   (0100011)
							   7'h63: next_state = S_BRANCH_CHECK; // Branch  (1100011)
							   7'h6F: next_state = S_EXEC_JAL;    // JAL     (1101111)
							   7'h67: next_state = S_EXEC_JALR;   // JALR    (1100111)
							   7'h37: next_state = S_EXEC_LUI;   // LUI    (0110111)
							   7'h17: next_state = S_EXEC_AUIPC;   // AUIPC    (0010111)
							   7'h73: next_state = S_EXEC_CSR_READ;    // CSR     (1110011)
							   default: next_state = S_FETCH;     // Or some illegal trap
							endcase
							 end
			  S_EXEC_R_TYPE:
				begin
					alu_src_1_sel = 1'b0;  
					alu_src_2_sel = 1'b0;  

				  next_state = S_WRITEBACK;
				end
			 S_EXEC_I_TYPE :
				begin
				  alu_src_1_sel = 1'b0;  
				  alu_src_2_sel = 1'b1;
				   
				  next_state = S_WRITEBACK;
				end
			 S_EXEC_LOAD :
				begin
				  alu_src_1_sel = 1'b0;  
							  alu_src_2_sel = 1'b1;
				  
				  next_state = S_MEM_READ;
				end
			 S_EXEC_STORE :
				begin
				  alu_src_1_sel = 1'b0;  
							  alu_src_2_sel = 1'b1;
				   
				   next_state = S_MEM_WRITE;
				end
			 S_EXEC_BRANCH : 
					begin
				  alu_src_1_sel = 1'b1;  
				  alu_src_2_sel = 1'b1;
				  pc_src_sel = 2'b01;
				  rd_mux_sel = 3'b001;
				  rd_w_en = 1'b1;
				  branch_or_jump_taken = 1'b1; // Set the flag
				  pc_en = 1'b1;
				   
				  next_state = S_FETCH;
				end
			 S_EXEC_JAL : 
					begin
					  alu_src_1_sel = 1'b1;  
					  alu_src_2_sel = 1'b1;
					  pc_src_sel = 2'b01;
					  rd_mux_sel = 3'b001;
					  rd_w_en = 1'b1;
					  branch_or_jump_taken = 1'b1; // Set the flag
					  pc_en = 1'b1;
					   
					  next_state = S_FETCH;
				end
			 S_EXEC_JALR : 
					begin
				  alu_src_1_sel = 1'b0;  
				  alu_src_2_sel = 1'b1;
				  pc_src_sel = 2'b01;
				  pc_en = 1'b1;
				  clear_lsb = 1'b1;
				  
				  rd_mux_sel = 3'b001;
				  rd_w_en = 1'b1;
				   
				  next_state = S_FETCH;
				end
			S_EXEC_LUI : 
					begin
					  rd_mux_sel = 3'b100;  
					  rd_w_en = 1'b1;
					   
					  next_state = S_FETCH;
				end
			S_EXEC_AUIPC : 
					begin
					  alu_src_1_sel = 1'b1;  
					  alu_src_2_sel = 1'b1;
					   
					  next_state = S_WRITEBACK;
				end
			 S_EXEC_CSR_READ : 
					begin
					 rd_mux_sel = 3'b000 ;
					 rd_w_en = 1'b1;
				     next_state = S_EXEC_CSR_WRITE;
				end
		     S_EXEC_CSR_WRITE: 
		     begin
				 csr_w_en      = 1'b1;
				 next_state = S_FETCH;
				 if((funct3 == 3'b101) || (funct3 == 3'b110) || (funct3 == 3'b111)) begin
					csr_mux_sel = 1'b1;
				 end
		     end
			 S_BRANCH_CHECK : 
					begin
							  //alu_src_1_sel = 1'b0;  
							  //alu_src_2_sel = 1'b0;
							  //alu_operation = 5'b00001;
				  
							  //if (alu_result) begin
								//// Jumps for bne, blt, bltu
								//if ( funct3 == 3'b001 || funct3 == 3'b100 || funct3 == 3'b110 )begin
													//next_state = S_EXEC_BRANCH;
								//end
								//// Continues for be, bge, bge
								//else begin
									//next_state = S_FETCH;
								//end
											 //end
							  //else begin
							  
								//if ( funct3 == 3'b000 || funct3 == 3'b101 || funct3 == 3'b111 )begin
													//next_state = S_EXEC_BRANCH;
								//end
								//// Continues for be, bge, bge
								//else begin
									//next_state = S_FETCH;
								//end
							  
							  //end 
							  
							  if(branch_taken) begin
								next_state = S_EXEC_BRANCH;
								//pc_en = 1'b1;
								pc_src_sel = 2'b01;
							  end
							  else begin
								next_state = S_FETCH;
							  end
				   

				end
				
			S_MEM_READ:
				begin
					 addr_mux_sel = 0;
					 rd_mux_sel = 3'b010;
					 rd_w_en = 0;
					 mem_r_en = 1;
					 if (mem_read_done == 1) begin
						next_state = S_FETCH;
						mem_r_en = 0;
						rd_w_en = 1'b1;
					 end
				end
				
			S_MEM_WRITE:
				begin
					  addr_mux_sel = 0;
					  mem_w_en = 1;
					  next_state = S_FETCH;
				end
				
			S_WRITEBACK:
				begin
					 rd_mux_sel = 3'b011;
					 rd_w_en = 1;
					 next_state = S_FETCH;
				end
				
			S_INTERRUPT_ZERO_LOAD_ADDRESS: 
			begin
			csr_mux_sel = 2'b10; 
			csr_read_mux_sel = 1'b1;
			csr_w_en      = 1'b1;
			interrupt_en  = 1'b1;
			csr_reg_0_sel = 1'b0;
			pc_src_sel = 2'b10; 
			pc_en         = 1'b1; 
	        pc_curr_en = 1'b1;
	        count = 1'b1;
	        next_state = S_FETCH;
			end
			
			S_INTERRUPT_ONE_LOAD_ADDRESS: 
			begin
					 csr_mux_sel = 2'b10; 
			         csr_read_mux_sel = 1'b1;
			         csr_w_en      = 1'b1;
			         interrupt_en  = 1'b1 ;
			         csr_reg_0_sel = 1'b0;
			         pc_src_sel = 2'b10; 
			         pc_en         = 1'b1; 
			         pc_curr_en = 1'b0;
			         count = 1'b1;
			         next_state = S_FETCH;
			end
			
			S_INTERRUPT_ZERO :
			    begin 
			    if (irq_active == 2'b10) begin
			         irq_ack       = 2'b10;
			         count = 1'b0;
			         next_state = S_FETCH;
			    end
			    else if ( irq_active == 2'b11 )begin
			         irq_ack       = 2'b11;
			         count = 1'b0;
			         next_state = S_INTERRUPT_ONE_LOAD_ADDRESS;
			    end
			    end 
			S_INTERRUPT_ONE :
			  begin    
					irq_ack       = 2'b01;
					      count = 1'b0;
			        next_state = S_FETCH;
			  end 
			  
	          default:next_state = S_INIT; // Reset to initial state on undefined state
		  
                 endcase
		 end
endmodule
