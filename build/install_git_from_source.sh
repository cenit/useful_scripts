#!/bin/sh

GIT_VERSION=2.19.1

tar zxvf git-${GIT_VERSION}.tar.gz 
cd git-${GIT_VERSION}/
make configure
./configure --prefix=/opt/git/git-${GIT_VERSION}
make all doc info
make install install-doc install-html install-info
