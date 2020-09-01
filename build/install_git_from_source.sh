#!/bin/sh

GIT_VERSION=2.28.0
wget https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz --no-check-certificate
tar zxvf v${GIT_VERSION}.tar.gz
cd git-${GIT_VERSION}/
make configure
./configure --prefix=/opt/git/git-${GIT_VERSION}
make all doc info
make install install-doc install-html install-info
