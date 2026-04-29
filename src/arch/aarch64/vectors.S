/*
 * vectors.S
 *
 * Purpose: ARMv8-A exception vector table for Jade Kernel
 * Author: Coder Agent v1.0.0
 * Created: 2026-04-29
 *
 * The vector table structure is mandated by ARM DDI 0487, Section D1.
 * 16 entries at 128-byte offsets, 2KB-aligned base loaded into VBAR_EL1.
 *
 * Each handler is a named halt-on-fault stub. Unique labels allow fault
 * identification via QEMU register dump cross-referenced against nm output.
 * Handlers will be replaced with real dispatch logic in a future sprint.
 *
 * Table layout (offsets from VBAR_EL1):
 *   +0x000  Current EL, SP0,  Synchronous
 *   +0x080  Current EL, SP0,  IRQ
 *   +0x100  Current EL, SP0,  FIQ
 *   +0x180  Current EL, SP0,  SError
 *   +0x200  Current EL, SPx,  Synchronous
 *   +0x280  Current EL, SPx,  IRQ
 *   +0x300  Current EL, SPx,  FIQ
 *   +0x380  Current EL, SPx,  SError
 *   +0x400  Lower EL, AArch64, Synchronous
 *   +0x480  Lower EL, AArch64, IRQ
 *   +0x500  Lower EL, AArch64, FIQ
 *   +0x580  Lower EL, AArch64, SError
 *   +0x600  Lower EL, AArch32, Synchronous
 *   +0x680  Lower EL, AArch32, IRQ
 *   +0x700  Lower EL, AArch32, FIQ
 *   +0x780  Lower EL, AArch32, SError
 */

.section .vectors, "ax"
.global _vectors
.balign 2048

_vectors:

/* --- Current EL, SP0 --- */
.balign 128
hang_sync_sp0:      wfe; b hang_sync_sp0

.balign 128
hang_irq_sp0:       wfe; b hang_irq_sp0

.balign 128
hang_fiq_sp0:       wfe; b hang_fiq_sp0

.balign 128
hang_serror_sp0:    wfe; b hang_serror_sp0

/* --- Current EL, SPx --- */
.balign 128
hang_sync_spx:      wfe; b hang_sync_spx

.balign 128
hang_irq_spx:       wfe; b hang_irq_spx

.balign 128
hang_fiq_spx:       wfe; b hang_fiq_spx

.balign 128
hang_serror_spx:    wfe; b hang_serror_spx

/* --- Lower EL, AArch64 --- */
.balign 128
hang_sync_lower64:  wfe; b hang_sync_lower64

.balign 128
hang_irq_lower64:   wfe; b hang_irq_lower64

.balign 128
hang_fiq_lower64:   wfe; b hang_fiq_lower64

.balign 128
hang_serror_lower64: wfe; b hang_serror_lower64

/* --- Lower EL, AArch32 --- */
.balign 128
hang_sync_lower32:  wfe; b hang_sync_lower32

.balign 128
hang_irq_lower32:   wfe; b hang_irq_lower32

.balign 128
hang_fiq_lower32:   wfe; b hang_fiq_lower32

.balign 128
hang_serror_lower32: wfe; b hang_serror_lower32
