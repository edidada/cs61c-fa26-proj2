.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
# t0: best value, t1: best index, t2: scan index, t3: candidate.
    bge zero a1 argmax_bad_length
    lw t0 0(a0)
    li t1 0
    li t2 1
argmax_loop:
    bge t2 a1 argmax_done
    addi a0 a0 4
    lw t3 0(a0)
    bge t0 t3 argmax_next
    mv t0 t3
    mv t1 t2
argmax_next:
    addi t2 t2 1
    j argmax_loop
argmax_done:
    mv a0 t1
    jr ra
argmax_bad_length:
    li a0 36
    j exit
