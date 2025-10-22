#!bin/bash

# FSAI_CM plugin install script for Ubuntu 24.04

echo "Checking Carmaker installation..."
if [ ! -d "/opt/ipg" ]; then
    echo "Carmaker installation not found in /opt/ipg."
    echo "Please install Carmaker first using the carmaker-14.0-install.sh script."
    exit 1
fi

echo "Checking for FSAI_CM plugin file..."
if [ ! -f "./FSAI_CM.zip" ]; then
    echo "FSAI_CM plugin file (FSAI_CM_Plugin_14.0.zip) not found."
    echo "Please place the FSAI_CM_Plugin_14.0.zip file in the current directory."
    exit 1
fi

echo "Unzipping FSAI_CM plugin files..."
unzip ./FSAI_CM.zip -d ./FSAI_CM
cd FSAI_CM

echo "Applying Changelog to CMakeLists.txt..."

# Files with wrong Carmaker version references
FILES=(
    "FSAI_CM/ros/ros2_ws/src/carmaker_rsds_client/CMakeLists.txt"
    "FSAI_CM/ros/ros2_ws/src/cmros_utils/CMakeLists.txt"
)

for file in "${FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Warning: File $file does not exist. Skipping."
        continue
    fi

    echo "Updating $file..."

    # Replace CARMAKER_VER from 12.0.1 to 14.0 (lines around 27-28)
    sed -i 's/set(CARMAKER_VER 12\.0\.1)/set(CARMAKER_VER 14.0)/' "$file"

    # Replace CARMAKER_DIR with version interpolation to fixed path (lines around 28 and 33)
    sed -i 's/set(CARMAKER_DIR \$ENV{IPGHOME}\/carmaker\/linux64-${CARMAKER_VER})/set(CARMAKER_DIR \$ENV{IPGHOME}\/carmaker\/linux64)/' "$file"
    sed -i 's/set(CARMAKER_DIR \$ENV{IPGHOME}\/carmaker\/linux64-${CARMAKER_VER})/set(CARMAKER_DIR \$ENV{IPGHOME}\/carmaker\/linux64)/' "$file"

    echo "Updated $file successfully."
done

echo "All updates completed."

ln -sfn /opt/ros/humble /opt/ros/ros2

chmod +x build.sh
./build.sh

echo "FSAI_CM plugin installation completed."
echo "You can now start Carmaker with FSAI_CM plugin support by running CMStart.sh from FSAI_CM directory."
cd ..