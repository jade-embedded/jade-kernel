/*
 * Jade Kernel Linker Script
 * Target: ARMv8-A (AArch64) bare-metal
 * Platform: QEMU virt machine
 */

/* Entry point */
ENTRY(_start)

/* Memory layout for QEMU virt machine */
/* QEMU virt loads at 0x40000000 by default */
MEMORY
{
    RAM (rwx) : ORIGIN = 0x40000000, LENGTH = 128M
}

SECTIONS
{
    /* Load address */
    . = 0x40000000;

    /* Executable code section */
    .text : {
        *(.text.boot)   /* Boot code first */
        *(.text*)       /* All other code */
    } > RAM

    /* Read-only data section */
    .rodata : ALIGN(4K) {
        *(.rodata*)
    } > RAM

    /* Initialized data section */
    .data : ALIGN(4K) {
        *(.data*)
    } > RAM

    /* Zero-initialized data section */
    .bss : ALIGN(4K) {
        __bss_start = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(8);    /* AArch64 requires 8-byte alignment */
        __bss_end = .;
    } > RAM

    /* Stack region (grows downward) */
    /* Reserve 16KB for initial kernel stack */
    .stack : ALIGN(16) {
        __stack_start = .;
        . = . + 16K;     /* 16KB stack size */
        . = ALIGN(16);   /* ARMv8-A requires 16-byte stack alignment */
        __stack_end = .;
    } > RAM

    /* Discard unnecessary sections */
    /DISCARD/ : {
        *(.comment)
        *(.eh_frame)
        *(.note*)
    }
}
