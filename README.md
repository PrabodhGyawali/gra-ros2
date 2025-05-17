# Prerequisites
This package is intended for the following:

- **Ubuntu 24.04**
- **ROS 2 Jazzy**
- **Gazebo Harmonic**


**Important:** For the most up-to-date installation instructions, please refer to the official pages:  
- [ROS 2 Jazzy Installation Guide](https://docs.ros.org/en/jazzy/Installation.html)  
- [Gazebo Harmonic Installation Guide](https://gazebosim.org/docs/harmonic/install_ubuntu/)

Make sure to install `ros-jazzy-desktop` (which includes RViz2).

<details open>
  <summary><h2>Install ROS 2 Jazzy</h2></summary>

  1. **Enable the Ubuntu Universe Repository:**
  
      ```bash
      sudo apt install software-properties-common
      sudo add-apt-repository universe
      ```

  2. **Add ROS 2 GPG key:**

      ```bash
      sudo apt update && sudo apt install curl -y
      sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
      ```

  3. **Add ROS 2 repository:**

      ```bash
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
      ```

  4. **Install ROS 2:**

      ```bash
      sudo apt update
      sudo apt upgrade
      sudo apt install ros-jazzy-desktop
      ```

</details>
<details open>
  <summary><h2>Install Gazebo Harmonic</h2></summary>

  1. **Install necessary tools:**

      ```bash
      sudo apt-get update
      sudo apt-get install curl lsb-release gnupg
      ```
  2. **Add Gazebo repository:**

      ```bash
      sudo curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
      ```

  3. **Install Gazebo Harmonic:**

      ```bash
      sudo apt-get update
      sudo apt-get install gz-harmonic
      ```

</details>

---

# Build Instructions

1. **Source the ROS 2 Environment:**

    ```bash
    source /opt/ros/jazzy/setup.bash
    ```

2. **Create a Workspace:**

    ```bash
    mkdir -p ~/colcon_ws/src
    cd ~/colcon_ws/src
    ```

3. **Clone the Repository:**

    ```bash
    git clone https://github.com/GryphonRacingAI/gra-ros2.git .
    ```
4. **Install Necessary Tools**
    ```bash
    sudo apt install -y python3-colcon-common-extensions
    sudo apt install -y python3-rosdep
    sudo rosdep init
    rosdep update
    ```

5. **Resolve Dependencies:**

    ```bash
    cd ~/colcon_ws
    rosdep install -i --from-path src --rosdistro jazzy -y
    ```

6. **Build and Source the Workspace:**

    ```bash
    cd ~/colcon_ws
    colcon build --symlink-install
    source install/setup.bash
    ```

---

# Usage

## Environment Setup

To source the overlays automatically every time you open a new terminal, add the following lines to the `.bashrc` script:
```bash
source /opt/ros/jazzy/setup.bash
source ~/colcon_ws/install/setup.bash
```

or simply run the following
```bash
echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc
echo "source ~/colcon_ws/install/setup.bash" >> ~/.bashrc
```

Run the following command so Gazebo can find the vehicle mesh
```bash
echo "export GZ_SIM_RESOURCE_PATH=$HOME/colcon_ws/install/simulation/share/" >> ~/.bashrc
```
then continue in a new terminal.

## Launch the Simulator

To run the simulator, run the following commands

```bash
ros2 launch simulation dynamic_event.launch.py autostart:=true
```
This should launch Gazebo Sim, with the acceleration track and ADS-DV vehicle model spawned in.
![Example](https://github.com/user-attachments/assets/99254e31-ed0a-49ae-9bee-ec22e6a2810f)

The following launch arguments are provided for `dynamic_event.launch.py`
  | Argument |Description| Options | Default
--|--|--|--|
event | specifies which track to spawn in based on the dynamic event |`acceleration`, `skidpad`, `autocross`, `trackdrive` |`acceleration`
autostart | starts the simulation automatically |`true`, `false`|`true`
model_file | path to the vehicle model sdf file | Any valid path to vehicle sdf model |hard-coded path
name | sets the vehicle name in Gazebo | Any valid string|`ads_dv`
verbosity | sets the Gazebo console output verbosity | 0 - 4| `1`

## Launch Perception

To launch the perception nodes, use the following command

```bash
ros2 launch ultralytics_ros predict_with_cloud.launch.xml use_sim_time:=true yolo_model:=conev11n.pt input_topic:=/zed2i/depth_camera/image
```

| Argument |Description| Options | Default
|--|--|--|--|
| use_sim_time | uses simulation time published to /clock | `true`, `false` | `true`  |
| yolo_model | sets the model for inference | `conev11n.pt`, `conev8n.pt`, `conev8n_40.pt` | `conev11n.pt` |
| input_topic | sets camera input topic | any valid camera video topic | `/image_raw`  |

All parameters for the 3D perception node `predict_with_cloud_node` are specified in `config/predict_with_cloud_node.yaml`

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Xtreamly-Team/xtreamly-trading-lp)
