#!/bin/bash

export CC=/usr/local/opt/llvm/bin/clang
export CXX=/usr/local/opt/llvm/bin/clang++
#export LDFLAGS=-L/usr/local/opt/llvm/lib
#export CPPFLAGS=-I/usr/local/opt/llvm/include
export LDFLAGS="-L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib"

mkdir build && cd build
cmake ../toolsrc/
cmake --build .
cp vcpkg ../
