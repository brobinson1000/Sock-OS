<p align="center">
  <img src="assets/sockos.svg" alt="SockOS" width="300">
</p>

<p align="center">
  <em>A 32-bit x86 operating system built from scratch — bootloader, kernel, and all.</em>
</p>

<p align="center">
  <img alt="Language" src="https://img.shields.io/badge/built%20with-C%20%26%20x86%20ASM-00599C">
  <img alt="Architecture" src="https://img.shields.io/badge/arch-x86%20(i386)-555555">
  <img alt="Status" src="https://img.shields.io/badge/status-experimental-orange">
  <img alt="License" src="https://img.shields.io/badge/license-Apache%202.0-blue">
</p>

---

## What is SockOS?

SockOS is a bare-metal operating system for 32-bit x86, written in C and x86 assembly with
no existing kernel, bootloader, or standard library underneath it. A custom bootloader
brings the machine up, switches the CPU from real mode into protected mode, installs its
own descriptor tables, and hands control to a freestanding kernel that manages physical
memory and services interrupts.

The project is a hands-on exploration of operating system internals and the x86 boot
process — the layers that are usually hidden behind GRUB and libc.

## Booting

<p align="center">
  <img src="assets/boot.png" alt="SockOS booting in QEMU" width="600">
</p>

> Drop in a screenshot or GIF of the kernel booting. For an OS project this is the single
> most convincing thing on the page — it proves the thing runs before anyone reads a line.

## Features

- **Custom bootloader** — loads the kernel off disk and transfers control without GRUB or any third-party loader.
- **Protected mode entry** — real mode to 32-bit protected mode transition, including A20 line enabling.
- **Descriptor tables** — hand-built GDT with configured privilege rings, and an IDT wired to real handlers.
- **Interrupt handling** — assembly ISR and IRQ stubs dispatching into C, with the PIC remapped clear of CPU exception vectors.
- **Physical memory manager** — bitmap frame allocator built from the boot-time memory map.
- **Freestanding build** — compiled `-ffreestanding` against a cross-compiler, no host runtime assumptions.

> Trim or extend this list to match what's actually in the tree today. If there's a VGA
> text driver, keyboard input, paging, or a heap allocator, they belong here — those are
> the first things a reader scans for.

## Getting started

### Requirements

- An `x86_64-elf` cross-compiler ([OSDev build guide](https://wiki.osdev.org/GCC_Cross-Compiler))
- GNU Make
- QEMU
- xorriso

> Building the cross-compiler is the slowest part of setup — budget 30–60 minutes for the
> first run.

### Build

```bash
git clone https://github.com/brobinson1000/Sock-OS.git
cd Sock-OS
make iso
```

### Run

```bash
make run
```

Pass the toolchain explicitly if your cross-compiler isn't on the default prefix:

```bash
make run TOOLCHAIN=x86_64-elf
```

Clean up build artifacts with `make clean`.

### Real hardware

The generated ISO boots on physical x86 machines as well as under emulation. Write it to a
USB drive with `dd` and boot from it.

> Worth naming what you actually tested it on — a concrete machine is more convincing than
> the claim by itself.

## Project layout

```
boot/       bootloader and real-mode entry
kernel/     kernel entry, interrupts, memory management
include/    shared headers
linker.ld   kernel memory layout
GNUmakefile build definitions
```

> Adjust to match the real tree.

## Design notes

**Boot path.** The bootloader loads the kernel image from disk, enables the A20 line, loads
a GDT, and performs the far jump into 32-bit protected mode before calling into the C
kernel entry point.

**Interrupts.** Assembly stubs push a consistent register frame and jump to a common
dispatcher, which calls the registered C handler for the vector. The PIC is remapped so
hardware IRQs don't collide with CPU exception vectors.

**Memory.** Physical frames are tracked in a bitmap built from the memory map obtained at
boot, so the allocator knows which regions the firmware has reserved.

## Roadmap

- [ ] Paging and virtual memory
- [ ] Keyboard driver
- [ ] Kernel heap allocator
- [ ] Task scheduling
- [ ] User mode and syscalls

## Contributing

Issues and pull requests are welcome. For larger changes, open an issue first to discuss
the direction.

## License

Apache 2.0 — see [LICENSE](LICENSE).
