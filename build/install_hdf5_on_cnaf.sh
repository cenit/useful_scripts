#!/bin/sh
  
module purge
module load compilers/gcc-7.1.0
module load boost_1_64_0_gcc7_1_0
module load compilers/openmpi-2.1.1_gcc-7.1.0
export CC=$(which gcc)
export CXX=$(which g++)
export FC=$(which gfortran)
export F90=$(which gfortran)

cd /shared/software/project/aladyn/hdf5

wget --no-check-certificate https://support.hdfgroup.org/ftp/HDF5/current18/src/CMake-hdf5-1.8.20.tar.gz 
tar zxvf CMake-hdf5-1.8.20.tar.gz 
mv CMake-hdf5-1.8.20 hdf5-1.8.20_source
mkdir hdf5-1.8.20
cd hdf5-1.8.20_source/
ctest -S HDF5config.cmake,BUILD_GENERATOR=Unix,FORTRAN_LIBRARIES=YES,INSTRALLDIR=/shared/software/project/aladyn/hdf5/hdf5-1.8.20/ -C Release -VV -O hdf5.log
cd build
mv HDF5-1.8.20-Linux.tar.gz ..
cd ..
tar zxvf HDF5-1.8.20-Linux.tar.gz 
mv HDF5-1.8.20-Linux/HDF_Group/HDF5/1.8.20/* ../hdf5-1.8.20/
cd ..
rm -rf hdf5-1.8.20_source CMake-hdf5-1.8.20.tar.gz 

