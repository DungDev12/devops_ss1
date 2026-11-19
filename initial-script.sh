sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y openjdk-17-jdk git curl

if ! getent group quickbite > /dev/null; then
    sudo groupadd quickbite
    echo "Da tao group quickbite"
else
    echo "Group quickbite da ton tai"
fi

if ! id quickbite > /dev/null 2>&1; then
    sudo useradd -r -M -g quickbite -s /bin/false quickbite
    echo "Da tao user quickbite"
else
    echo "User quickbite da ton tai"
fi