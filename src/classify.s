.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
li t0 5
    bne a0 t0 classify_bad_args
    addi sp sp -96
    sw ra 92(sp)
    sw s0 88(sp)
    sw s1 84(sp)
    sw s2 80(sp)
    sw s3 76(sp)
    sw s4 72(sp)
    sw s5 68(sp)
    sw s6 64(sp)
    sw s7 60(sp)
    # s0 argv; s1 silent; s2 m0; s3 m1; s4 input; s5 hidden; s6 output;
    # s7 final index. Stack 0..20 stores six matrix dimensions across calls.
    mv s0 a1
    mv s1 a2
    lw a0 4(s0)
    mv a1 sp
    addi a2 sp 4
    jal read_matrix
    mv s2 a0
    lw a0 8(s0)
    addi a1 sp 8
    addi a2 sp 12
    jal read_matrix
    mv s3 a0
    lw a0 12(s0)
    addi a1 sp 16
    addi a2 sp 20
    jal read_matrix
    mv s4 a0
    lw t0 0(sp)
    lw t1 20(sp)
    mul a0 t0 t1
    slli a0 a0 2
    jal malloc
    beqz a0 classify_bad_malloc
    mv s5 a0
    mv a0 s2
    lw a1 0(sp)
    lw a2 4(sp)
    mv a3 s4
    lw a4 16(sp)
    lw a5 20(sp)
    mv a6 s5
    jal matmul
    mv a0 s5
    lw t0 0(sp)
    lw t1 20(sp)
    mul a1 t0 t1
    jal relu
    lw t0 8(sp)
    lw t1 20(sp)
    mul a0 t0 t1
    slli a0 a0 2
    jal malloc
    beqz a0 classify_bad_malloc
    mv s6 a0
    mv a0 s3
    lw a1 8(sp)
    lw a2 12(sp)
    mv a3 s5
    lw a4 0(sp)
    lw a5 20(sp)
    mv a6 s6
    jal matmul
    lw a0 16(s0)
    mv a1 s6
    lw a2 8(sp)
    lw a3 20(sp)
    jal write_matrix
    mv a0 s6
    lw t0 8(sp)
    lw t1 20(sp)
    mul a1 t0 t1
    jal argmax
    mv s7 a0
    bnez s1 classify_free
    jal print_int
    li a0 10
    jal print_char
classify_free:
    mv a0 s2
    jal free
    mv a0 s3
    jal free
    mv a0 s4
    jal free
    mv a0 s5
    jal free
    mv a0 s6
    jal free
    mv a0 s7
    lw ra 92(sp)
    lw s0 88(sp)
    lw s1 84(sp)
    lw s2 80(sp)
    lw s3 76(sp)
    lw s4 72(sp)
    lw s5 68(sp)
    lw s6 64(sp)
    lw s7 60(sp)
    addi sp sp 96
    jr ra
classify_bad_args:
    li a0 31
    j exit
classify_bad_malloc:
    li a0 26
    j exit
