.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the number of elements to use is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
# t0 accumulates the RV32 result; a3/a4 are byte strides; t1/t2 values.
    bge zero a2 dot_bad_length
    bge zero a3 dot_bad_stride
    bge zero a4 dot_bad_stride
    slli a3 a3 2
    slli a4 a4 2
    li t0 0
dot_loop:
    lw t1 0(a0)
    lw t2 0(a1)
    mul t1 t1 t2
    add t0 t0 t1
    add a0 a0 a3
    add a1 a1 a4
    addi a2 a2 -1
    bnez a2 dot_loop
    mv a0 t0
    jr ra
dot_bad_length:
    li a0 36
    j exit
dot_bad_stride:
    li a0 37
    j exit
