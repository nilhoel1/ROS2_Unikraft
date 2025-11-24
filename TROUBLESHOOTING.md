# Troubleshooting Guide

This guide helps you diagnose and resolve common issues when working with ROS2 on Unikraft.

## Table of Contents

1. [Development Environment Issues](#development-environment-issues)
2. [Build Issues](#build-issues)
3. [ROS2 Runtime Issues](#ros2-runtime-issues)
4. [Unikraft Issues](#unikraft-issues)
5. [DDS Issues](#dds-issues)
6. [Network Issues](#network-issues)
7. [Performance Issues](#performance-issues)

## Development Environment Issues

### Devcontainer fails to build

**Symptoms**: Docker build fails or times out

**Solutions**:
1. Check Docker is running:
   ```bash
   docker ps
   ```

2. Free up disk space:
   ```bash
   docker system prune -a
   ```

3. Increase Docker memory limits (Docker Desktop):
   - Go to Settings → Resources
   - Increase memory to at least 4GB

4. Check internet connectivity for package downloads

5. Try building manually:
   ```bash
   cd .devcontainer
   docker build -t ros2-unikraft-dev .
   ```

### VS Code cannot connect to container

**Symptoms**: "Failed to connect" error

**Solutions**:
1. Restart Docker daemon:
   ```bash
   sudo systemctl restart docker
   ```

2. Remove old containers:
   ```bash
   docker container prune
   ```

3. Rebuild container:
   - Press F1 → "Dev Containers: Rebuild Container"

## Build Issues

### ROS2 build fails with missing dependencies

**Symptoms**: `CMake Error: Could not find package...`

**Solutions**:
1. Update rosdep:
   ```bash
   rosdep update
   ```

2. Install dependencies:
   ```bash
   cd ros2_workspace
   source /opt/ros/humble/setup.bash
   rosdep install --from-paths src --ignore-src -r -y
   ```

3. Check package.xml has correct dependencies

### Colcon build fails

**Symptoms**: Build errors during `colcon build`

**Solutions**:
1. Clean build artifacts:
   ```bash
   cd ros2_workspace
   rm -rf build/ install/ log/
   ```

2. Build with verbose output:
   ```bash
   colcon build --event-handlers console_direct+ --cmake-args -DCMAKE_VERBOSE_MAKEFILE=ON
   ```

3. Build single package:
   ```bash
   colcon build --packages-select package_name
   ```

4. Check compiler version:
   ```bash
   gcc --version  # Should be 11.x for Ubuntu 22.04
   ```

### Unikraft build fails

**Symptoms**: `kraft build` errors

**Solutions**:
1. Check kraft is installed:
   ```bash
   kraft --version
   ```

2. Reinstall kraft:
   ```bash
   pip3 install --upgrade git+https://github.com/unikraft/pykraft.git
   ```

3. Clean Unikraft build:
   ```bash
   rm -rf .unikraft/
   kraft clean
   ```

4. Reconfigure:
   ```bash
   kraft configure
   kraft build
   ```

5. Check Kraftfile syntax:
   ```bash
   kraft list
   ```

## ROS2 Runtime Issues

### Nodes cannot communicate

**Symptoms**: Publisher sends but subscriber doesn't receive

**Solutions**:
1. Check both nodes are running:
   ```bash
   ros2 node list
   ```

2. Verify topic:
   ```bash
   ros2 topic list
   ros2 topic echo /topic_name
   ```

3. Check ROS_DOMAIN_ID matches:
   ```bash
   echo $ROS_DOMAIN_ID
   ```

4. Verify DDS implementation:
   ```bash
   echo $RMW_IMPLEMENTATION
   ```

5. Test with simple example:
   ```bash
   # Terminal 1
   ros2 run demo_nodes_cpp talker
   
   # Terminal 2
   ros2 run demo_nodes_cpp listener
   ```

### "Cannot find node executable" error

**Symptoms**: `ros2 run` fails to find executable

**Solutions**:
1. Source workspace:
   ```bash
   source ros2_workspace/install/setup.bash
   ```

2. Rebuild package:
   ```bash
   cd ros2_workspace
   colcon build --packages-select your_package
   ```

3. Check executable installed:
   ```bash
   ls ros2_workspace/install/your_package/lib/your_package/
   ```

4. Verify CMakeLists.txt has install() directive

### Segmentation fault

**Symptoms**: Node crashes with segfault

**Solutions**:
1. Run with debugger:
   ```bash
   gdb --args ros2 run package_name node_name
   ```

2. Check for null pointer dereferences

3. Verify all dependencies initialized

4. Build in debug mode:
   ```bash
   colcon build --cmake-args -DCMAKE_BUILD_TYPE=Debug
   ```

## Unikraft Issues

### Cannot run on KVM

**Symptoms**: `kraft run` fails with KVM error

**Solutions**:
1. Check KVM available:
   ```bash
   ls -la /dev/kvm
   egrep -c '(vmx|svm)' /proc/cpuinfo
   ```

2. Load KVM modules:
   ```bash
   sudo modprobe kvm
   sudo modprobe kvm_intel  # or kvm_amd
   ```

3. Add user to kvm group:
   ```bash
   sudo usermod -aG kvm $USER
   newgrp kvm
   ```

4. Check permissions:
   ```bash
   sudo chmod 666 /dev/kvm
   ```

### Unikraft boot hangs

**Symptoms**: Image loads but doesn't start

**Solutions**:
1. Check kernel configuration:
   ```bash
   kraft configure
   ```

2. Increase timeout:
   ```bash
   kraft run --timeout 60
   ```

3. Check logs:
   ```bash
   kraft run --log-level debug
   ```

4. Try without KVM:
   ```bash
   kraft run --plat linuxu
   ```

### Out of memory errors

**Symptoms**: Allocation failures in Unikraft

**Solutions**:
1. Increase memory in Kraftfile:
   ```yaml
   targets:
     - platform: kvm
       architecture: x86_64
       memory: 512M  # Increase this
   ```

2. Check memory allocator config in menuconfig

3. Reduce application memory usage

## DDS Issues

### Discovery fails

**Symptoms**: Nodes don't discover each other

**Solutions**:
1. Check multicast enabled:
   ```bash
   # In config/cyclonedds.xml
   <AllowMulticast>true</AllowMulticast>
   ```

2. Test multicast:
   ```bash
   # Terminal 1
   socat - UDP4-RECVFROM:7400,ip-add-membership=239.255.0.1:0.0.0.0,reuseaddr
   
   # Terminal 2
   echo "test" | socat - UDP4-SENDTO:239.255.0.1:7400
   ```

3. Use static discovery:
   ```xml
   <!-- In DDS config -->
   <Peers>
     <Peer address="192.168.1.100"/>
   </Peers>
   ```

4. Check firewall:
   ```bash
   sudo ufw status
   sudo ufw allow 7400/udp
   ```

### High latency

**Symptoms**: Messages arrive slowly

**Solutions**:
1. Tune DDS settings in config files

2. Reduce QoS history depth:
   ```cpp
   rclcpp::QoS qos(1);  // Keep only latest message
   ```

3. Use reliable instead of best-effort QoS

4. Check network configuration

5. Monitor with:
   ```bash
   ros2 topic hz /topic_name
   ```

### Message loss

**Symptoms**: Some messages don't arrive

**Solutions**:
1. Use reliable QoS:
   ```cpp
   auto qos = rclcpp::QoS(rclcpp::KeepLast(10))
     .reliable()
     .durability_volatile();
   ```

2. Increase queue size:
   ```cpp
   publisher_ = create_publisher<Type>("topic", 100);
   ```

3. Check network stability

4. Monitor dropped messages:
   ```bash
   ros2 topic info /topic_name -v
   ```

## Network Issues

### Cannot ping from unikernel

**Symptoms**: Network connectivity fails

**Solutions**:
1. Check network bridge configured in KVM

2. Verify lwIP configuration in Kraftfile

3. Check network device in kraft run:
   ```bash
   kraft run --network bridge:virbr0
   ```

4. Test with simple network tool in unikernel

### Port conflicts

**Symptoms**: "Address already in use" errors

**Solutions**:
1. Find process using port:
   ```bash
   sudo lsof -i :PORT_NUMBER
   ```

2. Kill process or change port

3. Use different ROS_DOMAIN_ID:
   ```bash
   export ROS_DOMAIN_ID=1
   ```

## Performance Issues

### Slow build times

**Solutions**:
1. Use parallel builds:
   ```bash
   colcon build --parallel-workers $(nproc)
   ```

2. Build only changed packages:
   ```bash
   colcon build --packages-select package_name
   ```

3. Use ccache:
   ```bash
   sudo apt install ccache
   export CC="ccache gcc"
   export CXX="ccache g++"
   ```

### High CPU usage

**Solutions**:
1. Check for busy loops in code

2. Add delays in callbacks:
   ```cpp
   timer_ = create_wall_timer(100ms, callback);
   ```

3. Profile with:
   ```bash
   perf record ros2 run package node
   perf report
   ```

### Memory leaks

**Solutions**:
1. Use valgrind:
   ```bash
   valgrind --leak-check=full ros2 run package node
   ```

2. Use smart pointers (std::shared_ptr)

3. Ensure proper cleanup in destructors

## Getting More Help

If these solutions don't resolve your issue:

1. **Check logs**:
   ```bash
   # ROS2 logs
   cat ~/.ros/log/latest/your_node.log
   
   # Colcon logs
   cat ros2_workspace/log/latest_build/package_name/stdout.log
   ```

2. **Enable debug logging**:
   ```bash
   export RCUTILS_CONSOLE_OUTPUT_FORMAT="[{severity}] [{name}]: {message}"
   export RCUTILS_COLORIZED_OUTPUT=1
   ros2 run --prefix 'stdbuf -o L' package node
   ```

3. **Search existing issues**:
   - GitHub Issues: https://github.com/nilhoel1/ROS2_Unikraft/issues
   - ROS Answers: https://answers.ros.org
   - Unikraft: https://github.com/unikraft/unikraft/issues

4. **Ask for help**:
   - Create a GitHub issue with:
     - System information
     - Steps to reproduce
     - Error messages
     - Relevant logs
   - ROS Discourse: https://discourse.ros.org
   - Unikraft Discord: https://unikraft.org/community/

5. **Collect system information**:
   ```bash
   # ROS2 info
   ros2 doctor
   
   # System info
   uname -a
   lsb_release -a
   docker --version
   
   # Kraft info
   kraft --version
   kraft list
   ```
