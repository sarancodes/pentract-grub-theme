#!/bin/bash
ROOT_UID=0
THEME_DIR="/usr/share/grub/themes"
THEME_NAME="pentract"
MAX_DELAY=20


#colors

CDEF=" \033[0m"                                     # default color
CCIN=" \033[0;36m"                                  # info color
CGSC=" \033[0;32m"                                  # success color
CRER=" \033[0;31m"                                  # error color
CWAR=" \033[0;33m"                                  # warning color
b_CDEF=" \033[1;37m"                                # bold default color
b_CCIN=" \033[1;36m"                                # bold info color
b_CGSC=" \033[1;32m"                                # bold success color
b_CRER=" \033[1;31m"                                # bold error color
b_CWAR=" \033[1;33m"  



# echo like ...  with  flag type  and display message  colors
prompt () {
  case ${1} in
    "-s"|"--success")
      echo -e "${b_CGSC}${@/-s/}${CDEF}";;          # print success message
    "-e"|"--error")
      echo -e "${b_CRER}${@/-e/}${CDEF}";;          # print error message
    "-w"|"--warning")
      echo -e "${b_CWAR}${@/-w/}${CDEF}";;          # print warning message
    "-i"|"--info")
      echo -e "${b_CCIN}${@/-i/}${CDEF}";;          # print info message
    *)
    echo -e "$@"
    ;;
  esac
}

# Welcome message
  prompt -s "\n\t          ****************************\n\t          *  Pentract Bootloader theme  *\n\t          ****************************\n"
prompt -s "\t\t    Grub theme by sarancodes \n \n"   


 

# checking command availability
function has_command() {
  command -v $1 > /dev/null
}


prompt -i "Press enter to begin installation${CDEF}(automatically onstall after 10s) ${b_CWAR}:${CDEF}"
read -t10  

