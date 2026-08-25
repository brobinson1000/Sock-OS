#include "shell.h"
#include "keyboard.h"
#include "screen.h"
#include "mem.h"
#include "timer.h"

#define CMD_MAX 128

static char line[CMD_MAX];
static uint32_t line_len = 0;

static void cmd_help(const char* args);
static void cmd_clear(const char* args);


#define NCOMMANDS (sizeof(commands) / sizeof(commands[0]))

struct command {
    const char* name;
    void (*fn)(const char* args);
    const char* help;
};

static const struct command commands[] = {
    { "help",   cmd_help,   "list available commands" },
    { "clear",  cmd_clear,  "clear the screen" },
};



static void dispatch(char* buf) {
    char* args = buf;
    while (*args && *args != ' ') args++;
    if (*args == ' ') {
        *args = '\0';
        args++;
    }

    if (*buf == '\0') return;

    for (uint32_t i = 0; i < NCOMMANDS; i++) {
        if (strcmp(buf, commands[i].name) == 0) {
            commands[i].fn(args);
            return;
        }
    }

    kprint("snl: command not found: ");
    kprint(buf);
    kprint("\n");
}




static void cmd_help(const char* args) {
    if (*args == '\0') {
        for (uint32_t i = 0; i < NCOMMANDS; i++) {
            kprint("  ");
            kprint(commands[i].name);
            kprint("  -  ");
            kprint(commands[i].help);
            kprint("\n");
        }
        return;
    }

    for (uint32_t i = 0; i < NCOMMANDS; i++) {
        if (strcmp(args, commands[i].name) == 0) {
            kprint(commands[i].name);
            kprint("  -  ");
            kprint(commands[i].help);
            kprint("\n");
            return;
        }
    }

    kprint("snl: help: no help topics match `");
    kprint(args);
    kprint("'\n");
}




static void cmd_clear(const char* args) {
    (void)args;
    clear_screen();
}

void shell_run(void) {
    kprint("SockOS shell. Type 'help'.\n");

    for (;;) {
        kprint("> ");
        line_len = 0;

        for (;;) {
            char c = kbd_getchar();

            if (c == '\n') {
                kprint("\n");
                line[line_len] = '\0';
                break;
            }

            if (c == '\b') {
                if (line_len > 0) {
                    line_len--;
                    kdelete();
                }
                continue;
            }

            if (c == '\t') {
                uint32_t spaces = 4 - (line_len % 4);
                while (spaces-- && line_len < CMD_MAX - 1) {
                    line[line_len++] = ' ';
                    kprint(" ");
                }
                continue;
            }
            
            if (line_len < CMD_MAX - 1) {
                line[line_len++] = c;
                char s[2] = { c, '\0' };
                kprint(s);
            }
        }

        dispatch(line);
    }
}
