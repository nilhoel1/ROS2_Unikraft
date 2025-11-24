#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building Unikraft image for ROS2...${NC}"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$WORKSPACE_ROOT"

# Check if Kraftfile exists
if [ ! -f "Kraftfile" ]; then
    echo -e "${RED}Kraftfile not found!${NC}"
    exit 1
fi

# Configure Unikraft
echo -e "${YELLOW}Configuring Unikraft...${NC}"
kraft configure

# Build Unikraft
echo -e "${YELLOW}Building Unikraft image...${NC}"
kraft build

echo -e "${GREEN}Build complete!${NC}"
echo -e "${YELLOW}To run the image, use:${NC}"
echo -e "  kraft run"
echo -e "or"
echo -e "  ./scripts/run_unikraft.sh"
