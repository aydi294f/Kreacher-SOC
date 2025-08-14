// Company           :   tud                      
// Author            :   vana158e            
// E-Mail            :   <email>                    
//                    			
// Filename          :   alu.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   This ALU module performs the arithmetic, logical, shift, comparison, multiplication, division and remainder operations as part of the RISC-V processor            
//
// Create Date       :   Sat Jan  4 12:49:13 2025 
// Last Change       :   Sat Jan  4 13:56:00 2025
// by                :   vana158e                  			
//------------------------------------------------------------
`timescale 1ns/10ps

module alu #(
    parameter WIDTH = 64 // Parameter to support 32 or 64-bit operations
)(
    input [WIDTH-1:0] operand_a,
    input [WIDTH-1:0] operand_b,
    input [4:0] operation,
    input clear_lsb,
    output wire [WIDTH-1:0] result,
    output wire error // Indicates invalid operation - can be removed later if not required
);
    
    reg [WIDTH-1:0] result_reg;
    reg error_reg;
    
    assign result = result_reg;
    assign error = error_reg;
    
    
    // Parameter definition for different instructions

    // R-type arithmetic operations
    localparam ALU_ADD  = 5'b00000;
    localparam ALU_SUB  = 5'b00001;

    // R-type logical operations
    localparam ALU_AND  = 5'b00010;
    localparam ALU_OR   = 5'b00011;
    localparam ALU_XOR  = 5'b00100;

    // R-type comparison operations
    localparam ALU_SLT  = 5'b00101;
    localparam ALU_SLTU = 5'b00110;

    // R-type shift operations
    localparam ALU_SLL  = 5'b00111;
    localparam ALU_SRL  = 5'b01000;
    localparam ALU_SRA  = 5'b01001;

    // Multiplication operations
    localparam ALU_MUL  = 5'b01010;
    localparam ALU_MULH = 5'b01011;
    localparam ALU_MULHSU = 5'b01100;
    localparam ALU_MULHU = 5'b01101;

    // Division operations
    localparam ALU_DIV  = 5'b01110;
    localparam ALU_DIVU = 5'b01111;

    // Remainder operations
    localparam ALU_REM  = 5'b10000;
    localparam ALU_REMU = 5'b10001;
    
    
    function integer clog2;
    	input integer value;
    	integer temp_value;
    	begin
        	clog2 = 0;
        	temp_value = value - 1;
        	while (temp_value > 0) begin
            		clog2 = clog2 + 1;
            		temp_value = temp_value >> 1;
        	end
    	end
    endfunction

    localparam CLOG2_WIDTH = clog2(WIDTH);
    
    // Temporary Register for Multiplication
    reg [(2*WIDTH)-1:0] temp;
    
    always @(operand_a or operand_b or operation) begin
	result_reg = {WIDTH{1'b0}};
    	error_reg = 1'b0;
	// temp = {(2*WIDTH)-1{1'b0}};
        
	case (operation)
            
	    // R-type arithmetic operations
            ALU_ADD:    begin
	    		    	result_reg = clear_lsb ? (operand_a + operand_b) & ~1 : (operand_a + operand_b);
			    	error_reg = 1'b0;
			end
            ALU_SUB:    begin
	    		    	result_reg = operand_a - operand_b;
			    	error_reg = 1'b0;
			end

            // R-type logical operations
            ALU_AND:    begin
	    		    	result_reg = operand_a & operand_b;
			    	error_reg = 1'b0;
	    		end
            ALU_OR:     begin
	    		    	result_reg = operand_a | operand_b;
				error_reg = 1'b0;
			end
            ALU_XOR:    begin
	    		    	result_reg = operand_a ^ operand_b;
				error_reg = 1'b0;
			end

            // R-type comparison operations
            ALU_SLT:    begin
	    		    	result_reg = ($signed(operand_a) < $signed(operand_b)) ? {{(WIDTH-1){1'b0}}, 1'b1} : {WIDTH{1'b0}};
				error_reg = 1'b0;
			end
            ALU_SLTU:   begin
	                    	result_reg = (operand_a < operand_b) ? {{(WIDTH-1){1'b0}}, 1'b1} : {WIDTH{1'b0}};
				error_reg = 1'b0;
			end

            // R-type shift operations
            ALU_SLL:    begin
	    			result_reg = operand_a << operand_b[CLOG2_WIDTH-1:0];
				error_reg = 1'b0;
			end
            ALU_SRL:    begin
	    			result_reg = operand_a >> operand_b[CLOG2_WIDTH-1:0];
				error_reg = 1'b0;
			end
            ALU_SRA:    begin
	    			result_reg = $signed(operand_a) >>> operand_b[CLOG2_WIDTH-1:0];
				error_reg = 1'b0;
			end

            // Multiplication operations
            ALU_MUL:    begin
	    			result_reg = $signed(operand_a) * $signed(operand_b);
				error_reg = 1'b0;
			end
            ALU_MULH:   begin
			    	temp = $signed(operand_a) * $signed(operand_b);
                            	result_reg = temp[(2*WIDTH)-1:WIDTH];
				error_reg = 1'b0;
                        end
            ALU_MULHSU: begin
			    	temp = $signed(operand_a) * operand_b;
                            	result_reg = temp[(2*WIDTH)-1:WIDTH];
				error_reg = 1'b0;
                        end 
            ALU_MULHU:  begin
			    	temp = operand_a * operand_b;
                            	result_reg = temp[(2*WIDTH)-1:WIDTH];
				error_reg = 1'b0;
                        end

            // Division operations
            ALU_DIV:    begin
	    			result_reg = (operand_b != {WIDTH{1'b0}}) ? ($signed(operand_a) / $signed(operand_b)) : {WIDTH{1'b0}};
				error_reg = 1'b0;
			end
            ALU_DIVU:   begin
	    			result_reg = (operand_b != {WIDTH{1'b0}}) ? (operand_a / operand_b) : {WIDTH{1'b0}};
				error_reg = 1'b0;
			end

            // Remainder operations
            ALU_REM:    begin
	    			result_reg = (operand_b != {WIDTH{1'b0}}) ? ($signed(operand_a) % $signed(operand_b)) : {WIDTH{1'b0}};
				error_reg = 1'b0;
			end
            ALU_REMU:   begin
	    			result_reg = (operand_b != {WIDTH{1'b0}}) ? (operand_a % operand_b) : {WIDTH{1'b0}};
				error_reg = 1'b0;
			end

            // Default case
            default: 	begin
				result_reg = {WIDTH{1'b0}};
                		error_reg = 1'b1; // Signal an error for invalid operation
            		end
        endcase
    end

endmodule


