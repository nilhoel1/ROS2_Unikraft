#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse command line arguments
PLATFORM="${1:-kvm}"
ARCHITECTURE="${2:-x86_64}"

echo -e "${GREEN}Running Unikraft image on ${PLATFORM}/${ARCHITECTURE}...${NC}"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$WORKSPACE_ROOT"

# Check if build artifacts exist
if [ ! -d ".unikraft" ]; then
    echo -e "${RED}Unikraft build not found. Please run './scripts/build_unikraft.sh' first.${NC}"
    exit 1
fi

# Run with kraft
echo -e "${YELLOW}Starting Unikraft on ${PLATFORM}/${ARCHITECTURE}...${NC}"
kraft run --plat "$PLATFORM" --arch "$ARCHITECTURE"

echo -e "${GREEN}Unikraft instance stopped.${NC}"
