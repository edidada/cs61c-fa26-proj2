.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:
addi sp sp -32
    sw ra 28(sp)
    sw s0 24(sp)
    sw s1 20(sp)
    sw s2 16(sp)
    sw s3 12(sp)
    sw s4 8(sp)
    # s0 fd; s1/s2 caller row/column destinations; s3 matrix; s4 byte count.
    mv s1 a1
    mv s2 a2
    li a1 0
    jal fopen
    li t0 -1
    beq a0 t0 read_bad_open
    mv s0 a0
    mv a1 s1
    li a2 4
    jal fread
    li t0 4
    bne a0 t0 read_bad_read
    mv a0 s0
    mv a1 s2
    li a2 4
    jal fread
    li t0 4
    bne a0 t0 read_bad_read
    lw t0 0(s1)
    lw t1 0(s2)
    bge zero t0 read_bad_read
    bge zero t1 read_bad_read
    mulhu t2 t0 t1
    bnez t2 read_bad_read
    mul s4 t0 t1
    li t2 536870911
    bltu t2 s4 read_bad_read
    slli s4 s4 2
    mv a0 s4
    jal malloc
    beqz a0 read_bad_malloc
    mv s3 a0
    mv a0 s0
    mv a1 s3
    mv a2 s4
    jal fread
    bne a0 s4 read_bad_read
    mv a0 s0
    jal fclose
    bnez a0 read_bad_close
    mv a0 s3
    lw ra 28(sp)
    lw s0 24(sp)
    lw s1 20(sp)
    lw s2 16(sp)
    lw s3 12(sp)
    lw s4 8(sp)
    addi sp sp 32
    jr ra
read_bad_malloc:
    li a0 26
    j exit
read_bad_open:
    li a0 27
    j exit
read_bad_close:
    li a0 28
    j exit
read_bad_read:
    li a0 29
    j exit
