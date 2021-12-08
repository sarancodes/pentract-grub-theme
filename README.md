# Pentract GRUB Theme
### This is a custom theme for the grub bootloader.
![Screenshot 1](https://github.com/sarancodes/pentract-grub-theme/blob/main/screenshot1.png)
![Screenshot 2](https://github.com/sarancodes/pentract-grub-theme/blob/main/screenshot2.png)
![Variant](https://github.com/sarancodes/pentract-grub-theme/blob/main/variant1.png)
# Installation
- Clone this repository
- Change the directory to the pentract theme folder 
- Execute the install.sh script as super user `sudo ./install.sh`
- The script will prompt you to enter your name if you want to display it or else leave it blank and press enter
- The theme will be then installed on your system
- To uninstall use `sudo ./uninstall.sh` command 
##### Note: This theme does not work with ZFS File system
### Bonus Tips
- To extract the tar file use `tar -xvf pentract.tar.xz`
- To customize the font colors edit the color property in the  _**theme.txt**_  file
### Modify grub bootloader screen resolution 
- First type `sudo nano /etc/default/grub` in the terminal
- Find the line `#GRUB_GFXMODE=640x480` which is the default resolution
- Then remove the # and change the 640x480 with your preferred mode
- Example `GRUB_GFXMODE=1280x800`
- Save it by pressing `Ctrl+o` and exit `Ctrl+x`
- Then type `sudo update-grub`


