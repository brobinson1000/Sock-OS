bits 16
org 0x7c00

mov si, 0

video_mode:
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    lea si, [os]
    call print_string
    call new_line

    lea si, [version]
    call print_string
    call new_line

    lea si, [link]
    call print_string
    call new_line

    lea si, [prompt]
    call print_string
    call new_line

    lea si, [opt1]
    call print_string
    call new_line

    lea si, [opt2]
    call print_string
    call new_line

    lea si, [opt3]
    call print_string
    call new_line

get_input:
    mov ah, 0x00
    int 0x16

    cmp al, 0x0D
    je done_input

    cmp al, 0x73
    je match_s

    cmp al, 0x72
    je match_r

    jmp get_input

match_s:
    lea si, [message]
    call print_string
    jmp get_input

match_r:
    mov ax, 0x00
    int 0x19


done_input:
    jmp $

print_string:
    push si
    mov ah, 0x0e

print_char:
    mov al, [si]
    cmp al, 0
    je done_printing
    int 0x10
    inc si
    jmp print_char

done_printing:
    pop si
    ret

new_line:
    push si
    mov ah, 0x0e
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    pop si
    ret

os db "Sock OS", 0
version db "Version 1.00.0000 Sock OS", 0
link db "https://github.com/brobinson1000/Sock-OS.git", 0
prompt db "Boot Menu", 0
opt1 db "SockOS*", 0
opt2 db "Advanced options for SockOS", 0
opt3 db "Reboot System", 0
message db "You entered S", 0

times 510 - ($ - $$) db 0
dw 0xAA55

