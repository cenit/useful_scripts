#! /usr/bin/env bash

# make sure to add ${BUILD_FOLDER}/bin to PATH

BUILD_FOLDER=/shared/software/project/aladyn/ghostscript/

rm -rf ${BUILD_FOLDER}
mkdir -p ${BUILD_FOLDER}

wget https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs920/ghostscript-9.20.tar.gz
tar zxvf ghostscript-9.20.tar.gz
cd ghostscript-9.20
./configure --prefix="${BUILD_FOLDER}"
make
make install
