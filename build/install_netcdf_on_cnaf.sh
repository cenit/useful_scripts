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
wget https://github.com/Unidata/netcdf-c/archive/v4.4.1.1.tar.gz
mv v4.4.1.1.tar.gz netcdf-4.4.1.1.tar.gz
tar zxvf netcdf-4.4.1.1.tar.gz 
cd netcdf-c-4.4.1.1/
H5DIR=/shared/software/project/aladyn/hdf5/hdf5-1.8.20/
NCDIR=/shared/software/project/aladyn/netcdf/

mkdir build
cd build
cmake .. -D"CMAKE_INSTALL_PREFIX=${NCDIR}" -D"HDF5_DIR=${H5DIR}" 
cmake --build . --target install
cd ..
rm -rf build

