#!/usr/bin/env bash

TITLE="Quick Setup for Ubuntu"
export DEBIAN_FRONTEND=noninteractive

if ! command -v dialog &>/dev/null; then
    echo "The 'dialog' utility is required but not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y dialog
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
    sed -i '/^plugins=/c\plugins=(sudo extract magic-enter dirhistory command-not-found fancy-ctrl-z history safe-paste colored-man-pages colorize zsh-completions fzf-tab fast-syntax-highlighting zsh-autosuggestions zsh-syntax-highlighting zsh-autopair zsh-autocomplete)' ~/.zshrc || true

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

system_tweaks_menu() {
    while true; do
        dialog --clear --title "System Tweaks" --cancel-label "Back" --menu "Select a tweak:" 14 60 6 \
            1 "Fix System clock for dual boot" \
            2 "Apply swappiness tweak" \
            3 "Limit journal entry" \
            2>menu.tmp
        status=$?
        choice=$(<menu.tmp)
        rm -f menu.tmp
        clear
        case $status in
            0)
                case "$choice" in
                    1) fix_clock_menu ;;
                    2) echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
                       dialog --msgbox "Swappiness set to 10.\n\nPress Enter to continue..." 9 30 ;;
                    3)
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

declare -A PKG_GROUPS=(
    [basic]="ubuntu-restricted-extras ubuntu-restricted-addons fonts-powerline ttf-mscorefonts-installer fonts-firacode xdg-utils ntfs-3g grub-customizer adb fastboot scrcpy openvpn m17n-db ibus-m17n"
    [cli]="testdisk mc upower ffmpeg elinks screen byobu openssh-server openssh-client htop btop inxi neofetch whois vnstat iftop dnstop bmon nmap bat fim units imagemagick ghostscript mlocate ncdu fzf"
    [fun]="supertuxkart supertux minetest figlet boxes cmatrix toilet sl cowsay lolcat fortune fortune-mod"
    [gnome]="network-manager-gnome gnome-keyring gnome-disk-utility seahorse"
    [kde]="qapt-deb-installer yakuake xdg-desktop-portal-gtk xdg-desktop-portal-kde muon krfb redshift filelight latte-dock falkon okular ksysguard dolphin konsole qt5-style-kvantum qt5-style-kvantum"
    [development]="build-essential dpkg-repack dkms cmake checkinstall"
)

package_installer_menu() {
    while true; do
        dialog --clear --title "Package Installer" --cancel-label "Back" --menu "Select a package group:" 20 60 8 \
            1 "Basic Desktop Utilities" \
            2 "CLI Utilities" \
            3 "Fun/Eyecandy tools" \
            4 "GNOME Packages" \
            5 "KDE Packages" \
            6 "Development Packages" \
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
                    6) install_package_group "development" ;;
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
        dialog --clear --title "Optional Software Management" --cancel-label "Back" --menu "Select an option:" 20 70 8 \
            1 "Setup Flatpak" \
            2 "Install pipx" \
            3 "Remove snap" \
            4 "Firefox no-snap patch" \
            5 "Restore GNOME Software" \
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
                    4) firefox_no_snap_patch ;;
                    5) restore_gnome_software ;;
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
        # Prevent snapd from being reinstalled
        sudo tee /etc/apt/preferences.d/nosnap >/dev/null <<EOF
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
        dialog --msgbox "Snap and all snap packages removed, and snap is now blocked from being reinstalled by apt.\n\nPress Enter to continue..." 10 60
    fi
}

firefox_no_snap_patch() {
    dialog --yesno "This will remove all Snap and Ubuntu repo versions of Firefox, block their reinstallation, add the Mozilla Team PPA, and install the latest DEB version of Firefox with proper updates. Continue?" 8 70
    if [ $? -ne 0 ]; then
        dialog --msgbox "Firefox no-snap patch aborted." 7 40
        return
    fi

    # Remove existing Firefox and block Ubuntu repo version (including snap transitional package)
    sudo apt purge -y firefox

    sudo tee /etc/apt/preferences.d/firefox-no-snap >/dev/null <<EOF
Package: firefox*
Pin: release o=Ubuntu*
Pin-Priority: -1
EOF

    # Add Mozilla Team PPA and update
    sudo add-apt-repository -y ppa:mozillateam/ppa
    sudo apt update

    # Install Firefox from PPA
    sudo apt install -y -t 'o=LP-PPA-mozillateam' firefox

    # Enable auto-updates for PPA Firefox
    distro_codename=$(lsb_release -sc)
    echo "Unattended-Upgrade::Allowed-Origins:: \"LP-PPA-mozillateam:\${distro_codename}\";" | \
        sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox >/dev/null

    # Set PPA as highest priority for Firefox
    sudo tee /etc/apt/preferences.d/mozillafirefoxppa >/dev/null <<EOF
Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 501
EOF

    dialog --msgbox "Firefox no-snap patch applied:\n- Ubuntu repo and Snap Firefox blocked\n- Mozilla PPA enabled and prioritized\n- Latest Firefox DEB installed and set for auto-updates.\n\nYou may need to re-login for all changes to take effect." 12 70
}

restore_gnome_software() {
    sudo apt install --install-suggests gnome-software
    dialog --msgbox "GNOME Software Center has been installed or restored. You can now use it for graphical package management.\n\nPress Enter to continue..." 10 60
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
