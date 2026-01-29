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
    // - Interrupts masked
    
    // Idle loop for Sprint S3
    while(1) {
        __asm__ volatile("wfe");  // Wait for event
    }
}