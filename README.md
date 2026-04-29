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
  -kernel build/kernel.bin \
  -d int,cpu_reset \
  -D qemu.log
```

Expected behavior:
- Kernel loads at `0x40080000` (QEMU virt flat binary default)
- EL2 to EL1 transition completes
- `.bss` zeroed, stack initialized at `0x40005000`
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
    -nographic -kernel build/kernel.bin \
    -d int,cpu_reset -D qemu.log 2>&1 || true
  echo "Exit: $?"
done
```

All 5 boots should terminate with exit code `124`.
