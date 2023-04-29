# Programming Task : 2
.globl main
.text
main:

    li a0, 5            # Initialize a0 to the any num
    jal dataArray       # Jump and link to dataArray function to initialize array
    addi a0, x0, 10     # Exit the program
    ecall

# Function: void dataArray (int num) 
dataArray:
    addi sp, sp, -44    # Adjust stack pointer to allocate space for local variables and array
    sw ra, 0(sp)        # Save return address on the stack
    sw s0, 4(sp)        # Save s0 (i) on the stack
    sw a0, 8(sp)        # Save num on the stack
    li s0, 0            # Initialize i to 0
    addi t0, sp, 12     # Calculate the address of the array on the stack

loop:
    li t2,10
    bge s0, t2, endloop # Branch to endloop if i is greater than or equal to 10
    jal compare         # Jump and link to compare function to populate array element
    sw a3, 0(t0)        # Store the result of compare in the array
    addi a1, a3, 0      # Move the result to a1 to print it
    addi a0, x0, 1      # Load in ascii code for integer print
    ecall               # Print the integer value
    addi a1, x0, 32     # Load in ascii code for space
    addi a0, x0, 11     # Load in ascii code for newline print
    ecall               # Print the space
    addi t0, t0, 4      # Increment array pointer by 4 bytes
    addi s0, s0, 1      # Increment i by 1
    lw a0, 8(sp)        # load a0 with the num
    j loop              # Jump back to loop

endloop:
    lw s0, 4(sp)        # Restore s0 (i) from the stack
    lw ra, 0(sp)        # Restore return address from the stack
    addi sp, sp, 44     # Adjust stack pointer to deallocate space for local variables and array
    jr ra               # Jump to return address and return


# Function: int sub (int a, int b) 
sub:
    addi sp, sp, -4     # Adjust stack pointer to allocate space for a local variable
    sw ra, 0(sp)        # Save return address on the stack
    sub a2, a0, s0      # Subtract b from a and store the result in a2
    lw ra, 0(sp)        # Restore return address from the stack
    addi sp, sp, 4      # Adjust stack pointer to deallocate space for local variables
    jr ra               # Jump to return address and return

# Function: int compare (int a, int b) 
compare:
    addi sp, sp, -4     # Adjust stack pointer to allocate space for two local variables
    sw ra, 0(sp)        # Save return address on the stack
    jal sub             # Jump and link to sub function to perform subtraction
    bltz a2, return0    # Branch to return1 if the result is greater than or equal to 0
    li a3, 1            # Load 0 into a3 to indicate true (1)
    j end_compare       # Jump to end compare
    
return0:
    li a3, 0            # Load 0 into a3 to indicate false(0)

end_compare: 
    lw ra, 0(sp)
    addi sp, sp, 4      # Adjust stack pointer to deallocate space for local variables
    jr ra               # Jump to return address and return
