#! /usr/bin/env bash

cd ~/Downloads

sudo apt-get install plplot-tcl-dev libgsl0-dev libreadline-dev libzip-dev imagemagick pslib-dev  python python-numpy
sudo apt-get install libncurses-dev
sudo apt-get install libplplot-dev
sudo apt-get install libmagick++-dev
sudo apt-get install libwxgtk2.8-dev
sudo apt-get install libnetcdf-dev libhdf5-dev
sudo apt-get install libhdf4-alt-dev
sudo apt-get install libeigen3-dev

wget ftp://ftp.gnu.org/gnu/ncurses/ncurses-6.0.tar.gz
tar zxvf ncurses-6.0.tar.gz
cd ncurses-6.0/
sudo mkdir /opt/curses
./configure --prefix=/opt/curses/
make
make install

wget http://bitbucket.org/eigen/eigen/get/3.2.7.tar.gz
tar zxvf 3.2.7.tar.gz
cd eigen-eigen-b30b87236a1b/
sudo mkdir /opt/eigen
mkdir build_dir
cd build_dir/
cmake ../ -DCMAKE_INSTALL_PREFIX=/opt/eigen
make install

http://downloads.sourceforge.net/project/gnudatalanguage/gdl/0.9.6/gdl-0.9.6v2.tgz
tar zxvf gdl-0.9.6v2.tgz
cd gdl-0.9.6
mkdir build ; cd build
cd .. ; rm -rf build ; mkdir build ; cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/opt/gdl0.9.6 -DNCURSESDIR=/opt/curses -DEIGEN3DIR=/opt/eigen
make
make install
