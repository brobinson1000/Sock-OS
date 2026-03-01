void kmain() {
    char* video = (char*)0xB8000;
    const char* msg = "Hello from C Kernel!";

    for (int i = 0; msg[i]; i++) {
        video[i*2] = msg[i];
        video[i*2+1] = 0x0F; // white on black
    }

    while (1) { __asm__ __volatile__("hlt"); }
}
