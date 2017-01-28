#!/bin/bash

## Smilei
rm -rf Smilei
git clone https://github.com/ALaDyn/Smilei.git
cd Smilei/
git remote add upstream https://github.com/SmileiPIC/Smilei.git
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

## PIConGPU
rm -rf picongpu
git clone https://github.com/ALaDyn/picongpu.git
cd picongpu/
git remote add upstream https://github.com/ComputationalRadiationPhysics/picongpu.git
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

## psc
rm -rf psc
git clone https://github.com/ALaDyn/psc.git
cd psc/
git remote add upstream https://github.com/germasch/psc.git
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

## gnuplot-colorbrewer
rm -rf gnuplot-colorbrewer
git clone https://github.com/ALaDyn/gnuplot-colorbrewer.git
cd gnuplot-colorbrewer/
git remote add upstream https://github.com/aschn/gnuplot-colorbrewer.git
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

## VTKFortran 
rm -rf VTKFortran
git clone https://github.com/ALaDyn/VTKFortran.git
cd VTKFortran/
git remote add upstream https://github.com/szaghi/VTKFortran.git
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

## ramses 
rm -rf ramses
git clone https://github.com/ALaDyn/ramses.git
cd ramses/
git remote add upstream https://bitbucket.org/rteyssie/ramses.git
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

## QGIS 
rm -rf QGIS
git clone https://github.com/physycom/QGIS.git
cd QGIS/
git remote add upstream https://github.com/qgis/QGIS.git
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

## json 
rm -rf json
git clone https://github.com/physycom/json.git
cd json/
git remote add upstream https://github.com/nlohmann/json.git
git fetch upstream
git checkout develop
git merge upstream/develop
git push
cd ..

## jsoncons 
rm -rf jsoncons
git clone https://github.com/physycom/jsoncons.git
cd jsoncons/
git remote add upstream https://github.com/danielaparker/jsoncons.git
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

## Nominatim 
rm -rf Nominatim
git clone https://github.com/physycom/Nominatim.git
cd Nominatim/
git remote add upstream https://github.com/twain47/Nominatim.git
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

## mosquitto 
rm -rf mosquitto
git clone https://github.com/physycom/mosquitto.git
cd mosquitto/
git remote add upstream https://github.com/eclipse/mosquitto.git
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

## geopy 
rm -rf geopy
git clone https://github.com/physycom/geopy.git
cd geopy/
git remote add upstream https://github.com/geopy/geopy.git
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

## pyUblox 
rm -rf pyUblox
git clone https://github.com/physycom/pyUblox.git
cd pyUblox/
git remote add upstream https://github.com/tridge/pyUblox.git
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

## Catch 
rm -rf Catch
git clone https://github.com/physycom/Catch.git
cd Catch/
git remote add upstream https://github.com/philsquared/Catch.git
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

## RTKLIB 
rm -rf RTKLIB
git clone https://github.com/physycom/RTKLIB.git
cd RTKLIB/
git remote add upstream https://github.com/tomojitakasu/RTKLIB.git
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

## community_bash_style_guide
rm -rf community_bash_style_guide
git clone https://github.com/cenit/community_bash_style_guide.git
cd community_bash_style_guide/
git remote add upstream https://github.com/azet/community_bash_style_guide.git
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

## ALaDyn_cenit
rm -rf ALaDyn_cenit
git clone https://github.com/cenit/ALaDyn.git ALaDyn_cenit
cd ALaDyn_cenit/
git remote add upstream https://github.com/ALaDyn/ALaDyn.git
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

## Propaga_cenit
rm -rf Propaga_cenit
git clone https://github.com/cenit/Propaga.git Propaga_cenit
cd Propaga_cenit/
git remote add upstream https://github.com/ALaDyn/Propaga.git
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

## Stats
rm -rf Stats
git clone https://github.com/cenit/Stats.git
cd Stats/
git remote add upstream https://github.com/mjkaufer/Stats.git
git fetch upstream
git checkout master
git merge upstream/master
git push
cd ..

