.data
fin:           .asciz "input.txt"   
fout:          .asciz "output.txt"  
error:         .asciz "Error: failed to open a file."
fielderror:    .asciz "Error: Field is not correct."
newline:        .asciz "\n" 
input_buffer:  .space 1024 
accumulate_fourth:    .word 0 
accumulate_fifth:     .word 0          

.text
main:
    la   s0, input_buffer      
    li   s1, 1023          # Buffer size
    # Open input.txt for reading
    li   a7, 1024         # syscall: open
    la   a0, fin          # Input file name
    li   a1, 0            # Open for reading
    ecall
    bltz a0, main.error   # Exit on error
    mv   s3, a0           # Save input file descriptor
    # Open output.txt for writing
    li   a7, 1024         # syscall: open
    la   a0, fout         # Output file name
    li   a1, 9            # Open for writing (write-append)
    ecall
    bltz a0, main.error   # Exit on error
    mv   s4, a0           # Save output file descriptor
read_content:
    # Read the entire content from the input.txt
    li   a7, 63           # syscall: read
    mv   a0, s3           # Input file descriptor
    mv   a1, s0           # Buffer address
    mv   a2, s1           # Buffer length
    ecall
    bltz a0, main.close   # Close files on error/EOF
    beqz a0, main.close   # Exit loop if EOF
    mv   s5, a0           # Bytes read
    # Null-terminate the buffer for processing
    add  s5, s0, s5       # Calculate end of buffer
    sb   zero, 0(s5)      # Null-terminate buffer
initialize:
    mv   s6, s0                     # Start of the line
    li   s2, '-'                    # ASCII for '-'
    li   s7, ';'                    # Field delimiter ';'
    li   s8, 'Z'                    # ASCII for 'Z'
    li   s9, '\n'                   # Line delimiter
    li   s10, 0                     # keep record of ';'
    li   s11, 0                     # keep record of errors
main.loop:
    mv t4,s6
    jal first_field
    jal second_field
    jal third_field
    jal fourth_field
    jal fifth_field
    jal sixth_field
    jal accumulate_sum
    beqz s11,write
skip:
    addi s6,s6,1
    bge s6,s5,main.exit
    jal reset_record
    j main.loop


accumulate_sum:
    la   t0, accumulate_fourth     # Load the address of the accumulator (accumulate_fourth) into register t2
    la   t1, accumulate_fifth      # Load the address of the accumulator (accumulate_fifth) into register t2
    lw   t2, 0(t0)                 # Load the current value of the accumulator into register t3
    lw   t3, 0(t1)                 # Load the current value of the accumulator into register t3
    add  t2, t2, t3
    li   t3, 18                    # Load constant 18 into t3
    div  a3, t2, t3                
    mul  a4, a3, t3
    beq  a4, t2, divisible_by_18
    addi s11,s11,1                 # Update error state
divisible_by_18:
    sw   a5, 0(t0)
    sw   a5, 0(t1)
    ret

write:
    addi sp, sp, -4       # Allocate space on the stack
    sw ra, 0(sp)          # Save ra to the stack
    jal write_line
    lw ra, 0(sp)          # Restore ra from the stack
    addi sp, sp, 4        # Deallocate space on the stack
    j skip


compute_address:
    li t2,1
    beq t2,t6,first_line
    mv t2,t4
    sub t3,s6,t2
    jr ra

first_line:
    mv t2,s0
    sub t3,s6,t2
    jr ra

reset_record:
    addi s6, s6, -1
    li s10, 0
    li s11, 0
    jr ra

first_field:
    bnez s10, field_error           # If s10 is not zero, jump to the error 
    lb   t0, 0(s6)                  # Load character
    beqz t0, skip_line              # End of field or line (TODO)
    beq  t0, s7, update_delimiter   # Field delimiter ';' found
    beq  t0, s8, update_error       # Found 'Z', update error state
continue:
    addi s6, s6, 1                  # Advance pointer
    j first_field                   # Continue parsing the field
update_error:
    addi s11,s11,1                  # Update error state
    j continue   
update_delimiter:
    addi s10,s10,1                   # Update delimiter count state
    addi s6, s6, 1                   # Advance pointer
    jr   ra
update_line_count:
    addi t6,t6,1                      # Update line counter
   # addi s6, s6, 1                   # Advance pointer
    jr   ra 

