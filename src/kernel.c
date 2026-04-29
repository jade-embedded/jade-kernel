/*
 * Jade Kernel - Main Entry
 * Called from boot assembly after EL1 transition
 */

void kernel_main(void)
{
    // Kernel main entry point
    // At this point:
    // - Running at EL1
    // - Stack initialized
    // - .bss zeroed
    // - VBAR_EL1 installed
    // - Interrupts masked

    // Idle loop -- should not reach here if exception is taken
    while(1) {
        __asm__ volatile("wfe");
    }
}