#!/bin/bash

SIMPLE_VIM_PATH=$(dirname "$(readlink -f "$0")")

cd $SIMPLE_VIM_PATH

if [ ! -d ./tools ]; then
	echo "simple-vim tools not found"
	echo "please download from https://drive.google.com/drive/folders/1FR2ZDnq2HIjNRY-3pfVnFrKLK_m3rM2N?usp=sharing"
	exit 0
fi

pushd $HOME
rm  .vim
rm  .vimrc
ln -s simple-vim/tools/vim .vim
ln -s simple-vim/vimrc .vimrc
popd


