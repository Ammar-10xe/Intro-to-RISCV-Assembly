.section .text
.globl _start

_start:

    la a0, arr                      # Load the address of the array into a0
    lw a1, length                   # Load the length of the array into a1
    jal ra, asm_fib                 # Call the Fibonacci function

asm_fib:                            # Fibonacci function
    
    beqz a0, null_pointer           # Check if the array pointer is NULL
    beqz a1, zero_length            # Check if the length of the array is 0
    jal not_zero_length             # Array and length are valid, proceed with Fibonacci calculation
    j write_tohost                  # Exit the program 

null_pointer:
    
    ret                             # Array pointer is NULL, return

zero_length:
    
    ret                             # Length is 0, return

not_zero_length:                   

    li t2, 0                        # prev (Fn-2 term)
    li t3, 1                        # curr (Fn-1 term)
                                    # Loop to generate Fibonacci series and store in the array
    li t4, 0                        # value of i for loop 
    loop_start:
                                    # Handle the initial 2 terms F0 and F1
        beq t4, a1, loop_end        # Exit the loop when i == length
        beqz t4, store_prev         # if i == 0, store prev (F0)
        beq t4, a1, loop_end        # Skip i == 1, as F1 is already initialized

                                    # Fn = Fn-1 + Fn-2, n > 1
                                    # Save the Fn-1 value
        mv t0, t3                   # tmp = curr

                                    # Fn = Fn-1 + Fn-2
        add t3, t2, t3              # curr += prev

                                    # Update Fn-2 = Fn-1
        mv t2, t0                   # prev = tmp

                                    # Save result to array
        store_prev:
            sw t2, 0(a0)            # arr[i] = prev
            addi a0, a0, 4          # Increment array pointer
            addi t4, t4, 1          # Increment i
            j loop_start

    loop_end:
                                    
    ret                             # Restore callee-saved registers from the stack if needed

write_tohost:

    li x1, 1
    sw x1, tohost, t5
    j write_tohost

.data
arr: .space 100                     # Adjust the size of the array
length: .word 10                    # Adjust the length of the array

.align 4; .global tohost;   tohost:   .dword 0;
.align 4; .global fromhost; fromhost: .dword 0;

