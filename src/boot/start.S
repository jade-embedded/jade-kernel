/*
 * Copyright (c) 2026 jade-embedded contributors
 * SPDX-License-Identifier: Apache-2.0
 *
 * Jade Kernel - Boot Entry Point
 * ARMv8-A (AArch64) EL2 to EL1 transition
 */

.section .text.boot, "ax"
.global _start

_start:
    // Entry point - execution begins here
    // QEMU virt machine starts at EL2
    
mask_interrupts:
    // Mask all interrupts and exceptions using DAIF register
    // D = Debug exceptions
    // A = SError (System Error)
    // I = IRQ (normal interrupts)
    // F = FIQ (fast interrupts)
    
    msr DAIFSet, #0xF    // Set all DAIF bits (mask all exceptions)
    
read_current_el:
    // Read CurrentEL register to determine exception level
    
    mrs x0, CurrentEL        // Read current EL into x0
    and x0, x0, #0xC         // Extract EL bits [3:2]
    lsr x0, x0, #2           // Shift right to get EL number (0, 1, 2, or 3)
    
    // x0 now contains: 0=EL0, 1=EL1, 2=EL2, 3=EL3
    
    cmp x0, #2               // Are we at EL2?
    beq transition_to_el1    // Yes -> transition to EL1
    
    cmp x0, #1               // Are we at EL1?
    beq setup_el1_stack      // Yes -> already at target, continue
    
    cmp x0, #3               // Are we at EL3?
    beq el3_not_supported
    
    // Must be EL0
    b el0_privileged_fault

el0_privileged_fault:
    // Running at EL0 - cannot escalate privilege
    mov x0, #0xDEAD          // Error signature
    mov x1, #0xE100          // Exception level 0 error
    mov x2, #0xBAD0          // Bad state - EL0
    wfe
    b el0_privileged_fault

el3_not_supported:
    // EL3 secure monitor not supported
    mov x0, #0xDEAD          // Error signature
    mov x1, #0xE103          // Exception level 3 error
    mov x2, #0xBAD3          // Bad state - EL3
    wfe
    b el3_not_supported

transition_to_el1:
    // Configure EL1 execution state before transition
    
    // Set EL1 to use AArch64 (not AArch32)
    // HCR_EL2.RW = 1 (EL1 is AArch64)
    mov x0, #(1 << 31)       // RW bit is bit 31
    msr HCR_EL2, x0
    
    // Set up SPSR_EL2 (saved program status register)
    // This defines the processor state when we enter EL1
    // M[4:0] = 0b00101 (EL1h - EL1 with SP_EL1)
    // DAIF = 1111 (all exceptions masked)
    mov x0, #0x3C5           // EL1h mode (0x5) + DAIF masked (0x3C0)
    msr SPSR_EL2, x0
    
    // Set EL1 entry point (where to jump when we drop to EL1)
    adr x0, setup_el1_stack
    msr ELR_EL2, x0          // Exception Link Register = next instruction
    
    // Execute exception return to drop to EL1
    eret                     // Return to EL1 at address in ELR_EL2

setup_el1_stack:
    // Now running at EL1
    // Set up stack pointer using linker symbols
    
    // Load stack top address from linker script
    ldr x0, =__stack_end     // Stack grows downward, start at top
    mov sp, x0               // Set stack pointer
    
    // Stack is now ready for function calls and C runtime
    
zero_bss:
    ldr x0, =__bss_start
    ldr x1, =__bss_end
    cmp x0, x1
    beq install_vectors
zero_bss_loop:
    str xzr, [x0], #8
    cmp x0, x1
    blt zero_bss_loop

install_vectors:
    // Install exception vector table base address into VBAR_EL1
    // Required before any exception can be handled (ARM DDI 0487, Section D1)
    ldr x0, =_vectors          // Load vector table base address
    msr VBAR_EL1, x0           // Write to Vector Base Address Register
    isb                        // Instruction sync barrier -- ensure VBAR_EL1 visible
    // Fall through to branch_to_c

branch_to_c:
    // Branch to kernel_main() in C
    // Stack is set up, processor is at EL1, interrupts masked
    
    bl kernel_main           // Call C function
    
    // If kernel_main returns (it shouldn't), halt
hang:
    wfe                      // Wait for event (low power)
    b hang                   // Loop forever