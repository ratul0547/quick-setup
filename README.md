
## **quick-setup** for newly installed linux desktop environment. (targeted for ubuntu and ubuntu based distros)

 `(created mainly for myself to save some time after installing a new linux distro, but keeping it public so that other people can help themselves too.)`

 
--------------------------------------------------------------------- 
Contents:  
* [Basics](#basics)
* [Tweaks](#tweaks) 
* [Packages](#packages)
* [Additional Packages](#additional-packages)
  
  
---------------------------------------------------------------------  
---------------------------------------------------------------------  
# BASICS  
  
  

## * fix-system-time:
###### If faced time change problem when dual booting with windows
```sh
timedatectl set-local-rtc 1 --adjust-system-clock
```
#### revert
```sh
timedatectl set-local-rtc 0 --adjust-system-clock
```


  
---------------------------------------------------------------------  
  
## * bd-mirrors:

#### ubuntu

_Paste all in terminal_:
```sh
export CODENAME=$(lsb_release -c | cut -f2) && \
echo -e "\
deb http://mirror.xeonbd.com/ubuntu-archive/ $CODENAME main restricted universe multiverse \n\
deb http://mirror.xeonbd.com/ubuntu-archive/ $CODENAME-updates main restricted universe multiverse \n\
deb http://mirror.xeonbd.com/ubuntu-archive/ $CODENAME-backports main restricted universe multiverse \n\
deb http://mirror.xeonbd.com/ubuntu-archive/ $CODENAME-security main restricted universe multiverse" \
| sudo tee /etc/apt/sources.list.d/bd-mirrors.list
```

```sh
sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
sudo touch /etc/apt/sources.list
```

#### update apt database:
`sudo apt update && sudo apt upgrade`

  
  
---------------------------------------------------------------------  

## * oh-my-zsh:
_(https://github.com/ohmyzsh/ohmyzsh)_


#### Installing dependencies

```sh
sudo apt install zsh curl git
```

#### installing oh-my-zsh

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### installing p10k theme 
_(https://github.com/romkatv/powerlevel10k)_

```sh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```
#### set theme
```sh
sed -i "s/robbyrussell/powerlevel10k\/powerlevel10k/gi" ~/.zshrc
```
#### installing zsh-syntax-highlighting
_(https://github.com/zsh-users/zsh-syntax-highlighting)_

```sh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```
#### installing zsh-autosuggestions
_(https://github.com/zsh-users/zsh-autosuggestions)_

```sh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```
#### autosuggestions-config
Put these lines at the end of `~/.zshrc`
```
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#303030"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c70,)"
ZSH_AUTOSUGGEST_COMPLETION_IGNORE="apt pip pip3"
```

#### adding plugins
```sh
sed -i "s/plugins=(git)/plugins=(git\n\
extract\n\
sudo\n\
history\n\
safe-paste\n\
python\n\
pip\n\
colored-man-pages\n\
web-search\n\
zsh-syntax-highlighting\n\
zsh-autosuggestions)/gi" ~/.zshrc
```
#### alias file 
###### _create a_ `~/.aliases` _file first if not created already_
```sh
echo -e "\nsource \$HOME/.aliases\n" | tee -a ~/.zshrc
```
#### adding user dir to $PATH
```sh
echo -e "\nexport PATH=\"\$HOME/.local/bin:\$PATH\"" | tee -a ~/.zshrc
```

  
  
  
---------------------------------------------------------------------  
--------------------------------------------------------------------- 
# TWEAKS
  

## * changing swappiness:
```sh
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
```
  
  
---------------------------------------------------------------------  
  
## * limit journal entry:
```sh
sudo journalctl --vacuum-time=31days
```

---------------------------------------------------------------------  

## * advanced cp and mv:
###### _(With progressbar)_
_(https://github.com/jarun/advcpmv)_

#### building
```sh
wget http://ftp.gnu.org/gnu/coreutils/coreutils-9.0.tar.xz
tar xvJf coreutils-9.0.tar.xz
cd coreutils-9.0/
wget https://raw.githubusercontent.com/jarun/advcpmv/master/advcpmv-0.9-9.0.patch
patch -p1 -i advcpmv-0.9-9.0.patch
./configure
make
```

#### installing
```sh
sudo mv ./src/cp /usr/local/bin/copy && \
sudo mv ./src/mv /usr/local/bin/move
```
  
#### set alias
```sh
echo -e "\n## Advanced cp and mv\n
alias copy='copy -gr'\n
alias move='move -g'" | \
tee -a ~/.aliases
```

  
---------------------------------------------------------------------  
## * colored ls:

### lsd
_(https://github.com/Peltoche/lsd)_

```sh
wget -c https://github.com/Peltoche/lsd/releases/download/0.20.1/lsd_0.20.1_amd64.deb
```

```sh
sudo apt install ./lsd_0.20.1_amd64.deb
```

#### set alias
```sh
echo -e \
"alias lc='lsd'\n\
alias l='lsd --group-dirs first'\n\
alias la='lsd -A --group-dirs first'\n\
alias ll='lsd -lA --group-dirs first'\n\
alias lt='lsd --tree --depth 2 --group-dirs first'\n\
alias lta='lsd -A --tree --depth 3 --group-dirs first'"\
| tee -a ~/.aliases
```

  
---------------------------------------------------------------------  

## * colored cat
_(https://github.com/owenthereal/ccat)_

#### Dependencies

```sh
pip3 install pygments
```

#### Installing

```sh
wget -O ~/Downloads/ccat-linux-amd64-1.1.0.tar.gz \
https://github.com/owenthereal/ccat/releases/download/v1.1.0/linux-amd64-1.1.0.tar.gz
```
```sh
tar xvf ~/Downloads/ccat-linux-amd64-1.1.0.tar.gz && \
sudo cp ~/Downloads/linux-amd64-1.1.0/ccat /usr/local/bin/ccat
```
```sh
echo -e "alias cat='ccat'" | tee -a ~/.aliases
```

  
---------------------------------------------------------------------  
---------------------------------------------------------------------  
# PACKAGES
  
  
`sudo apt update && sudo apt upgrade -y`

#### basic packages:
```sh
sudo apt-get install \
ubuntu-restricted-extras \
git curl zsh \
fonts-powerline ttf-mscorefonts-installer \
ntfs-3g grub-customizer \
adb fastboot scrcpy openvpn \
m17n-db ibus-avro goldendict \
gimp inkscape krita qbittorrent \
flameshot kazam \
obs-studio nomacs \
thunderbird birdtray \
numix-icon-theme-circle gnome-icon-theme lxappearance \
onboard

```

#### build essentials:
```sh
sudo apt-get install \
build-essential dpkg-repack dkms cmake checkinstall
```

#### python:
```sh
sudo apt-get install \
python2 python3 python3-pip
```

#### gtk tools
```sh
sudo apt-get install \
synaptic gparted catfish gnome-disk-utility \
gnome-keyring seahorse keepassxc libsecret-tools
```

#### kde tools:
```sh
sudo apt-get install \
qapt-deb-installer yakuake xdg-desktop-portal-gtk xdg-desktop-portal-kde \
muon krfb redshift filelight latte-dock \
falkon okular ksysguard dolphin konsole
```
#### cli tools:
```sh
sudo apt-get install \
testdisk mc ffmpeg elinks rtorrent cmus cava \
screen byobu openssh-server openssh-client openssh-askpass vsftpd \
htop inxi neofetch whois vnstat iftop dnstop bmon nmap \
bat fim mpv units imagemagick ghostscript mlocate
```
#### fun commands:
```sh
sudo apt-get install \
figlet boxes cmatrix toilet sl cowsay lolcat fortune
```

#### screensaver:
```sh
sudo apt-get install \
xscreensaver xscreensaver-\* 
```
  
  
  
  
## * Install Flatpak

```sh
sudo add-apt-repository ppa:flatpak/stable 
```

```sh
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

---------------------------------------------------------------------  
---------------------------------------------------------------------  
# ADDITIONAL PACKAGES
  
  
## * youtube-dl
###### (youtube downloader)
_(https://youtube-dl.org)_
  
#### direct installation
```sh
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
```
```sh
sudo chmod a+rx /usr/local/bin/youtube-dl
```

  
#### or, via pip
```sh
pip3 install --upgrade youtube_dl
```


---------------------------------------------------------------------  

## * zoom
###### (video meeting client)
```sh
wget -cO zoom_amd64.deb https://zoom.us/client/latest/zoom_amd64.deb && \
sudo apt install ./zoom_amd64.deb
```

---------------------------------------------------------------------  


### * telegram

```sh
sudo apt install telegram-desktop
```
#### or,

```sh
wget -cO telegram-linux.tar.xz https://telegram.org/dl/desktop/linux
```
```sh
tar -xvJf telegram-linux.tar.xz && cd Telegram
```

 
---------------------------------------------------------------------  

## * speedtest-cli
_(https://speedtest.net)_

```sh
curl -s https://install.speedtest.net/app/cli/install.deb.sh | sudo bash
```
```sh
sudo apt-get install speedtest
```
 


---------------------------------------------------------------------  

## * brave-browser

```sh
sudo apt install apt-transport-https curl gnupg
```
```sh
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc \
| sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
```
```sh
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" \
| sudo tee /etc/apt/sources.list.d/brave-browser-release.list
```
```sh
sudo apt update && sudo apt install brave-browser
```


---------------------------------------------------------------------  


## * discord
###### (Online chat and communication client)
```sh
wget -cO discord.deb https://discord.com/api/download\?platform\=linux\&format\=deb && \
sudo apt install ./discord.deb
```



---------------------------------------------------------------------  

## * smplayer
###### (powerful video player)
```sh
sudo add-apt-repository ppa:rvm/smplayer
```
```sh
sudo apt-get update && sudo apt-get install mplayer smplayer smplayer-themes smplayer-skins
```



---------------------------------------------------------------------  

## * anydesk
###### (remote desktop sharing and control)
```sh
wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo apt-key add -
```
```sh
echo "deb http://deb.anydesk.com/ all main" \
| sudo tee /etc/apt/sources.list.d/anydesk-stable.list
```
```sh
sudo apt update && sudo apt install anydesk
```
  
  
---------------------------------------------------------------------  

### * kvantum theme engine

```sh
sudo add-apt-repository ppa:papirus/papirus
```

```sh
sudo apt update && sudo apt install qt5-style-kvantum qt5-style-kvantum-themes
```

---------------------------------------------------------------------  

## * VSCodium

download package from the releases page and install:
https://github.com/vscodium/vscodium/releases

---------------------------------------------------------------------  

## * AppImage-Launcher
download package from the releases page and install:
https://github.com/TheAssassin/AppImageLauncher/releases

#### or via ppa

```sh
sudo add-apt-repository ppa:appimagelauncher-team/stable
```
```sh
sudo apt update
```
```sh
sudo apt install appimagelauncher
```

---------------------------------------------------------------------  

## * Ulauncher
_(https://github.com/Ulauncher/Ulauncher)_

#### ppa
```sh
sudo add-apt-repository ppa:agornostal/ulauncher && \
sudo apt update && \
sudo apt install ulauncher
```

#### or download _*.deb_ file and install

---------------------------------------------------------------------  

### Optional Tweaks 

##### * Fix Ghostscript policy restriction:
```sh
sudo sed -i '/disable ghostscript format types/,+6d' /etc/ImageMagick-6/policy.xml
```
