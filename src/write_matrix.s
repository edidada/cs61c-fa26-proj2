.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:
addi sp sp -32
    sw ra 28(sp)
    sw s0 24(sp)
    sw s1 20(sp)
    sw s2 16(sp)
    sw s3 12(sp)
    # Stack 0/4: binary dimensions. s0 fd, s1 data, s2 element count.
    sw a2 0(sp)
    sw a3 4(sp)
    mv s1 a1
    mul s2 a2 a3
    li a1 1
    jal fopen
    li t0 -1
    beq a0 t0 write_bad_open
    mv s0 a0
    mv a1 sp
    li a2 2
    li a3 4
    jal fwrite
    li t0 2
    bne a0 t0 write_bad_write
    mv a0 s0
    mv a1 s1
    mv a2 s2
    li a3 4
    jal fwrite
    bne a0 s2 write_bad_write
    mv a0 s0
    jal fclose
    bnez a0 write_bad_close
    lw ra 28(sp)
    lw s0 24(sp)
    lw s1 20(sp)
    lw s2 16(sp)
    lw s3 12(sp)
    addi sp sp 32
    jr ra
write_bad_open:
    li a0 27
    j exit
write_bad_close:
    li a0 28
    j exit
write_bad_write:
    li a0 30
    j exit
