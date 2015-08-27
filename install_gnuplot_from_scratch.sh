#STILL NOT WORKING, BUT YOU CAN INSTALL DEPENDENCIES THROUGH yum IF YOU WANT, UNCOMMENTING A LINE AT THE END
#AND SETTING TO true THE FOLLOWING DEFINITION
BUILD_DEPENDENCIES=false


# make sure to add ${BUILD_FOLDER}/bin to PATH and ${BUILD_FOLDER}/lib to LD_LIBRARY_PATH before starting

BUILD_FOLDER=/shared/software/project/aladyn/gnuplot/build
SOURCE_FOLDER=/shared/software/project/aladyn/gnuplot/source

rm -rf ${SOURCE_FOLDER} ${BUILD_FOLDER}
mkdir ${SOURCE_FOLDER}
mkdir ${BUILD_FOLDER}

export PKG_CONFIG_PATH=${BUILD_FOLDER}/lib/pkgconfig

if ( "$BUILD_DEPENDENCIES" = true ) then
cd ${SOURCE_FOLDER}
wget http://download.savannah.gnu.org/releases/freetype/freetype-2.5.5.tar.gz
tar zxvf freetype-2.5.5.tar.gz
cd freetype-2.5.5
./configure --prefix="${BUILD_FOLDER}"
make
make install

cd ${SOURCE_FOLDER}
wget http://www.freedesktop.org/software/fontconfig/release/fontconfig-2.11.94.tar.gz
tar zxvf fontconfig-2.11.94.tar.gz
cd fontconfig-2.11.94
./configure --prefix="${BUILD_FOLDER}"
make
make install

cd ${SOURCE_FOLDER}
wget http://prdownloads.sourceforge.net/libpng/libpng-1.6.18.tar.gz
tar zxvf libpng-1.6.18.tar.gz
cd libpng-1.6.18
./configure --prefix="${BUILD_FOLDER}"
make
make install

cd ${SOURCE_FOLDER}
wget http://cairographics.org/releases/pixman-0.32.6.tar.gz
tar zxvf pixman-0.32.6.tar.gz
cd pixman-0.32.6
./configure --prefix="${BUILD_FOLDER}"
make
make install

cd ${SOURCE_FOLDER}
wget http://cairographics.org/releases/cairo-1.14.2.tar.xz
tar Jxvf cairo-1.14.2.tar.xz
cd  cairo-1.14.2
./configure --prefix="${BUILD_FOLDER}"
make
make install

cd ${SOURCE_FOLDER}
wget http://www.freedesktop.org/software/harfbuzz/release/harfbuzz-1.0.2.tar.bz2
tar jxvf harfbuzz-1.0.2.tar.bz2
cd harfbuzz-1.0.2
./configure --prefix="${BUILD_FOLDER}"
make
make install

cd ${SOURCE_FOLDER}
wget http://ftp.gnome.org/pub/GNOME/sources/pango/1.37/pango-1.37.3.tar.xz
tar Jxvf pango-1.37.3.tar.xz
cd pango-1.37.3
./configure --prefix="${BUILD_FOLDER}"
make
make install

cd ${SOURCE_FOLDER}
wget https://github.com/libgd/libgd/archive/gd-2.1.1.tar.gz
tar zxvf gd-2.1.1.tar.gz
cd libgd-gd-2.1.1
./bootstrap.sh
./configure --prefix="${BUILD_FOLDER}"
make
make install

cd ${SOURCE_FOLDER}
wget http://downloads.sourceforge.net/project/wxwindows/3.0.2/wxWidgets-3.0.2.tar.bz2
tar jxvf wxWidgets-3.0.2.tar.bz2
cd wxWidgets-3.0.2
./configure --prefix="${BUILD_FOLDER}"
make
make install




else
echo "Using system libraries"
#sudo yum install cairo-devel pango-devel freetype-devel gd-devel libpng-devel wxGTK-devel wxBase
fi


cd ${SOURCE_FOLDER}
wget http://downloads.sourceforge.net/project/gnuplot/gnuplot/5.0.1/gnuplot-5.0.1.tar.gz
tar zxvf gnuplot-5.0.1.tar.gz
cd gnuplot-5.0.1
./configure --prefix="${BUILD_FOLDER}"
make
make install


