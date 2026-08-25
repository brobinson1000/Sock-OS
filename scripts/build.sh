#!/run/current-system/sw/bin/bash
set -e

# Must match `mov al, N` in boot.asm's load_kernel
SECTORS=32
IMG_SECTORS=64

for t in nasm gcc ld qemu-system-i386; do
    command -v "$t" &>/dev/null || { echo "Error: $t not installed."; exit 1; }
done

CFLAGS="-m32 -march=i686 -ffreestanding -nostdlib -fno-pic -fno-pie \
        -fno-stack-protector -fno-builtin -fno-omit-frame-pointer \
        -mno-mmx -mno-sse -mno-sse2 -mno-80387 -mno-red-zone \
        -O2 -Wall -Wextra"

echo "Assembling bootloader..."
nasm -f bin boot.asm -o boot.bin

echo "Assembling kernel entry..."
nasm -f elf32 kernel.asm -o kernel_entry.o

echo "Assembling ISR stubs..."
nasm -f elf32 isr.asm -o isr_stubs.o

for src in kmain gdt pic screen idt timer keyboard mem; do
    echo "Compiling $src.c..."
    gcc $CFLAGS -c "$src.c" -o "$src.o"
done

echo "Compiling isr.c..."
gcc $CFLAGS -c isr.c -o isr_handlers.o

for src in *.c; do
    echo "Compiling $src..."
    gcc $CFLAGS -c "$src" -o "${src%.c}.o"
done

echo "Linking kernel..."
ld -m elf_i386 -T linker.ld -nostdlib \
   kernel_entry.o kmain.o gdt.o pic.o screen.o idt.o isr_stubs.o \
   isr_handlers.o timer.o keyboard.o mem.o shell.o \
   --oformat binary -o kernel.bin

# Catch a truncated kernel at build time instead of as a mystery crash
KSIZE=$(stat -c%s kernel.bin)
KSECTORS=$(( (KSIZE + 511) / 512 ))
echo "Kernel: $KSIZE bytes ($KSECTORS sectors, bootloader loads $SECTORS)"
if [ "$KSECTORS" -gt "$SECTORS" ]; then
    echo "ERROR: kernel needs $KSECTORS sectors but boot.asm loads only $SECTORS."
    echo "       Raise both SECTORS here and 'mov al, N' in boot.asm."
    exit 1
fi

echo "Creating OS image..."
dd if=/dev/zero  of=os-image.img bs=512 count=$IMG_SECTORS status=none
dd if=boot.bin   of=os-image.img bs=512 seek=0 conv=notrunc status=none
dd if=kernel.bin of=os-image.img bs=512 seek=1 conv=notrunc status=none

echo "Done! Run with:"
echo "  qemu-system-i386 -drive file=os-image.img,format=raw,index=0,media=disk"
