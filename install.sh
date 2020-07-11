#!/bin/bash
# 1. install vim && tmux
homepath=$1
currpath=$(cd "$(dirname "$0")";pwd) 
cd $homepath
rm -rf .vim .vimrc .tmux .tmux.conf .zshrc 
cd ${currpath}
cp -rf .vim .vimrc .tmux .tmux.conf .zshrc .ycm_extra_conf.py ycm_build ycm_tmp $homepath

# 2. YCM configuration
sudo apt-get update --fix-missing
sudo apt-get install build-essential cmake3 --fix-missing
sudo apt-get install python-dev python3-dev --fix-missing

# 2.1 YCM fast install with C/C++ family
# cd ~/.vim/bundle/YouCompleteMe
# ./install.py --clang-completer

# 2.2 YCM full install with C/C++ family
# extract llvm
cd $homepath/ycm_tmp/llvm_root_dir/
wget https://releases.llvm.org/4.0.0/clang+llvm-4.0.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz
xz -d clang+llvm-4.0.0-x86_64-linux-gnu-ubuntu-14.04.tar.xz
tar -xf clang+llvm-4.0.0-x86_64-linux-gnu-ubuntu-14.04.tar
# compile ycm_core
cd $homepath/ycm_build/
sh build.sh
make all
cd $homepath
