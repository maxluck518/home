#!/bin/bash
cpath=$(cd "$(dirname "$0")";pwd) 
cd ~
rm -rf .vim .vimrc .tmux .tmux.conf .zshrc 

cd ${cpath}
cp -rf .vim .vimrc .tmux .tmux.conf .zshrc .ycm_extra_conf.py ycm_build ~

# # YCM
# sudo apt-get update --fix-missing
# sudo apt-get install build-essential cmake3 --fix-missing
# sudo apt-get install python-dev python3-dev --fix-missing
# cd ~/.vim/bundle/YouCompleteMe
# ./install.py --clang-completer
