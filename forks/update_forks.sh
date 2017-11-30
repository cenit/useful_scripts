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

REPOSITORIES=(Smilei PIConGPU psc fbpic gnuplot-colorbrewer VTKFortran ramses epoch EPOCH_manuals QGIS jsoncons Nominatim mosquitto geopy pyUblox Catch RTKLIB numerical-methods-fortran densityClust tclap community_bash_style_guide)
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
