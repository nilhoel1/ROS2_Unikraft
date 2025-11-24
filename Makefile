.PHONY: help setup build-ros2 build-unikraft run clean test

# Colors for output
GREEN  := \033[0;32m
YELLOW := \033[1;33m
NC     := \033[0m # No Color

help:
	@echo "$(GREEN)ROS2 on Unikraft - Build System$(NC)"
	@echo ""
	@echo "Available targets:"
	@echo "  $(YELLOW)setup$(NC)          - Initialize workspace and install dependencies"
	@echo "  $(YELLOW)build-ros2$(NC)     - Build ROS2 workspace"
	@echo "  $(YELLOW)build-unikraft$(NC) - Build Unikraft image"
	@echo "  $(YELLOW)build-all$(NC)      - Build both ROS2 and Unikraft"
	@echo "  $(YELLOW)run$(NC)            - Run Unikraft image on KVM"
	@echo "  $(YELLOW)test$(NC)           - Run ROS2 tests"
	@echo "  $(YELLOW)clean$(NC)          - Clean build artifacts"
	@echo "  $(YELLOW)clean-all$(NC)      - Clean everything including dependencies"
	@echo ""

setup:
	@echo "$(GREEN)Setting up workspace...$(NC)"
	@./scripts/setup_workspace.sh

build-ros2:
	@echo "$(GREEN)Building ROS2 workspace...$(NC)"
	@cd ros2_workspace && \
		. /opt/ros/humble/setup.bash && \
		colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

build-unikraft:
	@echo "$(GREEN)Building Unikraft image...$(NC)"
	@./scripts/build_unikraft.sh

build-all: build-ros2 build-unikraft
	@echo "$(GREEN)Build complete!$(NC)"

run:
	@echo "$(GREEN)Running Unikraft on KVM...$(NC)"
	@./scripts/run_unikraft.sh

test:
	@echo "$(GREEN)Running ROS2 tests...$(NC)"
	@cd ros2_workspace && \
		. /opt/ros/humble/setup.bash && \
		. install/setup.bash && \
		colcon test && \
		colcon test-result --verbose

clean:
	@echo "$(YELLOW)Cleaning build artifacts...$(NC)"
	@rm -rf ros2_workspace/build ros2_workspace/install ros2_workspace/log
	@rm -rf .unikraft/build
	@echo "$(GREEN)Clean complete!$(NC)"

clean-all: clean
	@echo "$(YELLOW)Cleaning all dependencies...$(NC)"
	@rm -rf .unikraft
	@echo "$(GREEN)Deep clean complete!$(NC)"

# Development targets
dev-shell:
	@echo "$(GREEN)Starting development shell with ROS2 environment...$(NC)"
	@cd ros2_workspace && \
		tmpfile=$$(mktemp .dev_shell_rc.XXXXXX) && \
		echo '. /opt/ros/humble/setup.bash' > $$tmpfile && \
		echo '. install/setup.bash 2>/dev/null || true' >> $$tmpfile && \
		/bin/bash --rcfile $$tmpfile && \
		rm -f $$tmpfile
list-packages:
	@echo "$(GREEN)ROS2 Packages:$(NC)"
	@cd ros2_workspace && \
		. /opt/ros/humble/setup.bash && \
		. install/setup.bash 2>/dev/null && \
		colcon list || echo "No packages built yet. Run 'make build-ros2' first."

format:
	@echo "$(GREEN)Formatting code...$(NC)"
	@find ros2_workspace/src -name "*.cpp" -o -name "*.hpp" | xargs clang-format -i || true
	@echo "$(GREEN)Format complete!$(NC)"
