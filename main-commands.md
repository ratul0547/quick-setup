
### changing swappiness
```zsh
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
```
  
  
### limit journal entry
```zsh
sudo journalctl --vacuum-time=31days
```

  
  
### advanced cp and mv
source: https://github.com/jarun/advcpmv 

###### building
```zsh
wget http://ftp.gnu.org/gnu/coreutils/coreutils-8.32.tar.xz

tar xvJf coreutils-8.32.tar.xz && cd coreutils-8.32/

wget https://raw.githubusercontent.com/jarun/advcpmv/master/advcpmv-0.8-8.32.patch

patch -p1 -i advcpmv-0.8-8.32.patch

./configure

make
```
  
  
###### putting files to $PATH
```zsh
sudo cp ./src/cp /usr/local/bin/copy && sudo cp ./src/mv /usr/local/bin/move
```
  
  
###### set alias
```zsh
echo -e "\n### Advanced cp and mv\nalias copy='copy -gR'\nalias move='move -g'" | tee -a .aliases
```

  
  
### fix-system-time
_If faced time change problem when dual booting with windows_ 
```zsh
timedatectl set-local-rtc 1 --adjust-system-clock
```
###### revert
```zsh
timedatectl set-local-rtc 0 --adjust-system-clock
```

  
  
### bd-mirrors

###### ubuntu
```zsh
export CODENAME=$(lsb_release -c | cut -f2)
echo -e "deb http://mirror.xeonbd.com/ubuntu-archive/ $CODENAME main restricted universe multiverse \ndeb http://mirror.xeonbd.com/ubuntu-archive/ $CODENAME-updates main restricted universe multiverse \ndeb http://mirror.xeonbd.com/ubuntu-archive/ $CODENAME-backports main restricted universe multiverse \ndeb http://mirror.xeonbd.com/ubuntu-archive/ $CODENAME-security main restricted universe multiverse" | sudo tee /etc/apt/sources.list.d/bd_mirrors.list
```
###### update apt database:
`sudo apt update && sudo apt upgrade`

  
  
### package-installation

`sudo apt update && sudo apt upgrade -y`

###### basic apps:
```zsh
sudo apt-get install synaptic gparted ubuntu-restricted-extras git curl zsh fonts-powerline ttf-mscorefonts-installer catfish gnome-disk-utility ntfs-3g grub-customizer adb fastboot scrcpy openvpn m17n-db ibus-avro goldendict stacer flameshot gimp inkscape krita deluge kazam wine winetricks
```

###### build essentials:
```zsh
sudo apt-get install build-essential dpkg-repack dkms make cmake checkinstall python2 python3 python-pip python3-pip python-setuptools python3-setuptools python-wheel-common
```
###### kde apps:
```zsh
sudo apt-get install qapt-deb-installer muon filelight latte-dock yakuake xdg-desktop-portal-gtk xdg-desktop-portal-kde krfb redshift
```
###### cli_tools:
```zsh
sudo apt-get install mc htop inxi neofetch whois ffmpeg vnstat iftop tasksel vsftpd elinks rtorrent fim aptitude cmus bat screen byobu
```
###### fun_commands:
```zsh
sudo apt-get install figlet boxes cmatrix toilet fortune-mod fortunes fortune-min fortune-off xscreensaver xscreensaver-data-extra xscreensaver-gl xscreensaver-gl-extra sl cowsay lolcat
```
  
  
### apt-fast

_if add-apt-repository is unavailable:_
`sudo apt-get install software-properties-common`

###### install:
```zsh
sudo add-apt-repository ppa:apt-fast/stable
sudo apt-get update
sudo apt-get -y install apt-fast
```
###### or, quick install:
```zsh
/bin/bash -c "$(curl -sL https://git.io/vokNn)"
```
  
  
### oh-my-zsh

###### packages needed:
`zsh curl git`

###### installing oh-my-zsh
```zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

###### installing p10k theme
```zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```
###### set theme
```zsh
sed -i "s/robbyrussell/powerlevel10k\/powerlevel10k/gi" .zshrc
```
###### installing zsh-syntax-highlighting
```zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```
###### installing zsh-autosuggestions
```zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```
###### autosuggestions-config
```zsh
echo -e "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#303030" \nZSH_AUTOSUGGEST_STRATEGY=(history completion) \nZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20" >> .zshrc
```
###### alias file 
_create a_ `~/.aliases` _file first if not created already_
```zsh
echo -e "\nsource \$HOME/.aliases\n" | tee -a ~/.zshrc
```
###### adding new dir to $PATH
```zsh
echo -e "\nexport PATH=\"\$HOME/.local/bin:\$PATH\"" | tee -a ~/.zshrc
```
  
  
### colorls
```zsh
sudo apt install -y ruby-dev
sudo gem install colorls
```

