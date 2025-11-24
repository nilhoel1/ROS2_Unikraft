#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up ROS2 on Unikraft workspace...${NC}"

# Source ROS2 environment
if [ -f /opt/ros/humble/setup.bash ]; then
    source /opt/ros/humble/setup.bash
    echo -e "${GREEN}ROS2 Humble environment sourced${NC}"
else
    echo -e "${RED}ROS2 Humble not found. Please install ROS2 Humble first.${NC}"
    exit 1
fi

# Create workspace structure
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$WORKSPACE_ROOT"

# Initialize ROS2 workspace if not already done
if [ ! -d "ros2_workspace/src" ]; then
    mkdir -p ros2_workspace/src
    echo -e "${GREEN}Created ROS2 workspace directory${NC}"
fi

# Initialize Unikraft workspace if not already done
if [ ! -d "unikraft_workspace" ]; then
    mkdir -p unikraft_workspace
    echo -e "${GREEN}Created Unikraft workspace directory${NC}"
fi

# Install dependencies
echo -e "${YELLOW}Installing ROS2 dependencies...${NC}"
cd ros2_workspace
rosdep update || true
rosdep install --from-paths src --ignore-src -r -y || true

# Build ROS2 workspace
echo -e "${YELLOW}Building ROS2 workspace...${NC}"
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

echo -e "${GREEN}Setup complete!${NC}"
echo -e "${YELLOW}To use the workspace, run:${NC}"
echo -e "  source ros2_workspace/install/setup.bash"
