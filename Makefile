# Makefile for SockOS bootloader testing

BOOT_SRC = boot.asm
BOOT_BIN = boot.bin

all: run

$(BOOT_BIN): $(BOOT_SRC)
	nasm -f bin $(BOOT_SRC) -o $(BOOT_BIN)

# Run in QEMU
run: $(BOOT_BIN)
	qemu-system-i386 -fda $(BOOT_BIN)

# Clean
clean:
	rm -f $(BOOT_BIN)
