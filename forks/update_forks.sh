#! /usr/bin/env bash

REPOSITORIES_CLONED=(Smilei fbpic PIConGPU psc gnuplot-colorbrewer VTKFortran ramses epoch EPOCH_manuals websocketpp curlpp QGIS jsoncons Nominatim mosquitto geopy pyUblox Catch RTKLIB numerical-methods-fortran densityClust voc-dpm Dictionaries)
for REPO in ${REPOSITORIES_CLONED[*]}
do
  if [ -d "$REPO" ]; then
    echo $REPO
    cd $REPO/
    git fetch -p origin
    git push --mirror
    cd ..
  fi
done

REPOSITORIES_CLONED_CENIT=(Multitarget-tracker gdl Detectron community_bash_style_guide azure-batch-apps-blender L1--L2---Computation-of-satellite-and-receiver-position)
for REPO in ${REPOSITORIES_CLONED_CENIT[*]}
do
  if [ -d "$REPO_cenit" ]; then
    echo $REPO
    cd $REPO_cenit/
    git fetch -p origin
    git push --mirror
    cd ..
  fi
done

REPOSITORIES_CUSTOMIZED=math
for REPO in ${REPOSITORIES_CUSTOMIZED[*]}
do
  if [ -d "$REPO_cenit" ]; then
    echo $REPO_cenit
    cd $REPO_cenit/
    git checkout develop
    git fetch upstream
    git merge upstream/develop
    git push
    cd ..
  fi
done

REPOSITORIES_CUSTOMIZED=(vcpkg Propaga ALaDyn tools-piccante matconvnet vlfeat sudoku-detector voc-release4.01 libsvm Data-Analysis nocs ProteinPipe crowd-counting)
for REPO in ${REPOSITORIES_CUSTOMIZED[*]}
do
  if [ -d "$REPO_cenit" ]; then
    echo $REPO_cenit
    cd $REPO_cenit/
    git checkout master
    git fetch upstream
    git merge upstream/master
    git push
    cd ..
  fi
done

REPOSITORIES_CUSTOMIZED=(darknet)
for REPO in ${REPOSITORIES_CUSTOMIZED[*]}
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
