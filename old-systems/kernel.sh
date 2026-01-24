sudo apt install linux-generic
#spamming message for warnings
#sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 ubsan=0 /' /etc/default/grub
sudo update-grub
#sudo reboot
