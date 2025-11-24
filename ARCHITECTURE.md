# Architecture Overview

## System Architecture

The ROS2 on Unikraft system is designed with a layered architecture that enables ROS2 applications to run efficiently on Unikraft unikernels.

### Layer Breakdown

#### 1. Application Layer
- ROS2 nodes (publishers, subscribers, services)
- Custom robotics applications
- Launch files for orchestration

#### 2. ROS2 Core Layer
- **rclcpp**: C++ client library
- **rclpy**: Python client library (future support)
- **rcl**: ROS Client Library (core functionality)
- **rmw**: ROS Middleware Interface (abstraction layer)

#### 3. DDS Middleware Layer

Two DDS implementations are supported:

##### FastDDS (eProsima)
- Default ROS2 middleware
- RTPS protocol implementation
- High performance, feature-rich
- Configurable QoS policies

##### CycloneDDS (Eclipse)
- Lightweight alternative
- Good performance characteristics
- Smaller memory footprint
- Simple configuration

#### 4. Unikraft Libraries Layer

Key libraries integrated:
- **musl**: Lightweight C library
- **lwIP**: Lightweight IP stack for networking
- **pthread-embedded**: POSIX threads implementation
- **vfscore**: Virtual filesystem support
- **uknetdev**: Network device abstraction

#### 5. Unikraft Core
- Microkernel architecture
- Minimal kernel footprint
- Direct hardware access
- Fast system calls

#### 6. Hypervisor Layer
- Linux KVM hypervisor
- Hardware-assisted virtualization
- Isolation and security

## Data Flow

### Publisher-Subscriber Communication

```
Publisher Node
    ↓
rclcpp::publish()
    ↓
RMW Layer (abstraction)
    ↓
DDS Implementation (FastDDS/CycloneDDS)
    ↓
UDP/IP Stack (lwIP)
    ↓
Network Device (virtio-net)
    ↓
KVM Virtual Network
    ↓
Network Device (virtio-net)
    ↓
UDP/IP Stack (lwIP)
    ↓
DDS Implementation (FastDDS/CycloneDDS)
    ↓
RMW Layer (abstraction)
    ↓
rclcpp::callback()
    ↓
Subscriber Node
```

## Memory Management

### Unikraft Memory Layout

```
┌─────────────────────────┐ High Address
│   Stack (per thread)    │
├─────────────────────────┤
│   Heap (dynamic alloc)  │
├─────────────────────────┤
│   BSS (uninitialized)   │
├─────────────────────────┤
│   Data (initialized)    │
├─────────────────────────┤
│   Text (code)           │
├─────────────────────────┤
│   Kernel                │
└─────────────────────────┘ Low Address
```

### Memory Optimization Strategies

1. **Static Allocation**: Where possible, use static allocation to reduce heap fragmentation
2. **Pool Allocation**: DDS uses memory pools for message buffers
3. **Zero-Copy**: Direct buffer sharing between layers
4. **Lazy Loading**: Libraries loaded on-demand

## Threading Model

### Unikraft Threading

- Cooperative or preemptive scheduling (configurable)
- pthread-embedded provides POSIX thread API
- Minimal context switching overhead
- Thread-local storage support

### ROS2 Executor

- Single-threaded executor (default)
- Multi-threaded executor (optional)
- Callback groups for organization
- Priority-based execution

## Network Architecture

### Network Stack

```
Application (ROS2 nodes)
        ↓
    Socket API
        ↓
      lwIP
   ┌────┴────┐
   │  TCP    │  UDP (used by DDS)
   └────┬────┘
        │
      IPv4/IPv6
        │
   Network Device
   (virtio-net)
```

### DDS Discovery

1. **Multicast Discovery** (default):
   - Uses multicast groups for automatic peer discovery
   - Suitable for local networks

2. **Static Discovery** (configurable):
   - Pre-configured peer list
   - Better for constrained environments

## Build Process

### Compilation Flow

```
1. ROS2 Workspace Build
   ├── colcon discovers packages
   ├── CMake configures each package
   ├── Compiles C++ sources
   └── Links with ROS2 libraries

2. Unikraft Build
   ├── kraft reads Kraftfile
   ├── Fetches required libraries
   ├── Configures kernel (kconfig)
   ├── Compiles kernel + libraries
   └── Links into single binary

3. Integration (future work)
   ├── Package ROS2 binaries
   ├── Create initrd/filesystem
   └── Bundle with Unikraft image
```

## Performance Characteristics

### Boot Time
- Traditional OS: ~seconds
- Unikraft: < 1ms
- Impact: Faster deployment and restart

### Memory Footprint
- Traditional OS + ROS2: ~500MB+
- Unikraft + ROS2: ~50-100MB (projected)
- Impact: More efficient resource usage

### Latency
- Reduced: No kernel mode transitions
- Optimized: Direct hardware access
- Predictable: Minimal jitter

## Security Considerations

### Attack Surface Reduction
- Only necessary libraries included
- No unnecessary services
- Minimal code base

### Isolation
- Hardware-assisted virtualization (KVM)
- No multi-user system
- Single application per unikernel

### Network Security
- Firewall at hypervisor level
- Encrypted DDS communication (configurable)
- Secure discovery mechanisms

## Scalability

### Horizontal Scaling
- Multiple unikernel instances
- Load balancing at hypervisor level
- DDS handles multi-participant scenarios

### Vertical Scaling
- Resource allocation via hypervisor
- Dynamic memory adjustment
- CPU pinning for determinism

## Future Enhancements

1. **ARM64 Support**: Cross-compilation for ARM platforms
2. **Xen Support**: Alternative hypervisor backend
3. **RDMA**: Remote Direct Memory Access for ultra-low latency
4. **Zero-Copy DDS**: Direct memory sharing between nodes
5. **Hardware Acceleration**: Offload to specialized hardware
