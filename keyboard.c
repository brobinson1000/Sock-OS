#include "keyboard.h"
#include "pic.h"
#include "screen.h"
#include "idt.h"

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

static int shift_pressed = 0;
static int caps_on = 0;


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
            if ( c == '\b' ) {
                kdelete();
                return;
            } else if ( c == '\n' ) {
                kprint_newline();
                return;
            } else if ( c == '\t' ) {
                ktab();
                return;
            } else {
                char str[2] = {c, '\0'};
                kprint(str);
            }
        }
    } 
}
