#include "keyboard.h"
#include "pic.h"
#include "screen.h"
#include "idt.h"



// Key Mapping per io operaation
static const char scancode_to_ascii[] = {
    0, 0, '1','2','3','4','5','6','7','8','9','0','-','=','\b',
    '\t','q','w','e','r','t','y','u','i','o','p','[',']','\n',
    0,'a','s','d','f','g','h','j','k','l',';','\'','`',
    0,'\\','z','x','c','v','b','n','m',',','.','/',0,
    '*',0,' '
};
static const char scancode_shift_to_ascii[] = {
    0, 0, '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', '\b',
    '\t', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', '\n',
    0, 'A', 'S', 'D', 'F', 'G', 'H', 'J',  'K', 'L', ':', '\"' , '~',
    0, '|' , 'Z', 'X', 'C', 'V' , 'B', 'N', 'M', '<', '>' , '?', 0,
    '*', 0, ' '
};
static const char scancode_caps_to_ascii[] = {
    0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',
    '\t', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']', '\n',
    0, 'A', 'S', 'D', 'F', 'G', 'H', 'J',  'K', 'L', ';', '\'' , '`',
    0, '\\' , 'Z', 'X', 'C', 'V' , 'B', 'N', 'M', ',', '.' , '/', 0,
    '*', 0, ' '
};

// Shift and caps state
static int shift_pressed = 0;
static int caps_on = 0;


// Keyboard Utilities Used in Shell

#define KBD_BUF_SIZE 128           
#define KBD_BUF_MASK (KBD_BUF_SIZE - 1)

static volatile char     kbd_buf[KBD_BUF_SIZE];
static volatile uint32_t kbd_head = 0;   /* advanced by the ISR    */
static volatile uint32_t kbd_tail = 0;   /* advanced by the reader */

static void kbd_push(char c) {
    uint32_t next = (kbd_head + 1) & KBD_BUF_MASK;
    if (next == kbd_tail) return;        /* full - drop the keystroke */
    kbd_buf[kbd_head] = c;
    kbd_head = next;
}

int kbd_has_char(void) {
    return kbd_head != kbd_tail;
}

char kbd_getchar(void) {
    while (!kbd_has_char())
        __asm__ __volatile__("hlt");     /* woken by the keyboard IRQ */

    char c = kbd_buf[kbd_tail];
    kbd_tail = (kbd_tail + 1) & KBD_BUF_MASK;
    return c;
}

void kbd_flush(void) {
    kbd_tail = kbd_head;
}


void keyboard_callback(registers_t* regs) {
    (void)regs;
    uint8_t scancode = inb(0x60);
    if (scancode == 0x36 || scancode == 0x2A) {
        shift_pressed = 1;
        return;
    }
    if (scancode == 0xB6 || scancode == 0xAA ) {
        shift_pressed = 0;
        return;
    }
    if (scancode == 0x3A ) {
        caps_on ^= 1;
        return;
    }
    if (scancode & 0x80) return;
    if (scancode < sizeof(scancode_to_ascii)) {
        char c;
        if ( caps_on ) {
            c = scancode_caps_to_ascii[scancode];
        } else {
            c = shift_pressed ?  scancode_shift_to_ascii[scancode] : scancode_to_ascii[scancode];
        }
        if (c) {
            kbd_push(c);
        }
    }
}            
