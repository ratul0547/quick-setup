#!/usr/bin/env bash

TITLE="Quick Setup for Debian"
export DEBIAN_FRONTEND=noninteractive

sudo_check() {
    if ! dpkg -s sudo &>/dev/null; then
        dialog --msgbox "sudo is not installed. Please install sudo first.\n\nPress Enter to continue..." 8 50
        return 1
    fi
    return 0
}

if ! command -v dialog &>/dev/null; then
    echo "The 'dialog' utility is required but not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y dialog
fi

if ! dpkg -s sudo &>/dev/null; then
    dialog --msgbox \
"Sudo is NOT installed on your system.

This script relies on sudo for most functions and will NOT work properly without it. 
It is not recommended to run this quick-setup program as root.

To install sudo, open a new terminal and switch to root by running:

    su -
    apt update
    apt install sudo

Then, add your user to the sudo group:

    usermod -aG sudo $USER

Log out and log in again for group changes to take effect.

You may continue, but most features will be unavailable until sudo is installed.
Press Enter to continue..." 20 70
fi

echo "Updating package lists, please wait..."
sudo apt-get update

pkg_available() {
    apt-cache show "$1" >/dev/null 2>&1
}
is_installed() {
    dpkg -s "$1" &>/dev/null
}

shell_config_menu() {
    while true; do
        dialog --clear --title "Shell Configuration" --cancel-label "Back" --menu "Select a task:" 14 60 5 \
            1 "ZSH shell installation" \
            2 "ZSH Themes/Plugins configuration" \
            3 "Configure aliases" \
            2>menu.tmp
        status=$?
        choice=$(<menu.tmp)
        rm -f menu.tmp
        clear
        case $status in
            0)
                case "$choice" in
                    1) zsh_install ;;
                    2) zsh_theme_plugins ;;
                    3) configure_aliases ;;
                esac
                ;;
            1|255) return ;;
        esac
    done
}

zsh_install() {
    sudo apt-get install -y zsh git curl
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        RUNZSH=yes KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    if [ -f "$HOME/.zshrc" ]; then
        sed -i 's/^# \(export PATH=\$HOME\/bin:\/usr\/local\/bin:\$PATH\)/\1/' "$HOME/.zshrc"
    fi
    dialog --msgbox "ZSH installation and base setup complete.\n\nPress Enter to continue..." 9 45
}

