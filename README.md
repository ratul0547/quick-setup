
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

#### update apt database:
`sudo apt update && sudo apt upgrade`

  
  
---------------------------------------------------------------------  

## * apt-fast:

###### (A faster way to download packages via aria2 backend)  
  

##### # if add-apt-repository is unavailable: 
`sudo apt-get install software-properties-common`

#### install:
```sh
sudo add-apt-repository ppa:apt-fast/stable
``` 
```sh
sudo apt-get update
``` 
```sh
sudo apt-get -y install apt-fast
```
#### or, quick install:
```sh
/bin/bash -c "$(curl -sL https://git.io/vokNn)"
```
  

  
---------------------------------------------------------------------  

## * oh-my-zsh:

#### packages needed:
`zsh` ` curl` ` git`

#### installing oh-my-zsh
```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### installing p10k theme
```sh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```
#### set theme
```sh
sed -i "s/robbyrussell/powerlevel10k\/powerlevel10k/gi" ~/.zshrc
```
#### installing zsh-syntax-highlighting
```sh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```
#### installing zsh-autosuggestions
```sh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```
#### autosuggestions-config
```sh
echo -e "\
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#303030" \n\
ZSH_AUTOSUGGEST_STRATEGY=(history completion) \n\
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20" \n\
ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c70,)"
ZSH_AUTOSUGGEST_COMPLETION_IGNORE="apt pip pip3" \
>> ~/.zshrc
```
#### adding plugins
```sh
sed -i "s/plugins=(git)/plugins=(git\n\
extract\n\
adb\n\
sudo\n\
history\n\
safe-paste\n\
python\n\
pip\n\
colored-man-pages\n\
colorize\n\
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
## * colored cat
_source: https://github.com/owenthereal/ccat_

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
  
## * advanced cp and mv:
###### _(With progressbar)_
_source: https://github.com/jarun/advcpmv_

#### building
```sh
wget http://ftp.gnu.org/gnu/coreutils/coreutils-8.32.tar.xz
```
```sh
tar xvJf coreutils-8.32.tar.xz && cd coreutils-8.32/
```
```sh
wget https://raw.githubusercontent.com/jarun/advcpmv/master/advcpmv-0.8-8.32.patch
```
```sh
patch -p1 -i advcpmv-0.8-8.32.patch
```
```sh
./configure
```
```sh
make
```
  
#### put files to proper $PATH
```sh
sudo cp ./src/cp /usr/local/bin/copy && sudo cp ./src/mv /usr/local/bin/move
```
  
#### set alias
```sh
echo -e "\n## Advanced cp and mv\nalias copy='copy -gR'\nalias move='move -g'" | tee -a ~/.aliases
```


  
---------------------------------------------------------------------  

## * colored ls:
```sh
sudo apt install -y ruby-dev
``` 
```sh
sudo gem install colorls
```

#### set alias 
```sh
echo -e \
"alias lc='colorls'\n\
alias l='colorls --sd'\n\
alias la='colorls -A --sd'\n\
alias ll='colorls -lA --sd'\n\
alias lt='colorls --sd --tree=2'" \
| tee -a ~/.aliases
```
  
    
---------------------------------------------------------------------  
--------------------------------------------------------------------- 
# PACKAGES
  
  
`sudo apt update && sudo apt upgrade -y`

#### basic apps:
```sh
sudo apt-get install \
ubuntu-restricted-extras \
git curl zsh \
fonts-powerline ttf-mscorefonts-installer \
ntfs-3g grub-customizer \
adb fastboot scrcpy openvpn \
m17n-db ibus-avro goldendict \
stacer gimp inkscape krita qbittorrent \
flameshot kazam \
wine winetricks \

```

#### build essentials:
```sh
sudo apt-get install \
build-essential dpkg-repack dkms cmake checkinstall
```

#### python:
```sh
sudo apt-get install \
python2 python3 python3-pip python-setuptools python3-setuptools python-wheel-common
```

#### gtk tools
```sh
sudo apt-get install \
synaptic gparted catfish gnome-disk-utility 
```

