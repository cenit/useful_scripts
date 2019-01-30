#! /usr/bin/env bash

# CUSTOMIZED FORKS (not mirrors, we keep updated only the main branch from upstream!)

## cmake_cenit
REPO=cmake_cenit
rm -rf "${REPO}"
git clone https://gitlab.kitware.com/cenit/cmake "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote add upstream https://gitlab.kitware.com/cmake/cmake
    git checkout master
  git fetch upstream
    git merge upstream/master
  git push
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## crowd-counting
REPO=crowd-counting
rm -rf "${REPO}"
git clone https://github.com/physycom/crowd-counting.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote add upstream https://github.com/hankong/crowd-counting.git
  git checkout master
  git fetch upstream
  git merge upstream/master
  git push
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## sudoku-detector_cenit
REPO=sudoku-detector_cenit
rm -rf "${REPO}"
git clone https://github.com/cenit/sudoku-detector.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote add upstream https://github.com/aishack/sudoku-detector.git
  git checkout master
  git fetch upstream
  git merge upstream/master
  git push
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## ProteinPipe_cenit
REPO=ProteinPipe_cenit
rm -rf "${REPO}"
git clone https://github.com/cenit/ProteinPipe.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote add upstream https://github.com/Nico-Curti/ProteinPipe.git
  git checkout master
  git fetch upstream
  git merge upstream/master
  git push
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## Data-Analysis_cenit
REPO=Data-Analysis_cenit
rm -rf "${REPO}"
git clone https://github.com/cenit/Data-Analysis.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote add upstream https://github.com/Nico-Curti/Data-Analysis.git
  git checkout master
  git fetch upstream
  git merge upstream/master
  git push
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## nocs_cenit
REPO=nocs_cenit
rm -rf "${REPO}"
git clone https://github.com/cenit/nocs.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote add upstream https://github.com/matteomonti/nocs.git
  git checkout master
  git fetch upstream
  git merge upstream/master
  git push
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## voc-release4.01_cenit
REPO=voc-release4.01_cenit
rm -rf "${REPO}"
git clone https://github.com/cenit/voc-release4.01.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote add upstream https://github.com/rbgirshick/voc-release4.01.git
  git checkout master
  git fetch upstream
  git merge upstream/master
  git push
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## libsvm_cenit
REPO=libsvm_cenit
rm -rf "${REPO}"
git clone https://github.com/cenit/libsvm.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote add upstream https://github.com/cjlin1/libsvm.git
  git checkout master
  git fetch upstream
  git merge upstream/master
  git push
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## vlfeat_cenit
REPO=vlfeat_cenit
rm -rf "${REPO}"
git clone https://github.com/cenit/vlfeat.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote add upstream https://github.com/vlfeat/vlfeat.git
  git checkout master
  git fetch upstream
  git merge upstream/master
  git push
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## vcpkg_cenit
REPO=vcpkg
rm -rf "${REPO}"
git clone https://github.com/cenit/vcpkg.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote add upstream https://github.com/Microsoft/vcpkg.git
  git checkout master
  git fetch upstream
  git merge upstream/master
  git push
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## Propaga_cenit
REPO=Propaga_cenit
rm -rf "${REPO}"
git clone https://github.com/cenit/Propaga.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote add upstream https://github.com/ALaDyn/Propaga.git
  git checkout master
  git fetch upstream
  git merge upstream/master
  git push
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## ALaDyn_cenit
REPO=ALaDyn_cenit
rm -rf "${REPO}"
git clone https://github.com/cenit/ALaDyn.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote add upstream https://github.com/ALaDyn/ALaDyn.git
  git checkout master
  git fetch upstream
  git merge upstream/master
  git push
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## tools-piccante_cenit
REPO=tools-piccante_cenit
rm -rf "${REPO}"
git clone https://github.com/cenit/tools-piccante.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote add upstream https://github.com/ALaDyn/tools-piccante.git
  git checkout master
  git fetch upstream
  git merge upstream/master
  git push
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## darknet_cenit
REPO=darknet_cenit
rm -rf "${REPO}"
git clone https://github.com/cenit/darknet.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote add upstream_pj https://github.com/pjreddie/darknet.git
  git checkout master
  git fetch upstream_pj
  git merge upstream_pj/master
  git push
  git remote add upstream_ax https://github.com/AlexeyAB/darknet.git
  git checkout dev/alexey/master
  git fetch upstream_ax
  git merge upstream_ax/master
  git push
  git checkout master
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## matconvnet_cenit
REPO=matconvnet_cenit
rm -rf "${REPO}"
git clone https://github.com/cenit/matconvnet.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote add upstream https://github.com/vlfeat/matconvnet.git
  git checkout master
  git fetch upstream
  git merge upstream/master
  git push
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## math_cenit
REPO=boost_math_cenit
rm -rf "${REPO}"
git clone https://github.com/cenit/math.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote add upstream https://github.com/boostorg/math.git
  git checkout develop
  git fetch upstream
  git merge upstream/develop
  git push
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

# MIRRORED FORKS (we keep synced all the branches from upstream!)
# NOTE!! any custom commit will be overwritten in the next sync due to force push!
# Remove any fork you want to customize from the following list!