zsh_theme_plugins() {
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    fi
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc || true

    plugins=(
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-completions"
        "Aloxaf/fzf-tab"
        "zdharma-continuum/fast-syntax-highlighting"
        "marlonrichert/zsh-autocomplete"
        "hlissner/zsh-autopair"
    )
    for repo in "${plugins[@]}"; do
        name=${repo##*/}
        dest="$ZSH_CUSTOM/plugins/$name"
        if [ ! -d "$dest" ]; then
            git clone --depth=1 "https://github.com/$repo.git" "$dest"
        fi
    done
    sed -i '/^plugins=/c\plugins=(sudo extract magic-enter dirhistory command-not-found fancy-ctrl-z history safe-paste colored-man-pages colorize zsh-completions fzf-tab fast-syntax-highlighting zsh-autocomplete zsh-autopair zsh-autosuggestions)' ~/.zshrc || true

    dialog --msgbox "ZSH plugins and theme installed. Please restart your terminal.\n\nPress Enter to continue..." 9 60
}

configure_aliases() {
  cat > ~/.aliases <<'EOF'
############ basic shortcuts ############
alias rm='rm -i'
alias upgrade-all='sudo apt update && sudo apt upgrade && flatpak update'
alias apt='sudo apt'
alias apt-search='apt-cache search'
alias apt-show='apt show'
alias open='xdg-open'
alias c='clear'
alias gitclone='cd ~/.tmp && git clone'

alias mc='. /usr/share/mc/bin/mc-wrapper.sh'

alias gsudo='pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY'
alias gui='exec env DISPLAY=:0 XAUTHORITY=$XAUTHORITY'

alias delete='rm -rfv'
alias update-mlocate='echo -e "\nupdating database...\n" && sudo updatedb'
alias update-units='units_cur -b USD'
alias root='sudo -s'

############# lsd shortcuts #############
alias lc='lsd'
alias l='lsd --group-dirs first'
alias la='lsd -A --group-dirs first'
alias ll='lsd -lA --group-dirs first'
alias lt='lsd --group-dirs first --depth 3 --tree'
alias lta='lsd -A --tree --depth 3 --group-dirs first'

########## speedtest shortcuts ##########
alias speedtest='speedtest -A'
alias pingtest='ping -c 20 -i .2 8.8.8.8'

############ stats check ################
alias batterycheck='upower -i $(upower -e | grep "BAT")' 

######## yt-dlp shortcuts ########
alias dlmp3='yt-dlp -c -R 10 -x --audio-format mp3 --prefer-ffmpeg -o "%(title)s.%(ext)s"'
alias dlmp4='yt-dlp -c -R 10 -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" -o "%(title)s.%(ext)s"'
alias dlplist='yt-dlp -c -R 10 -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --yes-playlist --playlist-start 1 -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s"'
alias ytdl='yt-dlp'
EOF

for file in ~/.bashrc ~/.zshrc; do
    grep -q 'source ~/.aliases' "$file" 2>/dev/null || echo 'source ~/.aliases' >> "$file"
done
    dialog --msgbox "Aliases configured and sourced in bashrc/zshrc.\n\nPress Enter to continue..." 9 50
}

system_tweaks_menu() {
    while true; do
        dialog --clear --title "System Tweaks" --cancel-label "Back" --menu "Select a tweak:" 14 60 6 \
            1 "Configure sudo" \
            2 "Fix System clock for dual boot" \
            3 "Apply swappiness tweak" \
            4 "Limit journal entry" \
            2>menu.tmp
        status=$?
        choice=$(<menu.tmp)
        rm -f menu.tmp
        clear
        case $status in
            0)
                case "$choice" in
                    1) sudo_configure_menu ;;
                    2) fix_clock_menu ;;
                       dialog --msgbox "Clock fixed for dual boot.\n\nPress Enter to continue..." 9 40 ;;
                    3) echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
                       dialog --msgbox "Swappiness set to 10.\n\nPress Enter to continue..." 9 30 ;;
                    4)
                        dialog --inputbox "Enter days to keep journal entries:" 8 40 31 2>input.tmp
                        st=$?
                        days=$(<input.tmp)
                        rm -f input.tmp
                        clear
                        if [[ $st -eq 0 && "$days" =~ ^[0-9]+$ ]]; then
                            sudo journalctl --vacuum-time="${days}days"
                            dialog --msgbox "Journal limited to ${days}day(s).\n\nPress Enter to continue..." 9 40
                        else
                            dialog --msgbox "Invalid input.\n\nPress Enter to continue..." 8 30
                        fi
                        ;;
                esac
                ;;
            1|255) return ;;
        esac
    done
}
fix_clock_menu() {
    # Detect current RTC setting
    if timedatectl show | grep -q '^RTCInLocalTZ=yes'; then
        current="local"
    else
        current="utc"
    fi

    # Prepare menu options with asterisk for current
    opt1="UTC"
    opt2="Local"
    [ "$current" = "utc" ] && opt1="UTC *"
    [ "$current" = "local" ] && opt2="Local *"

    dialog --clear --title "Fix System clock for dual boot" --menu "Select RTC time mode:" 12 50 2 \
        1 "$opt1" \
        2 "$opt2" \
        2>menu.tmp
    status=$?
    choice=$(<menu.tmp)
    rm -f menu.tmp
    clear
    if [ "$status" -ne 0 ]; then return; fi

    case "$choice" in
        1)
            sudo timedatectl set-local-rtc 0 --adjust-system-clock
            dialog --msgbox "RTC is now set to UTC.\n\nPress Enter to continue..." 9 40
            ;;
        2)
            sudo timedatectl set-local-rtc 1 --adjust-system-clock
            dialog --msgbox "RTC is now set to Local Time.\n\nPress Enter to continue..." 9 40
            ;;
    esac
}
sudo_configure_menu() {
    while true; do
        dialog --clear --title "Configure sudo" --cancel-label "Back" --menu "Select sudo configuration option:" 14 60 6 \
            1 "Install sudo if missing" \
            2 "Add user to sudo group" \
            3 "Edit sudoers file (visudo)" \
            4 "List current sudo users" \
            2>menu.tmp
        status=$?
        choice=$(<menu.tmp)
        rm -f menu.tmp
        clear
        case $status in
            0)
                case "$choice" in
                    1)
                        if dpkg -s sudo &>/dev/null; then
                            dialog --msgbox "sudo is already installed.\n\nPress Enter to continue..." 8 40
                        else
                            dialog --msgbox \
