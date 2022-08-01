#! /usr/bin/env bash

REPOSITORIES_CLONED=(Smilei fbpic PIConGPU psc gnuplot-colorbrewer VTKFortran ramses epoch EPOCH_manuals websocketpp curlpp jsoncons Nominatim mosquitto geopy pyUblox Catch RTKLIB numerical-methods-fortran densityClust voc-dpm Dictionaries grub openeb coulomb_oscillators elmerfem PoissonRecon doxygen meep count Urti-2d)
for REPO in ${REPOSITORIES_CLONED[*]}
do
  if [ -d "${REPO}" ]; then
    echo "Updating --- ${REPO}"
    cd "${REPO}"/ || exit
    git fetch -p origin
    git push --mirror
    cd ..
  else
    echo "Unable to find --- $REPO --- skipping"
  fi
done

REPOSITORIES_CLONED_CENIT=(Multitarget-tracker gdl Detectron community_bash_style_guide azure-batch-apps-blender L1--L2---Computation-of-satellite-and-receiver-position)
for REPO in ${REPOSITORIES_CLONED_CENIT[*]}
do
  if [ -d "${REPO}_cenit" ]; then
    echo "Updating --- ${REPO}_cenit"
    cd "${REPO}_cenit"/ || exit
    git fetch -p origin
    git push --mirror
    cd ..
  else
    echo "Unable to find --- ${REPO}_cenit --- skipping"
  fi
done

REPOSITORIES_CUSTOMIZED=boost_math
for REPO in ${REPOSITORIES_CUSTOMIZED[*]}
do
  if [ -d "${REPO}_cenit" ]; then
    echo "Updating --- ${REPO}_cenit"
    cd "${REPO}_cenit"/ || exit
    git checkout develop
    git fetch upstream
    git merge upstream/develop
    git push
    cd ..
  else
    echo "Unable to find --- ${REPO}_cenit --- skipping"
  fi
done

REPOSITORIES_CUSTOMIZED=(vcpkg bin2header BBAPI Propaga ALaDyn tools-piccante matconvnet vlfeat sudoku-detector voc-release4.01 libsvm Data-Analysis nocs ProteinPipe crowd-counting cmake Blob.js openMVG dotfiles elmerfem Aravis-OpenCV-Wrapper Yolo_mark Microsoft-MPI)
for REPO in ${REPOSITORIES_CUSTOMIZED[*]}
do
  if [ -d "${REPO}_cenit" ]; then
    echo "Updating --- ${REPO}_cenit"
    cd "${REPO}_cenit"/ || exit
    git checkout master
    git fetch upstream
    git merge upstream/master
    git push
    cd ..
  else
    echo "Unable to find --- ${REPO}_cenit --- skipping"
  fi
done

REPOSITORIES_CUSTOMIZED=(vcpkg-tool)
for REPO in ${REPOSITORIES_CUSTOMIZED[*]}
do
  if [ -d "${REPO}_cenit" ]; then
    echo "Updating --- ${REPO}_cenit"
    cd "${REPO}_cenit"/ || exit
    git checkout main
    git fetch upstream
    git merge upstream/main
    git push
    cd ..
  else
    echo "Unable to find --- ${REPO}_cenit --- skipping"
  fi
done

REPOSITORIES_CUSTOMIZED=(darknet)
for REPO in ${REPOSITORIES_CUSTOMIZED[*]}
do
  if [ -d "${REPO}_cenit" ]; then
    echo "Updating --- ${REPO}_cenit"
    cd "${REPO}_cenit"/ || exit
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
  else
    echo "Unable to find --- ${REPO}_cenit --- skipping"
  fi
done
