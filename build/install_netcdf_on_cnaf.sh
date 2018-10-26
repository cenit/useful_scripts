#!/bin/sh 

module purge
module load compilers/gcc-7.1.0
module load boost_1_64_0_gcc7_1_0
module load compilers/openmpi-2.1.1_gcc-7.1.0
export CC=$(which gcc)
export CXX=$(which g++)
export FC=$(which gfortran)
export F90=$(which gfortran)

export H5DIR=/shared/software/project/aladyn/hdf5/hdf5-1.8.20/
export NCDIR=/shared/software/project/aladyn/netcdf/netcdf-4.4.1.1/

rm -rf /shared/software/project/aladyn/netcdf

cd /shared/software/project/aladyn/
mkdir netcdf
cd netcdf/
mkdir build
cd build/
wget https://github.com/Unidata/netcdf-c/archive/v4.4.1.1.tar.gz
mv v4.4.1.1.tar.gz netcdf-c-4.4.1.1.tar.gz
wget https://github.com/Unidata/netcdf-fortran/archive/v4.4.4.tar.gz
mv v4.4.4.tar.gz netcdf-fortran-4.4.4.tar.gz
tar zxvf netcdf-c-4.4.1.1.tar.gz 
tar zxvf netcdf-fortran-4.4.4.tar.gz

cd netcdf-c-4.4.1.1/
mkdir build
cd build
cmake .. -D"CMAKE_INSTALL_PREFIX=${NCDIR}" -D"HDF5_ROOT=${H5DIR}" -DCMAKE_BUILD_TYPE=Release 
cmake --build . --target install
cd ..
cd ..

cd netcdf-fortran-4.4.4
mkdir build
cd build
cmake .. -D"CMAKE_INSTALL_PREFIX=${NCDIR}" -D"HDF5_ROOT=${H5DIR}" -DCMAKE_BUILD_TYPE=Release
cmake --build . --target install
cd ..
cd ..

rm -rf netcdf-c-4.4.1.1
rm -rf netcdf-fortran-4.4.4

