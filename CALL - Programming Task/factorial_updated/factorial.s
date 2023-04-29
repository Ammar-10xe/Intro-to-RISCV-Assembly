.section ".text", "ax", @progbits
.globl _start
_start:

    la t0, n
    lw a0, 0(t0)        
    jal ra, factorial

    la t1, result       
    sw a0,0(t1)         # store the result in the "result" in data section  

factorial:
    addi sp,sp,-8    # Allocate 8 bytes on the stack for storing the return address and argument.
    sw ra,4(sp)      # Save the return address on the stack.
    sw a0,0(sp)      # Save the argument on the stack.
    addi t0,a0,-1    # Subtract 1 from the argument and store the result in t0.
    bgt t0,x0,Loop   # If t0 is greater than 0, jump to label L1.
    addi a0,x0,1     # If t0 is equal to zero return 1 
    addi sp,sp,8     # Deallocate the stack space 
    jalr ra          # return the result and return 

Loop:
    addi a0,a0,-1    # Subtract 1 from the argument and store the result in a0.
    jal ra,factorial # Jump to the beginning of the factorial function, passing a0 as the argument.
    addi t1,a0,0     # Store the result of the recursive call in t1.
    lw a0,0(sp)      # Load the argument from the stack.
    lw ra,4(sp)      # Load the return address from the stack.
    addi sp,sp,8     # Deallocate the stack space.
    mul a0,a0,t1     # Multiply the argument by the result of the recursive call.
    jalr ra          # Return to the calling function, using the return address stored on the stack.


write_tohost:

li x1, 1

sw x1, tohost, t5

j write_tohost

.data

n: .word 9
result: .word 0

.align 12

.section ".tohost","aw",@progbits;                            

.align 4; .global tohost; tohost: .dword 0;                     

.align 4; .global fromhost; fromhost: .dword 0; 
