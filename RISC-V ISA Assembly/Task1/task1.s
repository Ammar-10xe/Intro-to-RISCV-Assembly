.globl main        # main as a global symbol
    .data          # Start of the .data section

array_b:           # For Array b[3]
    .word 0,0,0    # Initializing the first three elements of the array b to 0

    .text          # Start of the .text section

main:
    li s0, 0        # s0 to hold i
    li s1, 7        # s1 to hold a = 7
    la s2, array_b  # s2 to hold &b i.e base address of b

loop:
   
    li t0, 3         # Check if i is less than 3
    bge s0, t0, exit # loop until i < 3
    
    mul t1, s0, s1   # t1 = (i * a)
    add t2, s1, t1   # t2 = a + (i * a)

    slli t3, s0, 2   # Multiply i by 4 to get the byte offset of b[i]
    add t3, t3, s2   # Add the offset to the base address of b to get the memory address of b[i]
    sw t2, 0(t3)     # Store the value of a + (i * a) into b[i]
    
    lw a0, 0(t3)    # Load the value of b[i] into a0
    addi a1, a0, 0  # Copy the value of a0 into a1 (required for printing)
    addi a0, x0, 1  # Set a0 to 1 to indicate that we want to print an integer
    ecall           # Print the value of a1 to the console

    addi a1, x0, '\n' # Set a1 to the ASCI value of '\n\ i.e (10)
    addi a0, x0, 11   # Set a0 to 11 indicate that we want to print a character 
    ecall             # print a newline character.
   
    addi s0, s0, 1  # loop increment of i
    addi s2, s2, 4  # Increment the address of b to point to the next element

    j loop

exit:
    
    addi a0, x0, 10 # Set the exit code to 10, indicating that the program terminated with an error. 
    ecall           # Exit the program
