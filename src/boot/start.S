/*
 * Jade Kernel - Boot Entry Point
 * ARMv8-A (AArch64) minimal entry
 */

.section .text.boot
.global _start

_start:
    // Trivial infinite loop for build validation
    b .

