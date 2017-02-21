#!/bin/bash

echo Smilei
cd Smilei/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo PIConGPU
cd picongpu/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo psc
cd psc/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo gnuplot-colorbrewer
cd gnuplot-colorbrewer/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo VTKFortran 
cd VTKFortran/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo ramses 
cd ramses/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo epoch 
cd epoch/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo EPOCH_manuals 
cd EPOCH_manuals/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo QGIS 
cd QGIS/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo json 
cd json/
git fetch upstream
git checkout develop
git merge upstream/develop
git push
cd ..

echo jsoncons 
cd jsoncons/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo Nominatim 
cd Nominatim/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo mosquitto 
cd mosquitto/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo geopy 
cd geopy/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo pyUblox 
cd pyUblox/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo Catch 
cd Catch/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo RTKLIB 
cd RTKLIB/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo numerical-methods-fortran  
cd numerical-methods-fortran/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo densityClust
cd densityClust
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo community_bash_style_guide
cd community_bash_style_guide/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo ALaDyn_cenit
cd ALaDyn_cenit/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo Propaga_cenit
cd Propaga_cenit/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

echo Stats
cd Stats/
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

