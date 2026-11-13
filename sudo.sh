#
pacman -S sudo
#
usermod -aG wheel your_username
#
EDITOR=nano visudo
#
## REMOVE THE # FROM THE LINE # %wheel ALL=(ALL:ALL) ALL
#
# THEN CHECK WITH 
su - your_username
#
sudo whoami
