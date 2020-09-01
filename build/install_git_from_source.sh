#!/bin/sh

#sudo apt-get install asciidoc
#sudo apt-get install docbook2x
#sudo apt-get install libcurl4-openssl-dev  #libcurl4-gnutls-dev has problems with proxies
#sudo apt-get install dh-autoreconf libexpat1-dev gettext libz-dev libssl-dev
#sudo apt-get install xmlto

GIT_VERSION=2.28.0
wget https://github.com/git/git/archive/v${GIT_VERSION}.tar.gz --no-check-certificate
tar zxvf v${GIT_VERSION}.tar.gz
cd git-${GIT_VERSION}/
make configure
./configure --prefix=/opt/git/git-${GIT_VERSION}
make all doc info
make install install-doc install-html install-info
