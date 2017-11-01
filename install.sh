#!/bin/bash
cpath=$(cd "$(dirname "$0")";pwd) 
cd ~
rm -r .vim .vimrc .tmux .tmux.conf .zshrc 
cd ${cpath}
cp -r .vim .vimrc .tmux .tmux.conf .zshrc ~
