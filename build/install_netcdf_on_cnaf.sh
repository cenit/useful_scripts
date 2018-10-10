#!/bin/sh 

module purge
module load compilers/gcc-7.1.0
module load boost_1_64_0_gcc7_1_0
module load compilers/openmpi-2.1.1_gcc-7.1.0
export CC=$(which gcc)
export CXX=$(which g++)
export FC=$(which gfortran)
export F90=$(which gfortran)

rm -rf /shared/software/project/aladyn/netcdf

cd /shared/software/project/aladyn/
mkdir netcdf
cd netcdf/
mkdir build
cd build/
#wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-4.4.4.tar.gz
#wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-cxx4-4.3.0.tar.gz
#wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.6.1.tar.gz
wget https://github.com/Unidata/netcdf-c/archive/v4.4.1.1.tar.gz
mv v4.4.1.1.tar.gz netcdf-4.4.1.1.tar.gz
tar zxvf netcdf-4.4.1.1.tar.gz 
cd netcdf-c-4.4.1.1/
H5DIR=/shared/software/project/aladyn/hdf5/hdf5-1.8.20/
#H5DIR=/shared/software/project/aladyn/hdf5/hdf5-1.8.20/share/cmake/
NCDIR=/shared/software/project/aladyn/netcdf/


#CPPFLAGS=-I${H5DIR}/include LDFLAGS=-L${H5DIR}/lib ./configure --prefix=${NCDIR}
#make check
#make install

mkdir build
cd build
#cmake .. -D"CMAKE_INSTALL_PREFIX=${NCDIR}" -D"HDF5_ROOT=${H5DIR}" -D"HDF5_NO_FIND_PACKAGE_CONFIG_FILE=ON"
cmake .. -D"CMAKE_INSTALL_PREFIX=${NCDIR}" -D"HDF5_DIR=${H5DIR}" 
cmake --build . --target install

