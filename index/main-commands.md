
## * fix-system-time:
###### If faced time change problem when dual booting with windows
```zsh
timedatectl set-local-rtc 1 --adjust-system-clock
```
#### revert
```zsh
timedatectl set-local-rtc 0 --adjust-system-clock
```

  
  
## * bd-mirrors:

#### ubuntu
```zsh
export CODENAME=$(lsb_release -c | cut -f2)
echo -e "deb http://mirror.xeonbd.com/ubuntu-archive/ $CODENAME main restricted universe multiverse \ndeb http://mirror.xeonbd.com/ubuntu-archive/ $CODENAME-updates main restricted universe multiverse \ndeb http://mirror.xeonbd.com/ubuntu-archive/ $CODENAME-backports main restricted universe multiverse \ndeb http://mirror.xeonbd.com/ubuntu-archive/ $CODENAME-security main restricted universe multiverse" | sudo tee /etc/apt/sources.list.d/bd_mirrors.list
```
#### update apt database:
`sudo apt update && sudo apt upgrade`

  
  
## * apt-fast:

###### if add-apt-repository is unavailable: 
`sudo apt-get install software-properties-common`

#### install:
```zsh
sudo add-apt-repository ppa:apt-fast/stable
sudo apt-get update
sudo apt-get -y install apt-fast
```
#### or, quick install:
```zsh
/bin/bash -c "$(curl -sL https://git.io/vokNn)"
```
  
  
## * oh-my-zsh:

#### packages needed:
`zsh curl git`

#### installing oh-my-zsh
```zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### installing p10k theme
```zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```
#### set theme
```zsh
sed -i "s/robbyrussell/powerlevel10k\/powerlevel10k/gi" .zshrc
```
#### installing zsh-syntax-highlighting
```zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```
#### installing zsh-autosuggestions
```zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```
#### autosuggestions-config
```zsh
echo -e "ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#303030" \nZSH_AUTOSUGGEST_STRATEGY=(history completion) \nZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20" >> .zshrc
```
#### adding plugins
```zsh
sed -i "s/plugins=(git)/plugins=(git extract adb sudo history safe-paste python pip colored-man-pages colorize web-search zsh-syntax-highlighting zsh-autosuggestions)/gi" ~/.zshrc
```
#### alias file 
###### _create a_ `~/.aliases` _file first if not created already_
```zsh
echo -e "\nsource \$HOME/.aliases\n" | tee -a ~/.zshrc
```
#### adding new dir to $PATH
```zsh
echo -e "\nexport PATH=\"\$HOME/.local/bin:\$PATH\"" | tee -a ~/.zshrc
```
  
  
## * colorls:
```zsh
sudo apt install -y ruby-dev
sudo gem install colorls
```

