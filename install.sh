#!/bin/bash

echo -e "Update & upgrade apt repository"
sudo apt-cache update
sudo apt-get upgrade

cp ./home/vimrc		$HOME/.vimrc
cp ./home/dircolors	$HOME/.dircolors
echo -e "Environment setup: .vimrc .dircolors"

mkdir -p $HOME/common/bin
cp ./home/common/bin/socatproxy		$HOME/common/bin/socatproxy
chmod +x $HOME/common/bin/socatproxy
echo -e "Tool added: socat for git"
sudo apt-get install -y socat

cp ./home/gitconfig	$HOME/.gitconfig
mkdir -p $HOME/repos/elvinongbl-github
cp ./home/repos/elvinongbl-github/gitconfig	$HOME/repos/elvinongbl-github/.gitconfig
echo -e "Environment setup: .gitconfig for work & personal github"
echo -e "Please add new gmail and patchwork token"
