#!/bin/bash

set -e

SIMPLE_VIM_PATH=$(dirname "$(readlink -f "$0")")

cd $SIMPLE_VIM_PATH

if [ ! -d ./tools ]; then
  echo "simple-vim tools not found"
  echo "please mkdir tools and download from https://drive.google.com/drive/folders/1FR2ZDnq2HIjNRY-3pfVnFrKLK_m3rM2N?usp=sharing"
  echo "- all-pkg.tar.gz : all package zip"
  echo "- vim.tar.gz : all .vim zip"
  echo "------ download all tar.gz to tools ------"
  echo "any question please email to lsken00@qq.com"
  exit 0
fi

pushd $HOME
if [ -f ".vimrc" ] || [ -f ".vim" ]; then
  mv .vim .vim-bak
  mv .vimrc .vimrc-bak
  echo "mv  ~/.vim and ~/.vimrc to ~/.vim-bak and ~/.vimrc-bak"
fi

pushd $HOME/simple-vim/tools
# Check if both required tar.gz files exist
if [ ! -f "vim.tar.gz" ] || [ ! -f "all-pkg.tar.gz" ]; then
  echo "Error: Missing required tar.gz files!"
  echo "Please ensure both 'vim.tar.gz' and 'all-pkg.tar.gz' are present in the tools."
  exit 1
fi

# Check if 'vim' directory exists, if not, extract vim.tar.gz
if [ ! -d "vim" ]; then
  echo "vim directory does not exist, extracting vim.tar.gz..."
  tar zxf vim.tar.gz
else
  echo "vim directory already exists, skipping extraction."
fi

# Check if 'all-pkg' directory exists, if not, extract all-pkg.tar.gz
if [ ! -d "all-pkg" ]; then
  echo "all-pkg directory does not exist, extracting all-pkg.tar.gz..."
  tar zxf all-pkg.tar.gz
else
  echo "all-pkg directory already exists, skipping extraction."
fi
popd

ln -s simple-vim/tools/vim .vim
ln -s simple-vim/vimrc .vimrc

popd
