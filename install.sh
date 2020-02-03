#!/bin/bash

cp ./home/vimrc		$HOME/.vimrc
cp ./home/dircolors	$HOME/.dircolors
echo -e "Environment setup: .vimrc .dircolors"

cp ./home/gitconfig	$HOME/.gitconfig
mkdir -p $HOME/repos/elvinongbl-github
cp ./home/repos/elvinongbl-github/gitconfig	$HOME/repos/elvinongbl-github/.gitconfig
echo -e "Environment setup: .gitconfig for work & personal github"
echo -e "Please add new gmail and patchwork token"
