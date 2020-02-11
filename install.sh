#!/bin/bash
#
# ./install.sh work|personal
#

if [ x"$1" == x ]; then
  isPersonal=1
else
  isPersonal=0
fi

if [ x"$1" == xpersonal ]; then
  isPersonal=1
fi

if [ x"$1" == xwork ]; then
  isPersonal=0
fi

echo -e "Update & upgrade apt repository"
sudo apt-cache update
sudo apt-get upgrade

cp ./home/vimrc		$HOME/.vimrc
cp ./home/dircolors	$HOME/.dircolors
cp ./home/bash_aliases	$HOME/.bash_aliases
echo -e "Environment setup: .vimrc .dircolors .bash_aliases"

mkdir -p $HOME/common/bin

echo -e "Environment setup: .gitconfig for work"
cp ./home/gitconfig	$HOME/.gitconfig
mkdir -p $HOME/repos/elvinongbl-github
cp ./home/repos/elvinongbl-github/gitconfig	$HOME/repos/elvinongbl-github/.gitconfig
echo -e "Please add new gmail and patchwork token"

if [ $isPersonal == 0 ]; then
  echo -e "Further tool chain for proxied work environment"
  # socat for work proxy
  cp ./home/common/bin/socatproxy	$HOME/common/bin/socatproxy
  chmod +x $HOME/common/bin/socatproxy
  echo -e "Tool added: socat for git"
  sudo apt-get install -y socat
else
  echo -e "Environment setup: ~/.gitconfig for personal"
  # if environment for personal, overwrite the ~/.gitconfig
  cp $HOME/repos/elvinongbl-github/.gitconfig	$HOME/.gitconfig
  rm $HOME/repos/elvinongbl-github/.gitconfig
fi

# Install ssh daemon for external access
sudo apt-get install -y openssh-server

# Install software packages for editing
sudo apt-get install -y vim.nox

# Install software packages for kernel development
# Reference: https://kernelnewbies.org/OutreachyfirstpatchSetup
sudo apt-get install -y \
  vim libncurses5-dev gcc make git \
  exuberant-ctags libssl-dev bison flex libelf-dev bc

# Install software packages for system monitoring
sudo apt-get install -y \
  i7z
