#!/usr/bin/env bash
cmake -G "Unix Makefiles"  -DEXTERNAL_LIBCLANG_PATH= ~/ycm_temp/llvm_root_dir/clang+llvm-4.0.0-x86_64-linux-gnu-ubuntu-14.04/.   ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp
