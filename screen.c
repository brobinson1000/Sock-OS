#include "screen.h"


#define VIDEO_MEMORY 0xB8000
#define SCREEN_WIDTH 80
#define SCREEN_HEIGHT 25
#define WHITE_ON_BLACK 0x0F


static int cursor_x = 0;
static int cursor_y = 0;


static char* video = (char*)VIDEO_MEMORY;

static void scroll() {
    if (cursor_y >= SCREEN_HEIGHT) {
        // Move every row up by one
        for (int i = 0; i < (SCREEN_HEIGHT - 1) * SCREEN_WIDTH * 2; i++) {
            video[i] = video[i + SCREEN_WIDTH * 2];
        }
        // Clear the last row
        for (int i = 0; i < SCREEN_WIDTH * 2; i += 2) {
            video[(SCREEN_HEIGHT - 1) * SCREEN_WIDTH * 2 + i] = ' ';
            video[(SCREEN_HEIGHT - 1) * SCREEN_WIDTH * 2 + i + 1] = WHITE_ON_BLACK;
        }
        cursor_y = SCREEN_HEIGHT - 1;
    }
}

void clear_screen() {
    for (int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT * 2; i += 2) {
        video[i] = ' ';
        video[i + 1] = WHITE_ON_BLACK;
    }
    cursor_x = 0;
    cursor_y = 0;
}

void kprint(const char* str) {
    for (int i = 0; str[i]; i++) {
        if (str[i] == '\n') {
            cursor_x = 0;
            cursor_y++;
            scroll();
        } else {
            int offset = (cursor_y * SCREEN_WIDTH + cursor_x) * 2;
            video[offset] = str[i];
            video[offset + 1] = WHITE_ON_BLACK;
            cursor_x++;
            if (cursor_x >= SCREEN_WIDTH) {
                cursor_x = 0;
                cursor_y++;
                scroll();
            }
        }
    }
}

void kdelete(void) {
    if ( cursor_x == 0 && cursor_y == 0 ) {
        return;
    }

    if (cursor_x == 0) {
        cursor_x = SCREEN_WIDTH - 1;
        cursor_y--;
    } else {
        cursor_x--;
    }

    int offset = ( cursor_y * SCREEN_WIDTH + cursor_x) * 2;
    video[offset] = ' ';
    video[offset + 1] = WHITE_ON_BLACK;
}

void kprint_newline() {
    cursor_x = 0;
    cursor_y++;
    scroll();
}

void ktab(void) {
    cursor_x += 8;
}


void kprint_hex(uint32_t n) {
    const char* digits = "0123456789ABCDEF";
    char buf[11];
    buf[0] = '0'; buf[1] = 'x';
    for (int i = 0; i < 8; i++)
        buf[2 + i] = digits[(n >> ((7 - i) * 4)) & 0xF];
    buf[10] = '\0';
    kprint(buf);
}
