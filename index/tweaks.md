
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
source: https://github.com/jarun/advcpmv 

#### building
```sh
wget http://ftp.gnu.org/gnu/coreutils/coreutils-8.32.tar.xz
tar xvJf coreutils-8.32.tar.xz && cd coreutils-8.32/
wget https://raw.githubusercontent.com/jarun/advcpmv/master/advcpmv-0.8-8.32.patch
patch -p1 -i advcpmv-0.8-8.32.patch
./configure
make
```
  
  
#### put files to proper $PATH
```sh
sudo cp ./src/cp /usr/local/bin/copy && sudo cp ./src/mv /usr/local/bin/move
```
  
  
#### set alias
```sh
echo -e "\n## Advanced cp and mv\nalias copy='copy -gR'\nalias move='move -g'" | tee -a .aliases
```

  
---------------------------------------------------------------------  
---------------------------------------------------------------------  

  [_[Main list]_](../README.md)  
[_<< Previous (Basic commands)_](basic-commands.md)  
[_(Package installation) Next >>_](package-installation.md)  
