## * youtube-dl
###### (youtube downloader)
  
#### direct installation
```sh
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
```
```sh
sudo chmod a+rx /usr/local/bin/youtube-dl
```
#### or, via pip
```sh
sudo pip install --upgrade youtube_dl
```



---------------------------------------------------------------------  

## * speedtest-cli
```sh
sudo apt-get install gnupg1 apt-transport-https dirmngr
```
```sh
export INSTALL_KEY=379CE192D401AB61
```
```sh
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $INSTALL_KEY
```
```sh
echo "deb https://ookla.bintray.com/debian generic main" | sudo tee  /etc/apt/sources.list.d/speedtest.list
```
```sh
sudo apt-get update
```
```sh
sudo apt-get install speedtest
```



---------------------------------------------------------------------  

## * subliminal
###### (subtitle downloader)

depends on: `python python3-pip python-setuptools python3-setuptools python-wheel-common`

#### installation
```sh
sudo pip install subliminal
```
```sh
echo "alias subltitle='subliminal download -l en ./' " | tee -a .aliases
```



---------------------------------------------------------------------  

## * brave-browser
```sh
sudo apt install apt-transport-https curl gnupg
```
```sh
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
```
```sh
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
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
qapt-deb-installer $(wget -c -O discord.deb https://discord.com/api/download\?platform\=linux\&format\=deb)
```



---------------------------------------------------------------------  

## * spotify
###### (Music streaming client)
```sh
curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/spotify.gpg add -
```
```sh
echo "deb [trusted=yes] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
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
echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list
```
```sh
apt update && apt install -y anydesk
```
  
   

---------------------------------------------------------------------  
--------------------------------------------------------------------- 
  [_[Main list]_](../README.md)  
[_<<Previous (Package installation)_](package-installation.md)  
