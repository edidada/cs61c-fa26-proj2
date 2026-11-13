.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
# Validate m0, then m1, then inner dimension as required.
    bge zero a1 matmul_bad_dimensions
    bge zero a2 matmul_bad_dimensions
    bge zero a4 matmul_bad_dimensions
    bge zero a5 matmul_bad_dimensions
    bne a2 a4 matmul_bad_dimensions
    addi sp sp -32
    sw ra 28(sp)
    sw s0 24(sp)
    sw s1 20(sp)
    sw s2 16(sp)
    sw s3 12(sp)
    sw s4 8(sp)
    sw s5 4(sp)
    sw s6 0(sp)
    # s0 current m0 row; s1 rows left; s2 inner dimension; s3 m1 base;
    # s4 output width; s5 next output slot; s6 current column index.
    mv s0 a0
    mv s1 a1
    mv s2 a2
    mv s3 a3
    mv s4 a5
    mv s5 a6
matmul_row:
    li s6 0
matmul_column:
    mv a0 s0
    slli t0 s6 2
    add a1 s3 t0
    mv a2 s2
    li a3 1
    mv a4 s4
    jal dot
    sw a0 0(s5)
    addi s5 s5 4
    addi s6 s6 1
    blt s6 s4 matmul_column
    slli t0 s2 2
    add s0 s0 t0
    addi s1 s1 -1
    bnez s1 matmul_row
    lw ra 28(sp)
    lw s0 24(sp)
    lw s1 20(sp)
    lw s2 16(sp)
    lw s3 12(sp)
    lw s4 8(sp)
    lw s5 4(sp)
    lw s6 0(sp)
    addi sp sp 32
    jr ra
matmul_bad_dimensions:
    li a0 38
    j exit
