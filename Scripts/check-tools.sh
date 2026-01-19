#!/bin/bash
# Check required tools for iOS UI testing workflow
#
# Run this before using the ios-ui-validation skill to ensure
# all required tools are installed and configured.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

ERRORS=0

check() {
    local name="$1"
    local cmd="$2"
    local install_hint="$3"

    if eval "$cmd" &>/dev/null; then
        echo -e "${GREEN}✓${NC} $name"
        return 0
    else
        echo -e "${RED}✗${NC} $name"
        echo -e "  ${YELLOW}→ $install_hint${NC}"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

echo "Checking required tools for iOS UI testing..."
echo ""

# Xcode Command Line Tools
check "Xcode Command Line Tools" \
    "xcode-select -p" \
    "Install: xcode-select --install"

# xcodebuild
check "xcodebuild" \
    "which xcodebuild" \
    "Install Xcode from App Store"

# xcrun
check "xcrun" \
    "which xcrun" \
    "Part of Xcode Command Line Tools"

# xcresulttool
check "xcresulttool" \
    "xcrun xcresulttool version" \
    "Part of Xcode Command Line Tools (Xcode 11+)"

# Swift
check "Swift toolchain" \
    "which swift" \
    "Install Xcode or Swift toolchain from swift.org"

# Swift version 6.0+
check "Swift 6.0+" \
    "swift --version | grep -E 'Swift version [6-9]\.|Swift version [1-9][0-9]\.'" \
    "Update Xcode 16+ or Swift toolchain"

# simctl (iOS Simulator)
check "simctl (Simulator)" \
    "xcrun simctl help" \
    "Part of Xcode Command Line Tools"

# Check for booted simulators or available devices
check "iOS Simulators available" \
    "xcrun simctl list devices available | grep -i iphone" \
    "Open Xcode → Settings → Platforms → Download iOS Simulator"

# Homebrew (optional but recommended)
echo ""
echo "Optional tools:"
if which brew &>/dev/null; then
    echo -e "${GREEN}✓${NC} Homebrew"
else
    echo -e "${YELLOW}○${NC} Homebrew (optional)"
    echo -e "  ${YELLOW}→ Install: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${NC}"
fi

echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}All required tools are installed!${NC}"
    exit 0
else
    echo -e "${RED}Missing $ERRORS required tool(s). Install them and re-run this script.${NC}"
    exit 1
fi
