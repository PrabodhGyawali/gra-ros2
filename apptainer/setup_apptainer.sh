#!bin/bash

# University Red Hat apptainer container setup in: '/local/data/$USER'

# Paste below into a shell

SETUP_DIR="/local/data/$USER"
INSTALL_ZED="no"
ROS_DISTRO="jazzy"

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Set up an Apptainer container environment for ROS Jazzy and related dependencies."
    echo
    echo "Options:"
    echo "  -z, --zed        Enable ZED SDK installation (default: disabled)"
    echo "  -d, --dir DIR    Specify setup directory (default: /local/data/$USER)"
    echo "  -h, --help       Display this help message and exit"
    echo
    echo "Example:"
    echo "  $0 --zed --dir /custom/path"
    echo "  $0 -z -d /custom/path"
    exit 0
}

while [[ "$#" -gt 0 ]]; do 
    case $1 in 
        -z|--zed) INSTALL_ZED="yes" ;;
        -r|--ros-distro) ROS_DISTRO="$2"; shift ;;
        -d|--dir) SETUP_DIR="$2" ; shift ;;
        -h|--help) show_help ;;
        *) echo "Unknown option: $1"; show_help ;;
    esac
    shift
done 

# Validate ROS distro
if [[ "$ROS_DISTRO" != "jazzy" && "$ROS_DISTRO" != "humble" ]]; then
    echo "Error: Invalid ROS distribution '$ROS_DISTRO'. Must be 'jazzy' or 'humble'."
    show_help
fi

# Set distro-specific variables
ros_distro_lower=$(echo "$ROS_DISTRO" | tr '[:upper:]' '[:lower:]')
if [[ "$ROS_DISTRO" == "jazzy" ]]; then
    ubuntu_codename="24"
    ubuntu_repo="2404"
    base_image="osrf/ros:jazzy-desktop-full"
    python_ver="3.12"
    gz_ver="harmonic"
    remove_pkg="ros-jazzy-simulation"
else
    ubuntu_codename="22"
    ubuntu_repo="2204"
    base_image="osrf/ros:humble-desktop-full"
    python_ver="3.10"
    gz_ver="fortress"
    remove_pkg="ros-humble-gazebo-ros"
fi

zed_file="ZED_SDK_Ubuntu${ubuntu_codename}_cuda12.8_tensorrt10.9_v5.0.5.zstd.run"
zed_url="https://download.stereolabs.com/zedsdk/5.0/cu12/ubuntu${ubuntu_codename}"
cuda_keyring_url="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu${ubuntu_repo}/x86_64/cuda-keyring_1.1-1_all.deb"

SETUP_DIR=$(realpath -m "$SETUP_DIR")

echo "Setting up $SETUP_DIR for user $USER with ROS $ROS_DISTRO"
mkdir -p "$SETUP_DIR"
cd "$SETUP_DIR"
echo "Generating ros_${ros_distro_lower}.def for $ROS_DISTRO..."

# Dynamic definition file generation
cat > "ros_${ros_distro_lower}.def" << EOF
Bootstrap: docker
From: ${base_image}
%files
    /local/data/<username>/ros_gz_bridge.py /local/data/<username>/ros_gz_bridge.py
$( [[ "$INSTALL_ZED" == "yes" ]] && echo "    /local/data/<username>/${zed_file} /local/data/<username>/${zed_file}" )
    cuda-keyring_1.1-1_all.deb /local/data/<username>/cuda-keyring_1.1-1_all.deb
    /local/data/<username>/colcon_ws/src /local/data/<username>/colcon_ws/src

    %post
    # Simulation 
    apt-get -y update
    apt-get -y install vim
    apt-get -y install ros-${ros_distro_lower}-pcl-ros
    apt-get -y install python3-pip
    apt-get -y install ros-${ros_distro_lower}-ros-gz
    apt-get -y install python${python_ver}-venv
    apt-get -y remove ${remove_pkg}
    apt-get install -y libgl1-mesa-dri libglx-mesa0
    apt-get install -y libvulkan1 vulkan-tools
    apt-get install -y mesa-vulkan-drivers
    apt-get install -y ros-${ros_distro_lower}-ackermann-msgs
 
    cp /local/data/<username>/ros_gz_bridge.py /opt/ros/${ROS_DISTRO}/lib/python${python_ver}/site-packages/ros_gz_bridge/actions/ros_gz_bridge.py
 
 
    curl https://packages.osrfoundation.org/gazebo.gpg --output /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
    echo "deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable \$(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
    apt-get -y update
    apt-get -y install gz-${gz_ver}
 
    apt-get install -y python3-colcon-common-extensions
    apt-get install -y python3-rosdep
    rosdep update

