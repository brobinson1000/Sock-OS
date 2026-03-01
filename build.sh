#!/bin/bash
set -e

if ! command -v nasm &>/dev/null || ! command -v gcc &>/dev/null || ! command -v ld &>/dev/null || ! command -v qemu-system-i386 &>/dev/null; then
    echo "Error: Required tool(s) are not installed (nasm, gcc, ld, qemu-system-i386)."
    exit 1
fi

echo "Assembling bootloader..."
nasm -f bin boot.asm -o boot.bin

echo "Assembling kernel entry..."
nasm -f elf32 kernel.asm -o kernel_entry.o

echo "Compiling C kernel..."
gcc -m32 -ffreestanding -fno-pic -c kmain.c -o kmain.o

echo "Linking kernel..."
ld -m elf_i386 -Ttext 0x7E00 --entry start kernel_entry.o kmain.o \
   --oformat binary -o kernel.bin

echo "Creating OS image..."
dd if=boot.bin of=os-image.img bs=512 seek=0
dd if=kernel.bin of=os-image.img bs=512 seek=1

