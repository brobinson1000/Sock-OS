<div align="center">

# SockOS 

**Custom 32-bit operating system built with C and x86_ASM**

</div>

<p>SockOS is a 32-bit x86-64 operating system built using C and x86_ASM. It is powered with a custom bootloader and utilizes the GNU Make build system. This project was created to teach myself about operating system internals and dive deeper on what actually happens in the boot process. This project is currently being updated.</p>

## Prerequisites

- x86_64-elf Cross-Compiler
- GNU Make
- QEMU
- xorriso

> **Note:** You can build the cross-compiler by following the [OSDev GCC Cross-Compiler Guide](https://wiki.osdev.org/GCC_Cross-Compiler).

## Building

The build process is automated by the GNUmakefile.

#### Build and Run

```bash
make run         # Build and run the ISO in QEMU
make iso         # Build a bootable ISO
make clean       # Remove all build artifacts
```

#### Linux

```bash
make iso TOOLCHAIN=x86_64-elf
make run TOOLCHAIN=x86_64-elf
```


## License

This project is licensed under the Apache License 2.0. See the [LICENSE](./LICENSE) file for details.

