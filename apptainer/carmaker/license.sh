echo "Checking for Carmaker license file..."
if [ ! -f "./Licenses.dat" ]; then
    echo "Carmaker license file (Licenses.dat) not found."
    echo "Please place the Licenses.dat file in the current directory."
    exit 1
fi

echo "Checking Carmaker installation..."
if [ ! -d "/opt/ipg" ]; then
    echo "Carmaker installation not found in /opt/ipg."
    echo "Please install Carmaker first using the carmaker-14.0-install.sh script."
    exit 1
fi

echo "Copying license file to /ipg/home/etc"
cp Licenses.dat Licenses 
mv Licenses /opt/ipg/etc/ 