#### kde tools:
```sh
sudo apt-get install \
qapt-deb-installer yakuake xdg-desktop-portal-gtk xdg-desktop-portal-kde \
muon krfb redshift filelight latte-dock
```
#### cli tools:
```sh
sudo apt-get install \
mc ffmpeg elinks rtorrent cmus screen vsftpd \
htop inxi neofetch whois vnstat iftop dnstop bmon \
bat fim mpv 
```
#### fun commands:
```sh
sudo apt-get install \
figlet boxes cmatrix toilet sl cowsay lolcat \
fortune-mod fortunes fortune-min fortune-off
```
#### screensaver:
```sh
sudo apt-get install \
xscreensaver xscreensaver-data-extra xscreensaver-gl xscreensaver-gl-extra 
```
  
  
  
  

--------------------------------------------------------------------- 
---------------------------------------------------------------------  
# ADDITIONAL PACKAGES
  
  
## * youtube-dl
###### (youtube downloader)
  
#### via pip
```sh
pip3 install --upgrade youtube_dl
```
  
#### or, direct installation
```sh
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
```
```sh
sudo chmod a+rx /usr/local/bin/youtube-dl
```


---------------------------------------------------------------------  
## * lyrics-in-terminal

```sh
pip3 install lyrics-in-terminal
```
  
  
---------------------------------------------------------------------  

## * speedtest-cli
```sh
sudo apt-get install gnupg1 apt-transport-https dirmngr
```
```sh
export INSTALL_KEY=379CE192D401AB61;
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $INSTALL_KEY
```
```sh
echo "deb https://ookla.bintray.com/debian generic main" \
| sudo tee  /etc/apt/sources.list.d/speedtest.list
```
```sh
sudo apt-get update && sudo apt-get install speedtest
```
  
---------------------------------------------------------------------  

## * subliminal
###### (subtitle downloader)

depends on: `python` `python3-pip` `python-setuptools` `python3-setuptools` `python-wheel-common`

#### installation
```sh
pip3 install subliminal
```
```sh
echo "alias subltitle='subliminal download -l en ./' " | tee -a ~/.aliases
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
sudo apt update
```
```sh
sudo apt install brave-browser
```



---------------------------------------------------------------------  

## * persepolis
###### (Download manager)
```sh
sudo add-apt-repository ppa:persepolis/ppa
```
```sh
sudo apt update
```
```sh
sudo apt install -y persepolis
```



---------------------------------------------------------------------  

## * clementine
###### (Music player)
```sh
sudo add-apt-repository ppa:me-davidsansome/clementine
```
```sh
sudo apt-get update
```
```sh
sudo apt-get install clementine
```



---------------------------------------------------------------------  

## * discord
###### (Online chat and communication client)
```sh
wget -cO discord.deb https://discord.com/api/download\?platform\=linux\&format\=deb && \
qapt-deb-installer discord.deb
```



---------------------------------------------------------------------  

## * spotify
###### (Music streaming client)
```sh
curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg \
| sudo apt-key --keyring /etc/apt/trusted.gpg.d/spotify.gpg add -
```
```sh
echo "deb [trusted=yes] http://repository.spotify.com stable non-free" \
| sudo tee /etc/apt/sources.list.d/spotify.list
```
```sh
sudo apt-get update && sudo apt-get install -y spotify-client
```



---------------------------------------------------------------------  

## * freetuxtv
###### (live tv)
```sh
sudo add-apt-repository ppa:freetuxtv/freetuxtv-dev
```
```sh
sudo apt update && sudo apt install -y freetuxtv
```


---------------------------------------------------------------------  

## * smplayer
###### (powerful video player)
```sh
sudo add-apt-repository ppa:rvm/smplayer
```
```sh
sudo apt-get update
```
```sh
sudo apt-get install smplayer smplayer-themes smplayer-skins
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
apt update && apt install -y anydesk
```
  
  
---------------------------------------------------------------------  
## * zoom
###### (video meeting client)
```sh
wget -cO zoom_amd64.deb https://zoom.us/client/latest/zoom_amd64.deb && \
sudo apt install zoom_amd64.deb
```
---------------------------------------------------------------------
