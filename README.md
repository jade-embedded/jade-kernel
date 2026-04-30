# jade-kernel
Microkernel for automotive and safety-critical embedded systems

## Build

```bash
make clean && make
```

Requires `aarch64-none-elf-gcc` toolchain isolated from host. See `scripts/verify-toolchain.sh`.

## QEMU Validation

Canonical launch command:

```bash
qemu-system-aarch64 \
  -M virt \
  -cpu cortex-a53 \
  -nographic \
  -kernel build/kernel.elf \
  -d int,cpu_reset \
  -D qemu.log
```

**Note:** QEMU requires `kernel.elf`, not `kernel.bin`. QEMU loads flat binaries
at a fixed address that does not match the linked load address, causing
`VBAR_EL1` and other absolute symbol references to resolve incorrectly at
runtime. The ELF file carries program headers that QEMU uses to load at the
correct address. The `kernel.bin` flat binary is intended for real hardware
flashing only.

Expected behavior:
- Kernel loads at `0x40000000` per ELF program headers
- EL2 to EL1 transition completes
- `.bss` zeroed, stack initialized at `0x40005000`
- Exception vector table installed at `0x40000800`, `VBAR_EL1` set
- `kernel_main()` entered, idles in WFE loop at EL1
- No exceptions or CPU resets
- `qemu.log` empty on clean boot
- `timeout` exit code `124` confirms kernel alive

## Validation

Run determinism check (5 boots):

```bash
for i in 1 2 3 4 5; do
  echo "Boot $i:"
  timeout 3 qemu-system-aarch64 -M virt -cpu cortex-a53 \
    -nographic -kernel build/kernel.elf \
    -d int,cpu_reset -D qemu.log 2>&1 || true
  echo "Exit: $?"
done
```

All 5 boots should terminate with exit code `124`.