second_field:
    li   t1, 1
    bne s10, t1, field_error         # If s10 is not 1, jump to the error 
    lb   t0, 0(s6)                   # Load character
    beq  t0, s7, update_delimiter    # Field delimiter ';' found
    addi s6, s6, 1                   # Advance pointer
    j second_field                   # Continue parsing the field
third_field:
    li   t1, 2
    bne s10, t1, field_error         # If s10 is not 2, jump to the error 
    lb   t0, 0(s6)                   # Load character
    beq  t0, s7, update_delimiter    # Field delimiter ';' found
    beq  t0, s2, negative_number     # if negative number found
    addi s6, s6, 1                   # Advance pointer
    j third_field                    # Continue parsing the field
fourth_field:
    li   t1, 3
    bne s10, t1, field_error         # If s10 is not 3, jump to the error 
    lb   t0, 0(s6)                   # Load character
    beq  t0, s7, update_delimiter    # Field delimiter ';' found
    beq  t0, s2, negative_number     # if negative number 
    
    addi sp, sp, -4                  # Allocate space on the stack
    sw ra, 0(sp)                     # Save ra to the stack
    la   t2, accumulate_fourth       # Load the address of the accumulator (accumulate_fourth) into register t2
    jal char_to_int
    lw ra, 0(sp)                     # Restore ra from the stack
    addi sp, sp, 4                   # Deallocate space on the stack

    addi s6, s6, 1                   # Advance pointer
    j fourth_field                   # Continue parsing the field

fifth_field:
    li   t1, 4
    bne s10, t1, field_error         # If s10 is not 4, jump to the error 
    lb   t0, 0(s6)                   # Load character
    beq  t0, s7, update_delimiter    # Field delimiter ';' found
    
    addi sp, sp, -4                  # Allocate space on the stack
    sw ra, 0(sp)                     # Save ra to the stack
    la   t2, accumulate_fifth        # Load the address of the accumulator (accumulate_fifth) into register t2
    jal char_to_int
    lw ra, 0(sp)                     # Restore ra from the stack
    addi sp, sp, 4                   # Deallocate space on the stack

    addi s6, s6, 1                   # Advance pointer
    j fifth_field                    # Continue parsing the field
sixth_field:
    li   t1, 5
    bne s10, t1, field_error         # If s10 is not 5, jump to the error 
    lb   t0, 0(s6)                   # Load character
    beq  t0, s9, update_line_count   # End of the line 
    addi s6, s6, 1                   # Advance pointer
    j sixth_field                    # Continue parsing the field

negative_number:
    li t2,2
    addi s11,s11,1                   # Update error state
    addi s6,s6,1
    beq t1, t2, third_field
    li t2,3
    beq t1, t2, fourth_field
    j field_error                   

char_to_int:
    lw   t3, 0(t2)                 # Load the current value of the accumulator into register t3
    li   t5, 10                    # Load the constant 10 into register t5
    mul  t3, t3, t5                # Multiply the accumulator by 10 (shift the digits left)
    addi t5, t0, -48               # Convert the ASCII character to its numeric value (ASCII '0' -> 48)
    add  t3, t3, t5                # Add the new digit to the accumulator
    sw   t3, 0(t2)                 # Store the updated accumulator value back to memory
    ret                            # Return from the function

write_line:

    addi sp, sp, -4                 # Allocate space on the stack
    sw ra, 0(sp)                    # Save ra to the stack
    jal compute_address
    lw ra, 0(sp)                    # Restore ra from the stack
    addi sp, sp, 4                  # Deallocate space on the stack

    li   a7, 64                     # syscall: write
    mv   a0, s4                     # Output file descriptor
    mv   a1, t2                     # Buffer address
    mv   a2, t3                     # Number of bytes to write
    ecall
    ret
skip_line:
    j main.loop       
main.close:
    li   a7, 57                     # syscall: close
    mv   a0, s3                     # Input file descriptor
    ecall
    li   a7, 57                     # syscall: close
    mv   a0, s4                     # Output file descriptor
    ecall
main.exit:
    li   a7, 10                     # syscall: exit
    ecall
main.error:
    li   a7, 4                      # syscall: print string
    la   a0, error                  # Address of error message
    ecall
    j main.exit                     # Exit program
field_error:
    li   a7, 4                      # syscall: print string
    la   a0, fielderror             # Address of error message
    ecall
    j main.exit                     # Exit program