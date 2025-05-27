#!/usr/bin/env bash

set -e

# Ensure dialog is installed
if ! command -v dialog &>/dev/null; then
    echo "dialog package is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y dialog
fi

TITLE="Quick Setup for Ubuntu"
# Create aliases file
cat > ~/.aliases <<'EOF'
############ basic shortcuts ############
alias rm='rm -i'
alias upgrade='sudo apt update && sudo apt upgrade && flatpak update'
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

########### modded cp and mv ############
alias copy='copy -gr'
alias move='move -g'

############## colored cat ##############
alias cat='ccat'
alias less='cless'

############# lsd shortcuts #############
alias lc='lsd'
alias l='lsd --group-dirs first'
alias la='lsd -A --group-dirs first'
alias ll='lsd -lA --group-dirs first'
alias lt='lsd --group-dirs first --depth 3 --tree'
alias lta='lsd -A --tree --depth 3 --group-dirs first'

############ cd+ls together #############
cdls() {cd "$@" && ls; }

########### cd+lsd together #############
cdl() {cd "$@" && lsd --group-dirs first; }
cdla() {cd "$@" && lsd -A --group-dirs first; }
cdll() {cd "$@" && lsd -lA --group-dirs first; }

########## speedtest shortcuts ##########
alias speedtest='speedtest -A'
alias pingtest='ping -c 20 -i .2 8.8.8.8'

############ stats check ################
alias batterycheck='upower -i $(upower -e | grep "BAT")' 

######## yt-dlp shortcuts (youtube-dl replaced) ########
alias dlmp3='yt-dlp -c -R 10 -x --audio-format mp3 --prefer-ffmpeg -o "%(title)s.%(ext)s"'
alias dlmp4='yt-dlp -c -R 10 -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" -o "%(title)s.%(ext)s"'
alias dlplist='yt-dlp -c -R 10 -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --yes-playlist --playlist-start 1 -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s"'
alias ytdl='yt-dlp'
EOF

# Ensure ~/.aliases is always sourced in .bashrc and .zshrc
for file in ~/.bashrc ~/.zshrc; do
    if ! grep -q 'source ~/.aliases' "$file" 2>/dev/null; then
        echo 'source ~/.aliases' >> "$file"
    fi
done

main_menu() {
    while true; do
        cmd=(dialog --clear --title "$TITLE" --menu "Choose an option:" 17 60 6)
        options=(
            1 "Shell & Desktop Environment"
            2 "Essential Packages"
            3 "Optional Software"
            4 "Exit"
        )
        choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty) || break
        clear
        case $choice in
            1) shell_env_menu ;;
            2) essential_packages_menu ;;
            3) optional_software_menu ;;
            4) break ;;
        esac
    done
}

shell_env_menu() {
    cmd=(dialog --separate-output --checklist "Shell & Desktop Environment:\n(Select items to run)" 20 70 10)
    options=(
        1 "Fix system clock for dual boot" off
        2 "Install Oh My Zsh & plugins" off
        3 "Apply swappiness tweak" off
        4 "Limit journal entries" off
        5 "Colored ls: lsd" off
        6 "Screensaver (xscreensaver)" off
        7 "Kvantum (KDE theming)" off
        8 "Ulauncher (app launcher)" off
        9 "Back" off
    )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear
    for choice in $choices; do
        case $choice in
            1) fix_system_time ;;
            2) oh_my_zsh ;;
            3) swappiness ;;
            4) limit_journal ;;
            5) colored_ls ;;
            6) xscreensaver ;;
            7) kvantum ;;
            8) ulauncher ;;
            9) return ;;
        esac
    done
}

essential_packages_menu() {
    cmd=(dialog --separate-output --checklist "Essential Package Setup:\n(Select package groups or actions to install/perform)" 24 70 12)
    options=(
        1 "Basic desktop packages" off
        2 "Build essentials" off
        3 "Python & pipx" off
        4 "Flatpak & Flathub (recommended)" on
        5 "Remove Snap from system" off
        6 "GTK tools" off
        7 "KDE tools" off
        8 "CLI tools" off
        9 "Fun commands" off
        10 "Back" off
    )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear
    for choice in $choices; do
        case $choice in
            1) install_flatpak ;;
            2) remove_snap ;;
            3) select_packages "basic" ;;
            4) select_packages "build" ;;
            5) select_packages "python" ;;
            6) select_packages "gtk" ;;
            7) select_packages "kde" ;;
            8) select_packages "cli" ;;
            9) select_packages "fun" ;;
            10) return ;;
        esac
    done
}

remove_snap() {
    dialog --title "Remove Snap" --yesno "This will remove Snapd and all snap packages from your system.\n\nAre you sure you want to proceed?" 10 60
    response=$?
    if [ $response -ne 0 ]; then
        dialog --msgbox "Snap removal cancelled." 6 40
        return
    fi

    dialog --infobox "Removing Snap and all snap packages..." 5 50
    # Remove all snap packages
    for snap in $(snap list | awk 'NR>1 {print $1}'); do
        sudo snap remove --purge "$snap"
    done
    # Remove snapd itself
    sudo systemctl stop snapd
    sudo apt-get purge -y snapd
    sudo apt-get autoremove -y
    # Remove leftover directories if present
    sudo rm -rf ~/snap /snap /var/snap /var/lib/snapd /var/cache/snapd

    dialog --msgbox "Snap and all snap packages have been removed from your system." 7 50
}

