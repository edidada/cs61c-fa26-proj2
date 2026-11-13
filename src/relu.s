.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
# a0 walks the array; a1 counts remaining elements; t0 holds one value.
    bge zero a1 relu_bad_length
relu_loop:
    lw t0 0(a0)
    bge t0 zero relu_next
    sw zero 0(a0)
relu_next:
    addi a0 a0 4
    addi a1 a1 -1
    bnez a1 relu_loop
    jr ra
relu_bad_length:
    li a0 36
    j exit
