#! /usr/bin/env bash

REPO=json
  if [ -d "$REPO" ]; then
    echo $REPO
    cd $REPO/
    git checkout develop
    git fetch upstream
    git merge upstream/develop
    git push
    cd ..
  fi

REPO=fbpic
  if [ -d "$REPO" ]; then
    echo $REPO
    cd $REPO/
    git checkout dev
    git fetch upstream
    git merge upstream/dev
    git push
    cd ..
  fi

REPOSITORIES=(Smilei PIConGPU psc gnuplot-colorbrewer VTKFortran ramses epoch EPOCH_manuals websocketpp crowd-counting curlpp QGIS jsoncons Nominatim mosquitto geopy pyUblox Catch RTKLIB numerical-methods-fortran densityClust voc-dpm Dictionaries)
for REPO in ${REPOSITORIES[*]}
do
  if [ -d "$REPO" ]; then
    echo $REPO
    cd $REPO/
    git checkout master
    git fetch upstream
    git merge upstream/master
    git push
    cd ..
  fi
done

REPO=math
  if [ -d "$REPO_cenit" ]; then
    echo $REPO_cenit
    cd $REPO_cenit/
    git checkout develop
    git fetch upstream
    git merge upstream/develop
    git push
    cd ..
  fi

REPOSITORIES=(vcpkg Propaga ALaDyn tools-piccante matconvnet Multitarget-tracker gdl vlfeat Detectron community_bash_style_guide sudoku-detector ProteinPipe Data-Analysis nocs voc-release4.01 libsvm azure-batch-apps-blender L1--L2---Computation-of-satellite-and-receiver-position cmake)
for REPO in ${REPOSITORIES[*]}
do
  if [ -d "${REPO}_cenit" ]; then
    echo ${REPO}_cenit
    cd ${REPO}_cenit/
    git checkout master
    git fetch upstream
    git merge upstream/master
    git push
    cd ..
  fi
done

REPOSITORIES=(darknet)
for REPO in ${REPOSITORIES[*]}
do
  if [ -d "${REPO}_cenit" ]; then
    echo ${REPO}_cenit
    cd ${REPO}_cenit/
    git checkout master
    git fetch upstream_pj
    git merge upstream_pj/master
    git push
    git checkout dev/alexey/master
    git fetch upstream_ax
    git merge upstream_ax/master
    git push
    git checkout master
    cd ..
  fi
done
