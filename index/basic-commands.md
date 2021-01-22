
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
export CODENAME=$(lsb_release -c | cut -f2);
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

###### if add-apt-repository is unavailable: 
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
`zsh curl git`

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
sed -i "s/robbyrussell/powerlevel10k\/powerlevel10k/gi" .zshrc
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
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20" >> .zshrc
```
#### adding plugins
```sh
sed -i "s/plugins=(git)/plugins=(git \n\
extract \n\
adb \n\
sudo \n\
history \n\
safe-paste \n\
python pip \n\
colored-man-pages \n\
colorize web-search \n\
zsh-syntax-highlighting \n\
zsh-autosuggestions)/gi" ~/.zshrc
```
#### alias file 
###### _create a_ `~/.aliases` _file first if not created already_
```sh
echo -e "\nsource \$HOME/.aliases\n" | tee -a ~/.zshrc
```
#### adding new dir to $PATH
```sh
echo -e "\nexport PATH=\"\$HOME/.local/bin:\$PATH\"" | tee -a ~/.zshrc
```
  
  
  
---------------------------------------------------------------------  

## * colorls:
```sh
sudo apt install -y ruby-dev
``` 
```sh
sudo gem install colorls
```



  
 
--------------------------------------------------------------------- 
--------------------------------------------------------------------- 
  [_[Main list]_](../README.md)  
[_(tweaks) next >>_](tweaks.md)
