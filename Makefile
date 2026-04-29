# Jade Kernel Build System
# Target: ARMv8-A (AArch64) bare-metal
# Toolchain: aarch64-none-elf-gcc

# Toolchain Configuration
CROSS_COMPILE = aarch64-none-elf-
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
READELF = $(CROSS_COMPILE)readelf

# Build Directories
SRC_DIR = src
BUILD_DIR = build
ARCH_DIR = $(SRC_DIR)/arch/aarch64
BOOT_DIR = $(SRC_DIR)/boot

# Compiler Flags (bare-metal, freestanding)
CFLAGS = -Wall -Wextra -Werror \
         -ffreestanding \
         -nostdlib \
         -nostartfiles \
         -O2 \
         -mcpu=cortex-a53 \
         -std=c11

# Assembler Flags
ASFLAGS = -mcpu=cortex-a53

# Linker Flags (will use custom script in later tasks)
LDFLAGS = -nostdlib -T src/arch/aarch64/kernel.ld

# Source Files (to be populated)
ASM_SOURCES = src/boot/start.S \
              src/arch/aarch64/vectors.S

C_SOURCES = src/kernel.c

# Object Files
ASM_OBJECTS = $(patsubst $(SRC_DIR)/%.S,$(BUILD_DIR)/%.o,$(ASM_SOURCES))
C_OBJECTS = $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(C_SOURCES))
OBJECTS = $(ASM_OBJECTS) $(C_OBJECTS)

# Output Files
KERNEL_ELF = $(BUILD_DIR)/kernel.elf
KERNEL_BIN = $(BUILD_DIR)/kernel.bin

# Phony Targets
.PHONY: all clean verify run

# Default Target
all: verify $(KERNEL_BIN)

# Verify toolchain before building
verify:
	@./scripts/verify-toolchain.sh

# Link kernel ELF
$(KERNEL_ELF): $(OBJECTS)
	@echo "Linking $@"
	@mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) -o $@ $^

# Generate flat binary from ELF
$(KERNEL_BIN): $(KERNEL_ELF)
	@echo "Generating $@"
	$(OBJCOPY) -O binary $< $@
	@echo "Build complete: $@"

# Compile C sources
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@echo "Compiling $<"
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# Assemble assembly sources
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.S
	@echo "Assembling $<"
	@mkdir -p $(dir $@)
	$(CC) $(ASFLAGS) -x assembler-with-cpp -c $< -o $@

# Clean build artifacts
clean:
	@echo "Cleaning build directory"
	@rm -rf $(BUILD_DIR)

# QEMU Configuration
QEMU = qemu-system-aarch64
QEMU_FLAGS = -M virt \
             -cpu cortex-a53 \
             -nographic \
             -kernel $(KERNEL_ELF) \
             -d int,cpu_reset \
             -D qemu.log

# Run in QEMU
run: $(KERNEL_BIN)
	@echo "Launching QEMU (5-second test, then auto-exit)..."
	@timeout 5 $(QEMU) $(QEMU_FLAGS) || true
	@echo ""
	@echo "QEMU test complete. Check qemu.log for details."

# Run with debug logging
debug: $(KERNEL_BIN)
	@echo "Launching QEMU with debug logging (Ctrl-A X to exit)..."
	$(QEMU) $(QEMU_FLAGS) $(QEMU_DEBUG_FLAGS)
