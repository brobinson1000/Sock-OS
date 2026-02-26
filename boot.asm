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

; 1
cmp al, 0x31
; match s is start OS
je match_boot

; 2
cmp al, 0x32
; Advanced options for Sock0S
je match_advanced

; 3
cmp al, 0x33
; match r is reboot OS
je match_reboot

jmp get_input

match_boot:
lea si, [normBootMessage]
call print_string
call new_line

match_advanced:
lea si, [advBootMessage]
call print_string
call new_line
jmp get_input


match_reboot:
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
opt1 db "[ 1 ] SockOS*", 0
opt2 db "[ 2 ] Advanced options for SockOS", 0
opt3 db "[ 3 ] Reboot System", 0
normBootMessage db "Normal Boot Starting in ", 0
advBootMessage db "Advanced Boot Options ", 0


times 510 - ($ - $$) db 0
dw 0xAA55
