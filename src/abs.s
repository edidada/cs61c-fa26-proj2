.globl abs

.text
# =================================================================
# FUNCTION: Given an int return its absolute value.
# Arguments:
#   a0 (int*) is a pointer to the input integer
# Returns:
#   None
# =================================================================
abs:
# t0: pointed-to signed value. INT_MIN retains RV32 two's-complement bits.
    lw t0 0(a0)
    bge t0 zero abs_done
    sub t0 zero t0
    sw t0 0(a0)
abs_done:
    jr ra
