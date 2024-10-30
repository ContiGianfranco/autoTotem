# Update
sudo apt update
sudo apt upgrade

# Enable vnc
sudo raspi-config nonint do_vnc 0
sudo apt-get install matchbox-window-manager xautomation unclutter

# Get .kiosk file and make it runnable
wget "link a .kiosk"
chmod 755 ~/.kiosk

# Run .kiosk on init
echo "xinit /home/$USER/kiosk -- vt$(fgconsole)" >> ~/.bashrc

# Download and enable it as lighttpd as local server
sudo apt install lighttpd -y
sudo systemctl enable lighttpd
sudo systemctl start lighttpd

# Create script directories
sudo mkdir /home/scripts
sudo chown $USER:$USER /home/scripts
sudo mkdir /home/scripts/envs
sudo mkdir /home/scripts/envs/modbus

# Falta crear la base de datos y los scripts de python