$( [[ "$INSTALL_ZED" == "yes" ]] && echo "
    # Bringup setup
    ## Install Zed 2i packages
 
    ### Cuda 12.8
    dpkg -i /local/data/<username>/cuda-keyring_1.1-1_all.deb
    apt-get -y update
    apt-get -y install cuda-toolkit-12-8
    ### 1. ZDK Install
    apt-get install -y zstd
    apt-get install -y libjpeg-turbo8-dev libturbojpeg

    cd /local/data/<username>
    chmod +x ${zed_file}
    ./${zed_file} --silent

### 2. Install VLP-16
    apt-get install -y ros-${ros_distro_lower}-velodyne
 
    ## Build the zed_ros2_wrapper colcon packages
    cd /local/data/<username>/colcon_ws/src  # THIS MUST BE PRESENT BEFOREHAND
    cd ..
    rosdep update
    rosdep install --from-path src --ignore-src -r -y # install dependencies" )

%environment
    # Inherit and ensure base environment is sourced
    export GZ_SIM_RESOURCE_PATH=/uolstore/home/users/\$USER/colcon_ws/install/simulation/share/
    source /opt/ros/${ROS_DISTRO}/setup.bash
$( [[ "$INSTALL_ZED" == "yes" ]] && echo "
   
    # CUDA paths (if needed for your additions)
    export PATH=/usr/local/cuda-12.8/bin\${PATH:+:\${PATH}}
    export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}" )
%runscript
    # Optional: Customize the default runscript if needed

%labels
   Prabodh Gyawali
EOF

# Replace placeholders in def file
sed -i "s|<username>|${USER}|g" "ros_${ros_distro_lower}.def"

# Download ros_gz_bridge.py
echo "Downloading ros_gz_bridge.py..."
wget -O ros_gz_bridge.py "https://raw.githubusercontent.com/gazebosim/ros_gz/0abd2b217d92ae7f65c1fa9f2a6464072217a038/ros_gz_bridge/ros_gz_bridge/actions/ros_gz_bridge.py"

# Download CUDA keyring if ZED is enabled
if [[ "$INSTALL_ZED" == "yes" ]]; then
    echo "Downloading CUDA keyring..."
    wget -O cuda-keyring_1.1-1_all.deb "${cuda_keyring_url}"
    # Download ZED SDK if enabled
    echo "Downloading ZED SDK from official Stereolabs URL (this may take 10-30 minutes for ~2.4GB)..."
    wget --continue -O "${zed_file}" "${zed_url}"
fi

# zed_ros2_wrapper setup if ZED is enabled
if [[ "$INSTALL_ZED" == "yes" ]]; then
    echo "Setting up colcon workspace and cloning zed_ros2_wrapper..."
    mkdir -p colcon_ws/src
    cd colcon_ws/src
    git clone https://github.com/stereolabs/zed-ros2-wrapper.git
    cd "$SETUP_DIR"
fi

echo "Setup complete! Files are ready in $SETUP_DIR/"
apptainer build --nv "ros_${ros_distro_lower}.sif" "ros_${ros_distro_lower}.def"

# Create custom.def based on the built image
cat > "custom.def" << EOF
Bootstrap: localimage
From: $SETUP_DIR/ros_${ros_distro_lower}.sif
%post
    # User-customizable post section
    # Add your custom installations, package builds, or commands here.
%environment
    # Inherit and ensure base environment is sourced
    export GZ_SIM_RESOURCE_PATH=/uolstore/home/users/$USER/colcon_ws/install/simulation/share/
    source /opt/ros/${ROS_DISTRO}/setup.bash
$( [[ "$INSTALL_ZED" == "yes" ]] && echo "
    # CUDA paths (if needed for your additions)
    export PATH=/usr/local/cuda-12.8/bin\${PATH:+:\${PATH}}
    export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64\${LD_LIBRARY_PATH:+:\${LD_LIBRARY_PATH}}" )
%runscript
    # Optional: Customize the default runscript if needed
EOF

# Cleanup to not waste disk space
rm -f "$SETUP_DIR/ros_gz_bridge.py"
if [[ "$INSTALL_ZED" == "yes" ]]; then
    rm -f "$SETUP_DIR/cuda-keyring_1.1-1_all.deb" "$SETUP_DIR/${zed_file}"
fi