# ROS2 on Unikraft

A port of ROS2 (Robot Operating System 2) to run on Unikraft unikernels targeting Linux KVM. This project enables running ROS2 applications with DDS (Data Distribution Service) middleware in a lightweight, high-performance unikernel environment.

## Overview

This project combines:
- **ROS2 Humble**: Modern robotics middleware framework
- **Unikraft**: Lightweight unikernel for cloud and edge deployments
- **DDS Support**: Both FastDDS and CycloneDDS middleware implementations
- **KVM Target**: Optimized for running on Linux KVM hypervisor

## Features

- ✅ ROS2 Humble base system
- ✅ DDS middleware support (FastDDS and CycloneDDS)
- ✅ Unikraft KVM platform target
- ✅ Development container with all dependencies
- ✅ Example publisher/subscriber nodes
- ✅ Build and deployment scripts
- ✅ DDS configuration files

## Architecture

```
┌─────────────────────────────────────┐
│     ROS2 Application Layer          │
│  (Publisher/Subscriber Nodes)       │
├─────────────────────────────────────┤
│     ROS2 Core (rclcpp/rclpy)       │
├─────────────────────────────────────┤
│   DDS Layer (FastDDS/CycloneDDS)   │
├─────────────────────────────────────┤
│      Unikraft Libraries             │
│  (lwIP, musl, pthread-embedded)     │
├─────────────────────────────────────┤
│      Unikraft Core                  │
├─────────────────────────────────────┤
│      Linux KVM Hypervisor           │
└─────────────────────────────────────┘
```

## Prerequisites

- Docker (for devcontainer)
- VS Code with Dev Containers extension (recommended)
- Or manually: Ubuntu 22.04 with ROS2 Humble and Unikraft tools

## Quick Start

### Using Dev Container (Recommended)

1. **Clone the repository**:
   ```bash
   git clone https://github.com/nilhoel1/ROS2_Unikraft.git
   cd ROS2_Unikraft
   ```

2. **Open in VS Code**:
   ```bash
   code .
   ```

3. **Reopen in Container**:
   - Press `F1` or `Ctrl+Shift+P`
   - Select "Dev Containers: Reopen in Container"
   - Wait for the container to build (first time only)

4. **Setup the workspace**:
   ```bash
   ./scripts/setup_workspace.sh
   ```

5. **Build ROS2 packages**:
   ```bash
   cd ros2_workspace
   colcon build --symlink-install
   source install/setup.bash
   ```

6. **Build Unikraft image**:
   ```bash
   ./scripts/build_unikraft.sh
   ```

7. **Run on KVM**:
   ```bash
   ./scripts/run_unikraft.sh
   ```

## Directory Structure

```
ROS2_Unikraft/
├── .devcontainer/          # Development container configuration
│   ├── devcontainer.json   # Dev container settings
│   └── Dockerfile          # Container image definition
├── config/                 # DDS configuration files
│   ├── cyclonedds.xml      # CycloneDDS configuration
│   └── fastdds.xml         # FastDDS configuration
├── ros2_workspace/         # ROS2 workspace
│   └── src/                # ROS2 packages
│       └── ros2_unikraft_example/  # Example package
│           ├── src/        # Source files
│           ├── launch/     # Launch files
│           ├── CMakeLists.txt
│           └── package.xml
├── unikraft_workspace/     # Unikraft workspace
├── scripts/                # Build and utility scripts
│   ├── setup_workspace.sh  # Initialize workspace
│   ├── build_unikraft.sh   # Build Unikraft image
│   └── run_unikraft.sh     # Run on KVM
├── Kraftfile               # Unikraft configuration
└── README.md               # This file
```

## Building from Source

### 1. Setup ROS2 Workspace

```bash
cd ros2_workspace
source /opt/ros/humble/setup.bash
colcon build --symlink-install
source install/setup.bash
```

### 2. Configure Unikraft

The `Kraftfile` contains the Unikraft configuration:
- Platform: KVM
- Architecture: x86_64
- Libraries: musl, lwIP, pthread-embedded

