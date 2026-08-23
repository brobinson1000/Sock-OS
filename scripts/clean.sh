#!/run/current-system/sw/bin/bash
echo "Cleaning old binaries.."

rm -f boot.bin
rm -f kernel.bin
rm -f kernel_entry.o
rm -f kmain.o
rm -f os-image.img

echo "Done"