optional_software_menu() {
    cmd=(dialog --separate-output --checklist "Optional/Feature Software:\n(Select software to install)" 18 70 8)
    options=(
        1 "Telegram Desktop" off
        2 "yt-dlp (YouTube downloader)" off
        3 "speedtest-cli" off
        4 "SMPlayer" off
        5 "Back" off
    )
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear
    for choice in $choices; do
        case $choice in
            1) install_telegram ;;
            2) youtube_dl ;;
            3) speedtest_cli ;;
            4) smplayer ;;
            5) return ;;
        esac
    done
}

declare -A PKG_GROUPS
PKG_GROUPS["basic"]="ubuntu-restricted-extras ubuntu-restricted-addons fonts-powerline ttf-mscorefonts-installer fonts-firacode xdg-utils ntfs-3g grub-customizer adb fastboot scrcpy openvpn m17n-db ibus-avro goldendict gimp inkscape krita qbittorrent flameshot kazam obs-studio nomacs thunderbird birdtray numix-icon-theme-circle gnome-icon-theme lxappearance onboard vlc pinta"
PKG_GROUPS["build"]="build-essential dpkg-repack dkms cmake checkinstall"
PKG_GROUPS["python"]="python2 python3 pipx"
PKG_GROUPS["gtk"]="synaptic gparted catfish gnome-disk-utility gnome-keyring seahorse keepassxc libsecret-tools arc-theme"
PKG_GROUPS["kde"]="qapt-deb-installer yakuake xdg-desktop-portal-gtk xdg-desktop-portal-kde muon krfb redshift filelight latte-dock falkon okular ksysguard dolphin konsole"
PKG_GROUPS["cli"]="testdisk mc ffmpeg elinks screen byobu openssh-server openssh-client openssh-askpass htop btop inxi neofetch whois vnstat iftop dnstop bmon nmap bat fim mpv units imagemagick ghostscript mlocate ncdu fzf fd-find"
PKG_GROUPS["fun"]="figlet boxes cmatrix toilet sl cowsay lolcat fortune"

select_packages() {
    group="$1"
    pkgs=(${PKG_GROUPS[$group]})
    dialog_choices=()
    for pkg in "${pkgs[@]}"; do
        dialog_choices+=("$pkg" "$pkg" "off")
    done

    cmd=(dialog --separate-output --checklist "Select packages to install from the $group group:" 25 70 15)
    selected_pkgs=$("${cmd[@]}" "${dialog_choices[@]}" 2>&1 >/dev/tty)
    clear
    [ -z "$selected_pkgs" ] && return

    to_install=()
    for pkg in $selected_pkgs; do
        if ! dpkg -s "$pkg" &>/dev/null; then
            to_install+=("$pkg")
        fi
    done
    [ ${#to_install[@]} -eq 0 ] && return

    dialog --infobox "Installing: ${to_install[*]}" 5 50
    sudo apt-get update
    sudo apt-get install -y "${to_install[@]}"
    sleep 1
}

fix_system_time() {
    sudo timedatectl set-local-rtc 1 --adjust-system-clock
}
oh_my_zsh() {
    sudo apt install -y zsh git curl
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    sed -i "s/robbyrussell/powerlevel10k\/powerlevel10k/gi" ~/.zshrc
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    sed -i "/^plugins=/c\plugins=(sudo extract magic-enter dirhistory command-not-found fancy-ctrl-z zsh-interactive-cd nmap history safe-paste colored-man-pages colorize autoenv zsh-syntax-highlighting zsh-autosuggestions)" ~/.zshrc
    cat <<EOF >> ~/.zshrc
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#303030"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c70,)"
ZSH_AUTOSUGGEST_COMPLETION_IGNORE="apt pip pip3 pipx"
EOF
    echo -e "\nsource \$HOME/.aliases\n" | tee -a ~/.zshrc
    echo -e "\nexport PATH=\"\$HOME/bin:\$HOME/.local/bin:\$PATH\"" | tee -a ~/.zshrc
}
swappiness() {
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
}
limit_journal() {
    sudo journalctl --vacuum-time=31days
}
colored_ls() {
    sudo apt install -y lsd || {
        wget -c https://github.com/lsd-rs/lsd/releases/download/v1.1.5/lsd-musl_1.1.5_amd64.deb
        sudo apt install ./lsd-musl_1.1.5_amd64.deb
    }
}
xscreensaver() {
    sudo apt-get install -y xscreensaver xscreensaver-*
}
kvantum() {
    sudo add-apt-repository -y ppa:papirus/papirus
    sudo apt update
    sudo apt install -y qt5-style-kvantum qt5-style-kvantum-themes
}
ulauncher() {
    sudo add-apt-repository -y ppa:agornostal/ulauncher
    sudo apt update
    sudo apt install -y ulauncher
}
install_flatpak() {
    sudo add-apt-repository -y ppa:flatpak/stable
    sudo apt update
    sudo apt install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}
youtube_dl() {
    pipx install yt-dlp
}
install_telegram() {
    flatpak install -y org.telegram.desktop
}
speedtest_cli() {
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
    sudo apt-get install -y speedtest || pipx install speedtest-cli
}
smplayer() {
    flatpak install -y info.smplayer.SMPlayer
}

main_menu