## Smilei
REPO=Smilei
rm -rf "${REPO}"
git clone --mirror https://github.com/SmileiPIC/Smilei.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/ALaDyn/Smilei.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## PIConGPU
REPO=picongpu
rm -rf "${REPO}"
git clone --mirror https://github.com/ComputationalRadiationPhysics/picongpu.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/ALaDyn/picongpu.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## psc
REPO=psc
rm -rf "${REPO}"
git clone --mirror https://github.com/germasch/psc.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/ALaDyn/psc.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## fbpic
REPO=fbpic
rm -rf "${REPO}"
git clone --mirror https://github.com/fbpic/fbpic.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/ALaDyn/fbpic.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## gnuplot-colorbrewer
REPO=gnuplot-colorbrewer
rm -rf "${REPO}"
git clone --mirror https://github.com/aschn/gnuplot-colorbrewer.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/ALaDyn/gnuplot-colorbrewer.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## VTKFortran
REPO=VTKFortran
rm -rf "${REPO}"
git clone --mirror https://github.com/szaghi/VTKFortran.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/ALaDyn/VTKFortran.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## ramses
REPO=ramses
rm -rf "${REPO}"
git clone --mirror https://bitbucket.org/rteyssie/ramses.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/ALaDyn/ramses.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## epoch
REPO=epoch
rm -rf "${REPO}"
git clone --mirror git@cfsa-pmw.warwick.ac.uk:EPOCH/epoch.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/ALaDyn/epoch.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## EPOCH_manuals
REPO=EPOCH_manuals
rm -rf "${REPO}"
git clone --mirror git@cfsa-pmw.warwick.ac.uk:EPOCH/EPOCH_manuals.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/ALaDyn/EPOCH_manuals.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## websocketpp
REPO=websocketpp
rm -rf "${REPO}"
git clone --mirror https://github.com/zaphoyd/websocketpp.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/physycom/websocketpp.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## curlpp
REPO=curlpp
rm -rf "${REPO}"
git clone --mirror https://github.com/jpbarrette/curlpp.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/physycom/curlpp.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## QGIS
REPO=QGIS
rm -rf "${REPO}"
git clone --mirror https://github.com/qgis/QGIS.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/physycom/QGIS.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## json
REPO=json
rm -rf "${REPO}"
git clone --mirror https://github.com/nlohmann/json.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/physycom/json.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## jsoncons
REPO=jsoncons
rm -rf "${REPO}"
git clone --mirror https://github.com/danielaparker/jsoncons.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/physycom/jsoncons.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## Nominatim
REPO=Nominatim
rm -rf "${REPO}"
git clone --mirror https://github.com/twain47/Nominatim.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/physycom/Nominatim.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## mosquitto
REPO=mosquitto
rm -rf "${REPO}"
git clone --mirror https://github.com/eclipse/mosquitto.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/physycom/mosquitto.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## geopy
REPO=geopy
rm -rf "${REPO}"
git clone --mirror https://github.com/geopy/geopy.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/physycom/geopy.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## pyUblox
REPO=pyUblox
rm -rf "${REPO}"
git clone --mirror https://github.com/tridge/pyUblox.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/physycom/pyUblox.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## Catch
REPO=Catch
rm -rf "${REPO}"
git clone --mirror https://github.com/philsquared/Catch.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/physycom/Catch.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## RTKLIB
REPO=RTKLIB
rm -rf "${REPO}"
git clone --mirror https://github.com/tomojitakasu/RTKLIB.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/physycom/RTKLIB.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## numerical-methods-fortran
REPO=numerical-methods-fortran
rm -rf "${REPO}"
git clone --mirror https://github.com/planelles20/numerical-methods-fortran.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/physycom/numerical-methods-fortran.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## densityClust
REPO=densityClust
rm -rf "${REPO}"
git clone --mirror https://github.com/thomasp85/densityClust.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/physycom/densityClust.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## voc-dpm
REPO=voc-dpm
rm -rf "${REPO}"
git clone --mirror https://github.com/rbgirshick/voc-dpm.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/physycom/voc-dpm.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## Dictionaries
REPO=Dictionaries
rm -rf "${REPO}"
git clone --mirror https://github.com/titoBouzout/Dictionaries.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/physycom/Dictionaries.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## Multitarget-tracker_cenit
REPO=Multitarget-tracker_cenit
rm -rf "${REPO}"
git clone --mirror https://github.com/Smorodov/Multitarget-tracker.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/cenit/Multitarget-tracker.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## gdl_cenit
REPO=gdl_cenit
rm -rf "${REPO}"
git clone --mirror https://github.com/gnudatalanguage/gdl.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/cenit/gdl.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## Detectron_cenit
REPO=Detectron_cenit
rm -rf "${REPO}"
git clone --mirror https://github.com/facebookresearch/Detectron.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/cenit/Detectron.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## community_bash_style_guide_cenit
REPO=community_bash_style_guide_cenit
rm -rf "${REPO}"
git clone --mirror https://github.com/azet/community_bash_style_guide.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/cenit/community_bash_style_guide.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## azure-batch-apps-blender_cenit
REPO=azure-batch-apps-blender_cenit
rm -rf "${REPO}"
git clone --mirror https://github.com/Azure/azure-batch-apps-blender.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/cenit/azure-batch-apps-blender.git
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi

## L1--L2---Computation-of-satellite-and-receiver-position_cenit
REPO=L1--L2---Computation-of-satellite-and-receiver-position_cenit
rm -rf "${REPO}"
git clone --mirror https://github.com/kevinsan1/L1--L2---Computation-of-satellite-and-receiver-position.git "${REPO}"
if [ -d "${REPO}" ]; then  #we add this check so that if cloning fails the following steps are not messing around!
  cd "${REPO}"/
  git remote set-url --push origin https://github.com/cenit/L1--L2---Computation-of-satellite-and-receiver-position
  git fetch -p origin
  git push --mirror
  cd ..
else
  echo "Failed cloning --- $REPO"
fi