"sudo is NOT installed.

You cannot use sudo commands until it is available.

To install sudo without sudo, open a new terminal and run the following as root:

    su -
    apt update
    apt install sudo

Then, add your user to the sudo group:

    usermod -aG sudo yourusername

Log out and log in again for group changes to take effect.

Press Enter to continue..." 15 60
                        fi
                        ;;
                    2)
                        if ! sudo_check; then
                            break
                        fi
                        dialog --inputbox "Enter username to add to sudo group:" 8 40 "$USER" 2>input.tmp
                        st=$?
                        user=$(<input.tmp)
                        rm -f input.tmp
                        clear
                        if [[ $st -eq 0 && -n "$user" && $(id -u "$user" 2>/dev/null) ]]; then
                            sudo usermod -aG sudo "$user"
                            dialog --msgbox "User $user added to sudo group.\n\nPress Enter to continue..." 8 40
                        else
                            dialog --msgbox "User $user does not exist.\n\nPress Enter to continue..." 8 40
                        fi
                        ;;
                    3)
                        if ! sudo_check; then
                            break
                        fi
                        # Check if backup already exists
                        if [ -e /etc/sudoers.bak ]; then
                            dialog --msgbox "A backup of /etc/sudoers already exists at /etc/sudoers.bak. No new backup will be created.\n\nOpening sudoers file with visudo..\nBe cautious while editing sudoers file. Make your changes and save.\n\nPress Enter to continue..." 14 60
                        else
                            sudo cp /etc/sudoers /etc/sudoers.bak
                            dialog --msgbox "A backup of /etc/sudoers has been created at /etc/sudoers.bak.\n\nOpening sudoers file with visudo..\nBe cautious while editing sudoers file. Make your changes and save.\n\nPress Enter to continue..." 14 60
                        fi
                        sudo visudo
                        ;;
                    4)
                        if ! sudo_check; then
                            break
                        fi
                        users=$(getent group sudo | cut -d: -f4 | tr ',' '\n')
                        dialog --msgbox "Users in sudo group:\n\n$users\n\nPress Enter to continue..." 14 50
                        ;;
                esac
                ;;
            1|255) return ;;
        esac
    done
}

declare -A PKG_GROUPS=(
    [basic]="fonts-powerline fonts-firacode xdg-utils ntfs-3g libreoffice grub-customizer openvpn goldendict gimp inkscape krita qbittorrent flameshot kazam obs-studio nomacs thunderbird numix-icon-theme-circle lxappearance onboard vlc pinta synaptic apt-xapian-index gparted catfish keepassxc arc-theme xscreensaver lsd"
    [cli]="testdisk mc upower ffmpeg elinks screen byobu openssh-server openssh-client htop btop inxi neofetch whois vnstat iftop dnstop bmon nmap bat fim units imagemagick ghostscript mlocate ncdu fzf fd-find libsecret-tools"
    [fun]="supertuxkart supertux minetest figlet boxes cmatrix toilet sl cowsay lolcat fortune fortune-mod"
    [gnome]="network-manager-gnome gnome-keyring gnome-disk-utility seahorse"
    [kde]="yakuake xdg-desktop-portal-gtk xdg-desktop-portal-kde plasma-nm muon krfb redshift filelight latte-dock falkon okular ksysguard dolphin konsole qt5-style-kvantum qt5-style-kvantum-themes"
    [firmware]="firmware-iwlwifi firmware-realtek firmware-linux firmware-linux-nonfree"
    [development]="build-essential dpkg-repack dkms cmake checkinstall adb fastboot scrcpy"
)

