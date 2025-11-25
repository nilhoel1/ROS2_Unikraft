# Contributing to ROS2 on Unikraft

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

We are committed to providing a welcoming and inclusive environment for all contributors. Please be respectful and constructive in all interactions.

## How to Contribute

### Reporting Bugs

Before reporting a bug:
1. Check if the issue already exists in GitHub Issues
2. Verify it's reproducible in the latest version
3. Collect relevant information (logs, configuration, etc.)

When reporting:
- Use a clear, descriptive title
- Describe the expected behavior
- Describe the actual behavior
- Include steps to reproduce
- Provide system information
- Attach relevant logs and screenshots

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When suggesting:
- Use a clear, descriptive title
- Explain the current behavior
- Explain the desired behavior
- Explain why this enhancement would be useful
- Provide examples of how it would be used

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/my-feature`
3. **Make your changes**
4. **Test thoroughly**
5. **Commit with clear messages**
6. **Push to your fork**
7. **Open a pull request**

#### Pull Request Guidelines

- Follow the existing code style
- Write clear commit messages
- Include tests for new functionality
- Update documentation as needed
- Keep changes focused and atomic
- Reference related issues

## Development Setup

### Prerequisites

- Docker and VS Code with Dev Containers extension
- Or: Ubuntu 22.04, ROS2 Humble, Unikraft tools

### Setting Up Development Environment

1. Clone the repository:
   ```bash
   git clone https://github.com/nilhoel1/ROS2_Unikraft.git
   cd ROS2_Unikraft
   ```

2. Open in dev container (VS Code):
   - Press F1 → "Dev Containers: Reopen in Container"

3. Setup workspace:
   ```bash
   make setup
   ```

### Building

```bash
# Build ROS2 workspace
make build-ros2

# Build Unikraft image
make build-unikraft

# Build everything
make build-all
```

### Testing

```bash
# Run ROS2 tests
make test
```

## Code Style

### C++ Code Style

We follow the ROS2 C++ style guide:
- Use `snake_case` for variables and functions
- Use `PascalCase` for classes
- 2-space indentation
- 100 character line limit
- Use C++17 features

Example:
```cpp
class MyPublisher : public rclcpp::Node
{
public:
  MyPublisher()
  : Node("my_publisher")
  {
    publisher_ = this->create_publisher<std_msgs::msg::String>("topic", 10);
  }

private:
  rclcpp::Publisher<std_msgs::msg::String>::SharedPtr publisher_;
};
```

### Python Code Style

Follow PEP 8:
- 4-space indentation
- 79 character line limit
- `snake_case` for variables and functions
- `PascalCase` for classes

### Shell Scripts

- Use `#!/bin/bash` shebang
- Set `set -e` for error handling
- Use meaningful variable names
- Comment complex sections
- Quote variables: `"$VAR"`

## Project Structure

```
ROS2_Unikraft/
├── .devcontainer/       # Development container
├── config/              # Configuration files
├── ros2_workspace/      # ROS2 packages
├── unikraft_workspace/  # Unikraft workspace
├── scripts/             # Utility scripts
└── docs/                # Additional documentation
```

## Adding New Features

### Adding a ROS2 Package

1. Create package:
   ```bash
   cd ros2_workspace/src
   ros2 pkg create --build-type ament_cmake my_package
   ```

2. Implement functionality

3. Update CMakeLists.txt and package.xml

4. Build and test:
   ```bash
   cd ../
   colcon build --packages-select my_package
   colcon test --packages-select my_package
   ```

### Adding Unikraft Libraries

1. Edit Kraftfile:
   ```yaml
   libraries:
     my-lib:
       version: stable
       kconfig:
         CONFIG_MY_LIB: 'y'
   ```

2. Reconfigure and rebuild:
   ```bash
   kraft configure
   kraft build
   ```

## Testing Guidelines

### Unit Tests

- Use Google Test for C++
- Use pytest for Python
- Test edge cases and error conditions
- Aim for high code coverage

### Integration Tests

- Test ROS2 node communication
- Test DDS discovery
- Test error handling
- Test with different configurations

### Performance Tests

- Measure boot time
- Measure memory usage
- Measure message latency
- Measure throughput

## Documentation

### Code Documentation

- Document all public APIs
- Use Doxygen for C++
- Use docstrings for Python
- Include usage examples

Example:
```cpp
/**
 * @brief Publishes messages to a topic
 * 
 * This class demonstrates basic ROS2 publishing functionality
 * on Unikraft.
 * 
 * @param topic_name Name of the topic to publish to
 */
class MyPublisher : public rclcpp::Node
{
  // ...
};
```

### User Documentation

- Update README.md for user-facing changes
- Add examples for new features
- Document configuration options
- Include troubleshooting tips

## Review Process

All contributions go through code review:

1. **Automated checks**: CI runs tests and linters
2. **Maintainer review**: Code quality and design
3. **Testing**: Verify functionality
4. **Documentation**: Check completeness
5. **Approval**: Merge when ready

## Commit Messages

Follow conventional commits format:

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance

Example:
```
feat(ros2): add new publisher example

Adds a simple publisher node that demonstrates DDS communication
on Unikraft with configurable message rate.

Closes #123
```

## Release Process

1. Version bump in relevant files
2. Update CHANGELOG.md
3. Create release branch
4. Final testing
5. Tag release
6. Publish release notes

## Getting Help

- GitHub Issues: For bugs and features
- GitHub Discussions: For questions and ideas
- ROS Discourse: For ROS-related questions
- Unikraft Discord: For Unikraft-related questions

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.

## Recognition

Contributors are recognized in:
- CONTRIBUTORS.md file
- Release notes
- Project documentation

Thank you for contributing to ROS2 on Unikraft! 🚀
