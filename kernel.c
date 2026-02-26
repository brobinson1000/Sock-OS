void kernel_main(void) {
    // Clear screen (BIOS interrupt 0x10 for video services)
    unsigned short* video_memory = (unsigned short*) 0xB8000;
    unsigned short color = 0x0F00;  // White on black text
    unsigned int i;

    // Clear the screen by writing spaces to each position
    for (i = 0; i < 80 * 25; i++) {
        video_memory[i] = ' ' | color; 
    }

    const char* message = "Hello, Kernel World!";
    for (i = 0; message[i] != '\0'; i++) {
        video_memory[i] = message[i] | color; // Write characters to video memory
    }

    // Infinite loop to halt the CPU (just for simplicity, to prevent the kernel from returning)
    while (1) {
        __asm__ volatile("hlt");  // Halt the CPU
    }
}