#checking for root access
prompt -w "\nChecking for root access...\n"
if [ "$UID" -eq "$ROOT_UID" ]; then
  # Create themes directory if not exists
  prompt -i "\nChecking for the existence of themes directory...\n"
  [[ -d ${THEME_DIR}/${THEME_NAME} ]] && rm -rf ${THEME_DIR}/${THEME_NAME}
  mkdir -p "${THEME_DIR}/${THEME_NAME}" 



  #copy theme
  prompt -i "\nInstalling ${THEME_NAME} theme...\n"
  cp -a ${THEME_NAME}/* ${THEME_DIR}/${THEME_NAME}/
  
  
  
  
  
    #adding username to grub bootloader
  prompt -w "Do you wanna display your name on a bootloader"
  read -p "[y/n]: " un
  if [[ "$un" == "y" || "$un" == "Y" ]]; then
    read -p "enter your Name [max 24 character] : " username

    if [ ${#username} -gt 24 ]
      then

        username=$(echo $username | cut -c1-24)

     fi
     prompt -i "\n Setting your username .......\n ."

     # Use a sed delimiter unlikely to appear in a name to avoid breakage
     sed -i "s|Hello Saran|Hello ${username}|g"  $THEME_DIR/$THEME_NAME/theme.txt
  fi
  
  
  #set theme
  prompt -i "\nSetting ${THEME_NAME} as default...\n"

  # Backup grub config
  cp -an /etc/default/grub /etc/default/grub.bak

  # Helper: replace KEY=... if present (commented or not), otherwise append.
  set_grub_var() {
    local key="$1" value="$2"
    if grep -Eq "^[#[:space:]]*${key}=" /etc/default/grub; then
      sed -i -E "s|^[#[:space:]]*${key}=.*|${key}=${value}|" /etc/default/grub
    else
      echo "${key}=${value}" >> /etc/default/grub
    fi
  }

  grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_THEME=/d' /etc/default/grub
  echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> /etc/default/grub

  # Newer Ubuntu (25.10 / 26.04) hides the menu by default, which suppresses
  # the theme entirely. Force a visible, graphical menu.
  set_grub_var "GRUB_TIMEOUT_STYLE" "menu"
  current_timeout=$(grep -E '^GRUB_TIMEOUT=' /etc/default/grub | tail -n1 | cut -d= -f2 | tr -d '"')
  if [ -z "$current_timeout" ] || [ "$current_timeout" = "0" ]; then
    set_grub_var "GRUB_TIMEOUT" "10"
  fi

  # GRUB requires a graphical terminal to render themes; setting "console"
  # disables theming. Force gfxterm explicitly (just commenting "console" is
  # not enough — the variable must be set to gfxterm).
  set_grub_var "GRUB_TERMINAL_OUTPUT" "gfxterm"
  # GRUB_TERMINAL (if set) overrides GRUB_TERMINAL_OUTPUT. Comment it out so
  # our gfxterm setting wins.
  sed -i -E 's|^[[:space:]]*GRUB_TERMINAL=.*|#&|' /etc/default/grub

  # Ensure a graphical mode is selected so the theme can render.
  if ! grep -Eq '^GRUB_GFXMODE=' /etc/default/grub; then
    echo 'GRUB_GFXMODE=auto' >> /etc/default/grub
  fi
  if ! grep -Eq '^GRUB_GFXPAYLOAD_LINUX=' /etc/default/grub; then
    echo 'GRUB_GFXPAYLOAD_LINUX=keep' >> /etc/default/grub
  fi

  # On Ubuntu 25.04+, scripts in /etc/default/grub.d/ are sourced AFTER
  # /etc/default/grub and can silently override GRUB_THEME (this is the
  # "theme ignored / not written to grub.cfg" symptom users hit on 25.10
  # and 26.04). Drop in a file that sorts last so our values win.
  if [ -d /etc/default/grub.d ]; then
    cat > /etc/default/grub.d/zzz-${THEME_NAME}.cfg <<EOF
# Written by ${THEME_NAME} install.sh — overrides earlier drop-ins.
GRUB_THEME="${THEME_DIR}/${THEME_NAME}/theme.txt"
GRUB_TERMINAL_OUTPUT="gfxterm"
GRUB_TIMEOUT_STYLE="menu"
EOF
    chmod 0644 /etc/default/grub.d/zzz-${THEME_NAME}.cfg
  fi




  


  prompt -i "\n finalizing your installation .......\n \n."
  # Update grub config
  echo -e "Updating grub config..."
  GENERATED_CFG=""
  if has_command update-grub; then
    update-grub
    GENERATED_CFG="/boot/grub/grub.cfg"
  elif has_command grub-mkconfig; then
    if [ -d /boot/efi/EFI/ubuntu ]; then
      GENERATED_CFG="/boot/efi/EFI/ubuntu/grub.cfg"
    elif [ -d /boot/efi/EFI/debian ]; then
      GENERATED_CFG="/boot/efi/EFI/debian/grub.cfg"
    else
      GENERATED_CFG="/boot/grub/grub.cfg"
    fi
    grub-mkconfig -o "$GENERATED_CFG"
  elif has_command grub2-mkconfig; then
    if has_command zypper; then
      GENERATED_CFG="/boot/grub2/grub.cfg"
    elif has_command dnf; then
      GENERATED_CFG="/boot/efi/EFI/fedora/grub.cfg"
    fi
    [ -n "$GENERATED_CFG" ] && grub2-mkconfig -o "$GENERATED_CFG"
  fi

  # Verify the theme actually landed in grub.cfg. On Ubuntu 25.04+ a buggy
  # grub-mkconfig and/or drop-in overrides can silently strip GRUB_THEME.
  if [ -n "$GENERATED_CFG" ] && [ -f "$GENERATED_CFG" ]; then
    if ! grep -Eq '^[[:space:]]*set[[:space:]]+theme=' "$GENERATED_CFG"; then
      prompt -w "\nWARNING: ${GENERATED_CFG} contains no 'set theme=' line."
      prompt -w "  The theme files were copied to ${THEME_DIR}/${THEME_NAME}/"
      prompt -w "  but grub-mkconfig did not write the theme into grub.cfg."
      prompt -w "  This is a known issue on Ubuntu 25.04+. Try:"
      prompt -w "    1) Check for overrides: ls /etc/default/grub.d/"
      prompt -w "    2) Re-run: sudo update-grub"
      prompt -w "    3) If still missing, manually append to ${GENERATED_CFG}:"
      prompt -w "         set theme=${THEME_DIR}/${THEME_NAME}/theme.txt\n"
    fi
  fi

  # Success message
  prompt -s "\n\t          ****************************\n\t          *  successfully installed  *\n\t          ****************************\n"

  

else

  # Error message
  prompt -e "\n [ Error! ] -> Run me as root  \n \n "

fi