package_installer_menu() {
    while true; do
        dialog --clear --title "Package Installer" --cancel-label "Back" --menu "Select a package group:" 20 60 8 \
            1 "Basic Desktop Utilities" \
            2 "CLI Utilities" \
            3 "Fun/Eyecandy tools" \
            4 "GNOME Packages" \
            5 "KDE Packages" \
            6 "Hardware/Firmware Packages" \
            7 "Development Packages" \
            2>menu.tmp
        status=$?
        choice=$(<menu.tmp)
        rm -f menu.tmp
        clear
        case $status in
            0)
                case "$choice" in
                    1) install_package_group "basic" ;;
                    2) install_package_group "cli" ;;
                    3) install_package_group "fun" ;;
                    4) install_package_group "gnome" ;;
                    5) install_package_group "kde" ;;
                    6) install_package_group "firmware" ;;
                    7) install_package_group "development" ;;
                esac
                ;;
            1|255) return ;;
        esac
    done
}

install_package_group() {
    local group="$1"
    local pkgs=(${PKG_GROUPS[$group]})

    declare -A available_map
    for pkg in $(apt-cache show "${pkgs[@]}" 2>/dev/null | grep '^Package: ' | awk '{print $2}'); do
        available_map["$pkg"]=1
    done

    declare -A installed_map
    for pkg in "${pkgs[@]}"; do
        if dpkg -s "$pkg" &>/dev/null; then
            installed_map["$pkg"]=1
        else
            installed_map["$pkg"]=0
        fi
    done

    build_dialog_choices() {
        local state="$1"
        > "$tmp_choices"
        echo -e "SELECT_ALL mark_available_packages off" >> "$tmp_choices"
        echo -e "DESELECT_ALL clear_selection off" >> "$tmp_choices"
        for pkg in "${pkgs[@]}"; do
            if [[ -z "${available_map[$pkg]}" ]]; then
                echo "$pkg unavailable off" >> "$tmp_choices"
            elif [[ "${installed_map[$pkg]}" == "1" ]]; then
                echo "$pkg installed off" >> "$tmp_choices"
            else
                if [[ -n "$state" ]]; then
                    echo "$pkg not-installed $state" >> "$tmp_choices"
                else
                    echo "$pkg not-installed on" >> "$tmp_choices"
                fi
            fi
        done
    }

    tmp_choices=$(mktemp)
    build_dialog_choices

    while true; do
        mapfile -t choices < <(
            dialog --separate-output --ok-label "Install" --cancel-label "Back" --checklist \
                "Select packages to install (installed/unavailable are unchecked):\nUse 'SELECT_ALL'/'DESELECT_ALL' to toggle." \
                20 75 20 \
                $(cat "$tmp_choices") \
                2>&1 >/dev/tty
        )
        status=$?
        clear
        if [[ $status -ne 0 ]]; then rm -f "$tmp_choices"; return; fi

        if printf '%s\n' "${choices[@]}" | grep -q "^SELECT_ALL$"; then
            build_dialog_choices "on"
            continue
        elif printf '%s\n' "${choices[@]}" | grep -q "^DESELECT_ALL$"; then
            build_dialog_choices "off"
            continue
        fi

        clean_choices=()
        for pkg in "${choices[@]}"; do
            [[ "$pkg" == "SELECT_ALL" || "$pkg" == "DESELECT_ALL" ]] && continue
            if [[ "${available_map[$pkg]}" == "1" && "${installed_map[$pkg]}" == "0" ]]; then
                clean_choices+=("$pkg")
            fi
        done

        to_install=("${clean_choices[@]}")
        not_installed=()
        if (( ${#to_install[@]} )); then
            sudo apt-get install -y "${to_install[@]}"
            for pkg in "${to_install[@]}"; do
                if ! dpkg -s "$pkg" &>/dev/null; then
                    not_installed+=("$pkg")
                fi
            done
        fi

        msg=""
        if (( ${#to_install[@]} )); then
            installed=()
            for pkg in "${to_install[@]}"; do
                if dpkg -s "$pkg" &>/dev/null; then
                    installed+=("$pkg")
                fi
            done
            if (( ${#installed[@]} )); then
                msg+="Successfully installed:\n$(printf '%s\n' "${installed[@]}")\n\n"
            fi
        fi
        if (( ${#not_installed[@]} )); then
            msg+="Failed to install:\n$(printf '%s\n' "${not_installed[@]}")\n\n"
        fi
        [[ -z "$msg" ]] && msg="Nothing was installed."
        dialog --msgbox "$msg" 14 70
        break
    done
    rm -f "$tmp_choices"
}

optional_software_mgmt_menu() {
    while true; do
        dialog --clear --title "Optional Software Management" --cancel-label "Back" --menu "Select an option:" 14 70 6 \
            1 "Setup Flatpak" \
            2 "Install pipx" \
            3 "Remove snap" \
            2>menu.tmp
        status=$?
        choice=$(<menu.tmp)
        rm -f menu.tmp
        clear
        case $status in
            0)
                case "$choice" in
                    1) flatpak_menu ;;
                    2) install_pipx ;;
                    3) remove_snap ;;
                esac
                ;;
            1|255) return ;;
        esac
    done
}

flatpak_menu() {
    while true; do
        dialog --clear --title "Flatpak Setup" --cancel-label "Back" --menu "Select Flatpak option:" 14 60 4 \
            1 "Flatpak and Flatpak-repo only" \
            2 "Gnome Backend" \
            3 "Plasma Backend" \
            2>menu.tmp
        status=$?
        choice=$(<menu.tmp)
        rm -f menu.tmp
        clear
        case $status in
            0)
                case "$choice" in
                    1)
                        sudo apt-get install -y flatpak
                        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                        dialog --msgbox "Flatpak and flathub repo setup complete.\n\nPress Enter to continue..." 9 50
                        ;;
                    2)
                        sudo apt-get install -y gnome-software-plugin-flatpak
                        dialog --msgbox "Gnome Flatpak backend installed.\n\nPress Enter to continue..." 9 50
                        ;;
                    3)
                        sudo apt-get install -y plasma-discover-backend-flatpak
                        dialog --msgbox "Plasma Flatpak backend installed.\n\nPress Enter to continue..." 9 50
                        ;;
                esac
                ;;
            1|255) return ;;
        esac
    done
}

install_pipx() {
    if ! command -v pipx &>/dev/null; then
        sudo apt-get install -y pipx
    fi
    dialog --msgbox "pipx is installed.\n\nPress Enter to continue..." 8 30
}

remove_snap() {
    if ! command -v snap &>/dev/null && ! dpkg -s snapd &>/dev/null; then
        dialog --msgbox "Snap is not installed.\n\nPress Enter to continue..." 8 30
        return
    fi
    dialog --yesno "Snap is installed. Remove snap and all snap packages?" 8 60
    if [ $? -eq 0 ]; then
        if command -v snap &>/dev/null; then
            for snap in $(snap list | awk 'NR>1 {print $1}'); do
                sudo snap remove --purge "$snap"
            done
        fi
        sudo systemctl stop snapd 2>/dev/null || true
        sudo apt-get purge -y snapd
        sudo apt-get autoremove -y
        sudo rm -rf ~/snap /snap /var/snap /var/lib/snapd /var/cache/snapd
        dialog --msgbox "Snap and all snap packages removed.\n\nPress Enter to continue..." 9 50
    fi
}

while true; do
    dialog --clear --title "$TITLE" --cancel-label "EXIT" --menu "Choose a section:" 14 60 6 \
        1 "Shell configuration" \
        2 "System Tweaks" \
        3 "Package installer" \
        4 "Optional Software Management" \
        2>menu.tmp
    status=$?
    choice=$(<menu.tmp)
    rm -f menu.tmp
    clear
    case $status in
        0)
            case $choice in
                1) shell_config_menu ;;
                2) system_tweaks_menu ;;
                3) package_installer_menu ;;
                4) optional_software_mgmt_menu ;;
            esac
            ;;
        1|255)
            exit 0
            ;;
    esac
done
