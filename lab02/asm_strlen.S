# Function to calculate the number of characters in a string

.section .text
.globl _start

_start:
    
    la a0, hello_string         # loads the address of hello_string 
    jal ra, asm_strlen          # Call asm_strlen with the address of the hello_string

    j write_tohost

asm_strlen:
    
    li t0, 0                    # Set the initial string length to 0
    loop_strlen:                # Check the string characters
        lbu t1, 0(a0)           # Load the byte from the current address
        beqz t1, end_strlen     # If the byte is 0 (end of string), exit the loop
        li t2, 32               # ASCII code for space
        beq t1, t2, skip_space  # If the character is a space, skip it       
        addi a0, a0, 1          # Move the pointer to the next character position
        addi t0, t0, 1          # Increment the length counter
        j loop_strlen
                                
    skip_space:                 # Skip over spaces
        addi a0, a0, 1          # Move the pointer to the next character position
        j loop_strlen

    end_strlen:                 # Return the length of the string
        mv a0, t0               # Move the length to a0 for return
        ret


write_tohost:

    li x1, 1
    sw x1, tohost, t5
exit:
    j write_tohost

.data

    hello_string: .asciz "hello!"

.align 4; .global tohost;   tohost:   .dword 0;
.align 4; .global fromhost; fromhost: .dword 0;
