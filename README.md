# Pentract GRUB Theme
### A custom theme for the grub bootloader with automatic installation and uninstall support.
# Installation
- Clone this repository
- Change the directory to the pentract theme folder 
- Execute the install.sh script as super user `sudo ./install.sh`
- The script will prompt you to enter your name if you want to display it or else leave it blank and press enter
- The theme will be then installed on your system
- To uninstall use `sudo ./uninstall.sh` command 
##### Note: This theme does not work with ZFS File system

#### Bootloader Menu
![Screenshot 1](https://github.com/sarancodes/pentract-grub-theme/blob/main/screenshot1.png)
#### Advanced Options Menu
![Screenshot 2](https://github.com/sarancodes/pentract-grub-theme/blob/main/screenshot2.png)
#### Below is an another variant of this theme
![Variant](https://github.com/sarancodes/pentract-grub-theme/blob/main/variant1.png)

### Bonus Tips
- To extract the tar file use `tar -xvf pentract.tar.xz`
- Or else use the `unzip filename` command to extract the zip file.
- To customize the font colors edit the color property in the  _**theme.txt**_  file
- In case of `permission denied` right click and change the property of install.sh file to enable and run as program option.
- Then re-run the install.sh script
- Press `C` in the grub bootloader screen and type `vbeinfo` to know the supported resolutions of the system.
### Modify grub bootloader screen resolution 
- First type `sudo nano /etc/default/grub` in the terminal
- Find the line `#GRUB_GFXMODE=640x480` which is the default resolution
- Then remove the # and change the 640x480 with your preferred mode
- Example `GRUB_GFXMODE=1280x800`
- Save it by pressing `Ctrl+o` and exit `Ctrl+x`
- Then type `sudo update-grub`


