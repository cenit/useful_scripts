#!/bin/bash

REPO=json
  if [ -d "$REPO" ]; then
    echo $REPO
    cd $REPO/
    git fetch upstream
    git checkout develop
    git merge upstream/develop
    git push
    cd ..
  fi

REPOSITORIES=(Smilei PIConGPU psc fbpic gnuplot-colorbrewer VTKFortran ramses epoch EPOCH_manuals websocketpp crowd-counting curlpp QGIS jsoncons Nominatim mosquitto geopy pyUblox Catch RTKLIB numerical-methods-fortran densityClust voc-dpm Dictionaries)
for REPO in ${REPOSITORIES[*]}
do
  if [ -d "$REPO" ]; then
    echo $REPO
    cd $REPO/
    git fetch upstream
    git checkout master
    git merge upstream/master
    git push
    cd ..
  fi
done

REPOSITORIES=(vcpkg Propaga ALaDyn tools-piccante darknet matconvnet Multitarget-tracker gdl vlfeat Detectron community_bash_style_guide sudoku-detector ProteinPipe Data-Analysis math nocs voc-release4.01 libsvm azure-batch-apps-blender L1--L2---Computation-of-satellite-and-receiver-position)
for REPO in ${REPOSITORIES[*]}
do
  if [ -d "${REPO}_cenit" ]; then
    echo ${REPO}_cenit
    cd ${REPO}_cenit/
    git fetch upstream
    git checkout master
    git merge upstream/master
    git push
    cd ..
  fi
done