```bash
kraft configure
```

### 3. Build Unikraft Image

```bash
kraft build
```

### 4. Run on KVM

```bash
kraft run --plat kvm --arch x86_64
```

## Running Examples

### Publisher-Subscriber Example

This example demonstrates DDS communication between ROS2 nodes on Unikraft.

1. **Build the example**:
   ```bash
   cd ros2_workspace
   source install/setup.bash
   colcon build --packages-select ros2_unikraft_example
   ```

2. **Run with launch file**:
   ```bash
   ros2 launch ros2_unikraft_example example.launch.py
   ```

3. **Or run nodes separately**:

   Terminal 1 - Publisher:
   ```bash
   ros2 run ros2_unikraft_example simple_publisher
   ```

   Terminal 2 - Subscriber:
   ```bash
   ros2 run ros2_unikraft_example simple_subscriber
   ```

## DDS Configuration

### Using CycloneDDS

```bash
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
export CYCLONEDDS_URI=file://$(pwd)/config/cyclonedds.xml
```

### Using FastDDS

```bash
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
export FASTRTPS_DEFAULT_PROFILES_FILE=$(pwd)/config/fastdds.xml
```

## Development

### Adding New ROS2 Packages

1. Create package in `ros2_workspace/src/`:
   ```bash
   cd ros2_workspace/src
   ros2 pkg create --build-type ament_cmake my_package
   ```

2. Build:
   ```bash
   cd ../
   colcon build --packages-select my_package
   ```

### Modifying Unikraft Configuration

Edit `Kraftfile` to add libraries or change configuration:

```yaml
libraries:
  my-lib:
    version: stable
    kconfig:
      CONFIG_MY_LIB_OPTION: 'y'
```

Then reconfigure and rebuild:
```bash
kraft configure
kraft build
```

## Troubleshooting

### Build Issues

1. **Missing dependencies**:
   ```bash
   rosdep update
   rosdep install --from-paths ros2_workspace/src --ignore-src -r -y
   ```

2. **Kraft not found**:
   ```bash
   pip3 install git+https://github.com/unikraft/pykraft.git
   ```

3. **KVM not available**:
   - Ensure KVM kernel modules are loaded: `lsmod | grep kvm`
   - Check hardware virtualization: `egrep -c '(vmx|svm)' /proc/cpuinfo`

### Runtime Issues

1. **DDS discovery failures**:
   - Check network configuration
   - Verify DDS configuration files
   - Try different RMW implementation

2. **Memory issues**:
   - Increase memory allocation in Kraftfile
   - Check Unikraft memory configuration

## Performance Considerations

Unikraft provides several advantages for ROS2 deployments:
- **Fast boot times**: < 1ms boot time
- **Small memory footprint**: Minimal overhead compared to full OS
- **High performance**: Direct hardware access, no context switching
- **Security**: Reduced attack surface

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the Apache License 2.0.

## Resources

- [ROS2 Documentation](https://docs.ros.org/en/humble/)
- [Unikraft Documentation](https://unikraft.org/docs/)
- [FastDDS Documentation](https://fast-dds.docs.eprosima.com/)
- [CycloneDDS Documentation](https://cyclonedds.io/)

## Acknowledgments

This project builds upon:
- ROS2 Humble by Open Robotics
- Unikraft by the Unikraft community
- FastDDS by eProsima
- CycloneDDS by Eclipse Foundation

## Support

For issues and questions:
- GitHub Issues: [Report issues](https://github.com/nilhoel1/ROS2_Unikraft/issues)
- ROS Discourse: [ROS Community](https://discourse.ros.org/)
- Unikraft Discord: [Join community](https://unikraft.org/community/)

## Roadmap

Future improvements:
- [ ] Support for more ROS2 distributions
- [ ] Additional DDS implementations
- [ ] ARM64 architecture support
- [ ] Xen hypervisor support
- [ ] Performance benchmarking suite
- [ ] CI/CD integration
- [ ] Pre-built binary releases
