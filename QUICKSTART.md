# Quick Start Guide

Get up and running with ROS2 on Unikraft in minutes!

## Prerequisites

- Docker Desktop or Docker Engine installed
- VS Code with Dev Containers extension (recommended)
- Git

## 5-Minute Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/nilhoel1/ROS2_Unikraft.git
cd ROS2_Unikraft
```

### Step 2: Open in Dev Container

**Option A: VS Code (Recommended)**
```bash
code .
```
Then press `F1` and select "Dev Containers: Reopen in Container"

**Option B: Docker Compose**
```bash
docker-compose up -d ros2-unikraft-dev
docker-compose exec ros2-unikraft-dev bash
```

### Step 3: Setup Workspace

```bash
./scripts/setup_workspace.sh
```

### Step 4: Build ROS2 Example

```bash
cd ros2_workspace
source /opt/ros/humble/setup.bash
colcon build --symlink-install
source install/setup.bash
```

### Step 5: Run Example

**Terminal 1 - Publisher:**
```bash
ros2 run ros2_unikraft_example simple_publisher
```

**Terminal 2 - Subscriber:**
```bash
ros2 run ros2_unikraft_example simple_subscriber
```

You should see the publisher sending messages and the subscriber receiving them!

## Next Steps

### Build Unikraft Image

```bash
./scripts/build_unikraft.sh
```

### Run on KVM

```bash
./scripts/run_unikraft.sh
```

### Try Different DDS Implementations

**FastDDS (default):**
```bash
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
export FASTRTPS_DEFAULT_PROFILES_FILE=$(pwd)/config/fastdds.xml
```

**CycloneDDS:**
```bash
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export CYCLONEDDS_URI=file://$(pwd)/config/cyclonedds.xml
```

### Explore the Code

- **ROS2 Example**: `ros2_workspace/src/ros2_unikraft_example/`
- **Publisher**: `src/simple_publisher.cpp`
- **Subscriber**: `src/simple_subscriber.cpp`
- **Launch File**: `launch/example.launch.py`

### Using Makefile

```bash
# See all available commands
make help

# Setup workspace
make setup

# Build everything
make build-all

# Run tests
make test

# Clean build artifacts
make clean
```

## Common Commands

### ROS2 Commands

```bash
# List nodes
ros2 node list

# List topics
ros2 topic list

# Echo topic
ros2 topic echo /unikraft_topic

# Show topic info
ros2 topic info /unikraft_topic

# Check node info
ros2 node info /simple_publisher
```

### Development Commands

```bash
# Create new package
cd ros2_workspace/src
ros2 pkg create --build-type ament_cmake my_package

# Build specific package
cd ../
colcon build --packages-select my_package

# Clean and rebuild
rm -rf build/ install/ log/
colcon build --symlink-install
```

### Unikraft Commands

```bash
# List available libraries
kraft list

# Configure Unikraft
kraft configure

# Build Unikraft image
kraft build

# Run with specific platform
kraft run --plat kvm --arch x86_64

# Clean Unikraft build
kraft clean
```

## Troubleshooting Quick Tips

### ROS2 nodes can't communicate?
```bash
# Check ROS domain
echo $ROS_DOMAIN_ID

# Try setting explicitly
export ROS_DOMAIN_ID=0

# Verify DDS
echo $RMW_IMPLEMENTATION
```

### Build fails?
```bash
# Update dependencies
cd ros2_workspace
rosdep update
rosdep install --from-paths src --ignore-src -r -y

# Clean and rebuild
rm -rf build/ install/ log/
colcon build
```

### Unikraft issues?
```bash
# Reinstall kraft
pip3 install --upgrade git+https://github.com/unikraft/pykraft.git

# Clean Unikraft
rm -rf .unikraft/
kraft configure
kraft build
```

## Resources

- **Full Documentation**: See [README.md](README.md)
- **Architecture**: See [ARCHITECTURE.md](ARCHITECTURE.md)
- **Troubleshooting**: See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Contributing**: See [CONTRIBUTING.md](CONTRIBUTING.md)

## Getting Help

- **GitHub Issues**: [Report problems](https://github.com/nilhoel1/ROS2_Unikraft/issues)
- **ROS Community**: [ROS Discourse](https://discourse.ros.org)
- **Unikraft Community**: [Unikraft Discord](https://unikraft.org/community/)

## What's Next?

1. **Modify the example** - Edit `simple_publisher.cpp` to send custom messages
2. **Create your own package** - Follow the package creation steps above
3. **Experiment with DDS** - Try different middleware implementations
4. **Build for Unikraft** - Port your ROS2 application to run on Unikraft
5. **Deploy on KVM** - Run your unikernel on Linux KVM

Happy coding! 🚀
