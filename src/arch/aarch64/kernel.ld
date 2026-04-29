/*
 * Jade Kernel Linker Script
 * Target: ARMv8-A (AArch64) bare-metal
 * Platform: QEMU virt machine
 */

ENTRY(_start)

MEMORY
{
    RAM (rwx) : ORIGIN = 0x40000000, LENGTH = 128M
}

PHDRS
{
    text_seg  PT_LOAD FLAGS(5);   /* R-X */
    data_seg  PT_LOAD FLAGS(6);   /* RW- */
}

SECTIONS
{
    . = 0x40000000;

    /* Boot entry -- _start must remain at binary origin */
    .text.boot : {
        *(.text.boot)
    } > RAM :text_seg

    . = ALIGN(2K);

    /* Exception vector table -- 2KB aligned per ARM DDI 0487 */
    .vectors : {
        __vectors_start = .;
        *(.vectors)
        . = ALIGN(2K);
        __vectors_end = .;
    } > RAM :text_seg

    /* Remaining kernel code */
    .text : {
        *(.text*)
    } > RAM :text_seg

    .rodata : ALIGN(4K) {
        *(.rodata*)
    } > RAM :text_seg

    .data : ALIGN(4K) {
        *(.data*)
    } > RAM :data_seg

    .bss : ALIGN(4K) {
        __bss_start = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(8);
        __bss_end = .;
    } > RAM :data_seg

    .stack : ALIGN(16) {
        __stack_start = .;
        . = . + 16K;
        . = ALIGN(16);
        __stack_end = .;
    } > RAM :data_seg

    /DISCARD/ : {
        *(.comment)
        *(.eh_frame)
        *(.note*)
    }
}