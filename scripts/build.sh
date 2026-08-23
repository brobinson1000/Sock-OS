#!/run/current-system/sw/bin/bash
set -e
if ! command -v nasm &>/dev/null || ! command -v gcc &>/dev/null || ! command -v ld &>/dev/null || ! command -v qemu-system-i386 &>/dev/null; then
    echo "Error: not installed (nasm, gcc, ld, qemu-system-i386)."
    exit 1
fi

echo "Assembling bootloader..."
nasm -f bin boot.asm -o boot.bin

echo "Assembling kernel entry..."
nasm -f elf32 kernel.asm -o kernel_entry.o

echo "Assembling ISR stubs..."
nasm -f elf32 isr.asm -o isr_stubs.o

echo "Compiling kmain.c..."
gcc -m32 -ffreestanding -fno-pic -fno-stack-protector -c kmain.c -o kmain.o

echo "Compiling gdt.c..."
gcc -m32 -ffreestanding -fno-pic -fno-stack-protector -c gdt.c -o gdt.o

echo "Compiling pic.c..."
gcc -m32 -ffreestanding -fno-pic -fno-stack-protector -c pic.c -o pic.o

echo "Compiling screen.c..."
gcc -m32 -ffreestanding -fno-pic -fno-stack-protector -c screen.c -o screen.o

echo "Compiling idt.c..."
gcc -m32 -ffreestanding -fno-pic -fno-stack-protector -c idt.c -o idt.o

echo "Compiling isr.c..."
gcc -m32 -ffreestanding -fno-pic -fno-stack-protector -c isr.c -o isr_handlers.o

echo "Compiling timer.c..."
gcc -m32 -ffreestanding -fno-pic -fno-stack-protector -c timer.c -o timer.o

echo "Compiling keyboard.c..."
echo "Compiling keyboard.c..."
gcc -m32 -ffreestanding -fno-pic -fno-stack-protector -c keyboard.c -o keyboard.o


echo "Compiling commands.c..."
gcc -m32 -ffreestanding -fno-pic  -fno-stack-protector -c yes.c -o yes.o

echo "Compiling mem.c..."
gcc -m32 -ffreestanding -fno-pic  -fno-stack-protector -c mem.c -o mem.o

echo "Linking kernel..."
ld -m elf_i386 -Ttext 0x7E00 --entry start \
   kernel_entry.o kmain.o gdt.o pic.o screen.o idt.o isr_stubs.o isr_handlers.o timer.o keyboard.o yes.o mem.o \
   --oformat binary -o kernel.bin

echo "Creating OS image..."
dd if=/dev/zero of=os-image.img bs=512 count=30
dd if=boot.bin of=os-image.img bs=512 seek=0 conv=notrunc
dd if=kernel.bin of=os-image.img bs=512 seek=1 conv=notrunc

echo "Done! Run with: qemu-system-i386 -fda os-image.img"
