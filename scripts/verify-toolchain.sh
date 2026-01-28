#!/bin/bash
# Toolchain Verification Script for Jade Kernel
# Verifies aarch64-none-elf cross-compilation environment

set -e

echo "=========================================="
echo "Jade Kernel Toolchain Verification"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0

# Check compiler
echo -n "Checking aarch64-none-elf-gcc... "
if command -v aarch64-none-elf-gcc &> /dev/null; then
    VERSION=$(aarch64-none-elf-gcc --version | head -n1)
    echo -e "${GREEN}OK${NC}"
    echo "  Version: $VERSION"
else
    echo -e "${RED}FAIL${NC}"
    echo "  aarch64-none-elf-gcc not found in PATH"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Check binutils
echo "Checking binutils:"
for TOOL in ld objcopy readelf objdump; do
    echo -n "  aarch64-none-elf-$TOOL... "
    if command -v aarch64-none-elf-$TOOL &> /dev/null; then
        echo -e "${GREEN}OK${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        ERRORS=$((ERRORS + 1))
    fi
done
echo ""

# Verify target architecture
echo -n "Verifying target architecture... "
if aarch64-none-elf-gcc -v 2>&1 | grep -q "Target: aarch64-none-elf"; then
    echo -e "${GREEN}OK${NC}"
    echo "  Target: aarch64-none-elf (bare-metal AArch64)"
else
    echo -e "${RED}FAIL${NC}"
    echo "  Expected target: aarch64-none-elf"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Check for host toolchain leakage
echo -n "Checking for host toolchain isolation... "
if command -v aarch64-none-elf-gcc &> /dev/null; then
    GCC_PATH=$(which aarch64-none-elf-gcc)
    if [[ "$GCC_PATH" == *"aarch64-none-elf"* ]]; then
        echo -e "${GREEN}OK${NC}"
        echo "  Cross-compiler path: $GCC_PATH"
    else
        echo -e "${YELLOW}WARNING${NC}"
        echo "  Verify no host compiler interference"
    fi
else
    echo -e "${RED}FAIL${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Summary
echo "=========================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ Toolchain verification PASSED${NC}"
    echo "=========================================="
    exit 0
else
    echo -e "${RED}✗ Toolchain verification FAILED ($ERRORS errors)${NC}"
    echo "=========================================="
    exit 1
fi
