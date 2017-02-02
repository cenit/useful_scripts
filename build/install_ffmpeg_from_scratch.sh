# adapted from http://trac.ffmpeg.org/wiki/CompilationGuide/Centos
# make sure to add ${BUILD_FOLDER}/bin to PATH and ${BUILD_FOLDER}/lib to LD_LIBRARY_PATH before starting


BUILD_FOLDER=/shared/software/ffmpeg/build
SOURCE_FOLDER=/shared/software/ffmpeg/source

mkdir ${SOURCE_FOLDER}
mkdir ${BUILD_FOLDER}

export PKG_CONFIG_PATH=${BUILD_FOLDER}/lib/pkgconfig

cd ${SOURCE_FOLDER}
wget http://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz
tar zxvf libtool-2.4.6.tar.gz
cd libtool-2.4.6
./configure --prefix="${BUILD_FOLDER}"
make
make install

cd ${SOURCE_FOLDER}
git clone --depth 1 git://github.com/yasm/yasm.git
cd yasm
autoreconf -fiv
./configure --prefix="${BUILD_FOLDER}"
make
make install
make distclean

cd ${SOURCE_FOLDER}
git clone --depth 1 git://git.videolan.org/x264
cd x264
./configure --prefix="${BUILD_FOLDER}" --enable-static
make
make install
make distclean

cd ${SOURCE_FOLDER}
hg clone https://bitbucket.org/multicoreware/x265
cd x265/build/linux
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${BUILD_FOLDER}" -DENABLE_SHARED:bool=off ../../source
make
make install

cd ${SOURCE_FOLDER}
wget http://downloads.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-0.1.4.tar.gz
tar zxvf fdk-aac-0.1.4.tar.gz
cd fdk-aac-0.1.4
./configure --prefix="${BUILD_FOLDER}" --disable-shared
make
make install
make distclean

cd ${SOURCE_FOLDER}
curl -L -O http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
tar xzvf lame-3.99.5.tar.gz
cd lame-3.99.5
./configure --prefix="${BUILD_FOLDER}" --disable-shared --enable-nasm
make
make install
make distclean

cd ${SOURCE_FOLDER}
curl -O http://downloads.xiph.org/releases/ogg/libogg-1.3.2.tar.gz
tar xzvf libogg-1.3.2.tar.gz
cd libogg-1.3.2
./configure --prefix="${BUILD_FOLDER}"
make
make install
make distclean

cd ${SOURCE_FOLDER}
curl -O http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.4.tar.gz
tar xzvf libvorbis-1.3.4.tar.gz
cd libvorbis-1.3.4
#LDFLAGS="-L${BUILD_FOLDER}/lib" CPPFLAGS="-I${BUILD_FOLDER}/include"
./configure --prefix="${BUILD_FOLDER}" --with-ogg="${BUILD_FOLDER}"
make
make install
make distclean

cd ${SOURCE_FOLDER}
wget http://downloads.xiph.org/releases/opus/opus-1.1.tar.gz
tar zxvf opus-1.1.tar.gz
cd opus-1.1
./configure --prefix="${BUILD_FOLDER}"
make
make install
make distclean

cd ${SOURCE_FOLDER}
wget http://downloads.xiph.org/releases/flac/flac-1.3.1.tar.xz
tar xJvf flac-1.3.1.tar.xz
cd flac-1.3.1
./configure --prefix="${BUILD_FOLDER}"
make
make install
make distclean

cd ${SOURCE_FOLDER}
wget https://ftp.mozilla.org/pub/mozilla.org/opus/opus-tools-0.1.9.tar.gz
tar zxvf opus-tools-0.1.9.tar.gz
cd opus-tools-0.1.9
./configure --prefix="${BUILD_FOLDER}"
make
make install
make distclean

cd ${SOURCE_FOLDER}
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
./configure --prefix="${BUILD_FOLDER}" --disable-examples
make
make install
make clean

cd ${SOURCE_FOLDER}
git clone --depth 1 git://source.ffmpeg.org/ffmpeg
cd ffmpeg
./configure --prefix="${BUILD_FOLDER}" --extra-cflags="-I${BUILD_FOLDER}/include" --extra-ldflags="-L${BUILD_FOLDER}/lib"  --pkg-config-flags="--static" --enable-gpl --enable-nonfree --enable-libfdk_aac --enable-libfreetype --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265
make
make install
make distclean
hash -r

