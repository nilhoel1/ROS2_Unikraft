from launch import LaunchDescription
from launch_ros.actions import Node


def generate_launch_description():
    """
    Launch file for ROS2 on Unikraft example
    Starts both publisher and subscriber nodes
    """
    return LaunchDescription([
        Node(
            package='ros2_unikraft_example',
            executable='simple_publisher',
            name='simple_publisher',
            output='screen',
            parameters=[{
                'use_sim_time': False
            }]
        ),
        Node(
            package='ros2_unikraft_example',
            executable='simple_subscriber',
            name='simple_subscriber',
            output='screen',
            parameters=[{
                'use_sim_time': False
            }]
        ),
    ])
