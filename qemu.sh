#!/run/current-system/sw/bin/bash
echo "Running in QEMU..."
qemu-system-i386 -drive file=os-image.img,format=raw \
                  -m 512M \
                  -serial stdio \
