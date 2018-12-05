#! /usr/bin/env bash

# CUSTOMIZED FORKS (not mirrors, we keep updated only the main branch from upstream!)

## crowd-counting
rm -rf crowd-counting
git clone https://github.com/physycom/crowd-counting.git
cd crowd-counting/
git remote add upstream https://github.com/hankong/crowd-counting.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## sudoku-detector_cenit
rm -rf sudoku-detector_cenit
git clone https://github.com/cenit/sudoku-detector.git sudoku-detector_cenit
cd sudoku-detector_cenit/
git remote add upstream https://github.com/aishack/sudoku-detector.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## ProteinPipe_cenit
rm -rf ProteinPipe_cenit
git clone https://github.com/cenit/ProteinPipe.git ProteinPipe_cenit
cd ProteinPipe_cenit/
git remote add upstream https://github.com/Nico-Curti/ProteinPipe.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## Data-Analysis_cenit
rm -rf Data-Analysis_cenit
git clone https://github.com/cenit/Data-Analysis.git Data-Analysis_cenit
cd Data-Analysis_cenit/
git remote add upstream https://github.com/Nico-Curti/Data-Analysis.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## nocs_cenit
rm -rf nocs_cenit
git clone https://github.com/cenit/nocs.git nocs_cenit
cd nocs_cenit/
git remote add upstream https://github.com/matteomonti/nocs.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## voc-release4.01_cenit
rm -rf voc-release4.01_cenit
git clone https://github.com/cenit/voc-release4.01.git voc-release4.01_cenit
cd voc-release4.01_cenit/
git remote add upstream https://github.com/rbgirshick/voc-release4.01.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## libsvm_cenit
rm -rf libsvm_cenit
git clone https://github.com/cenit/libsvm.git libsvm_cenit
cd libsvm_cenit/
git remote add upstream https://github.com/cjlin1/libsvm.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## vlfeat_cenit
rm -rf vlfeat_cenit
git clone https://github.com/cenit/vlfeat.git vlfeat_cenit
cd vlfeat_cenit/
git remote add upstream https://github.com/vlfeat/vlfeat.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## vcpkg_cenit
rm -rf vcpkg
git clone https://github.com/cenit/vcpkg.git vcpkg_cenit
cd vcpkg_cenit/
git remote add upstream https://github.com/Microsoft/vcpkg.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## Propaga_cenit
rm -rf Propaga_cenit
git clone https://github.com/cenit/Propaga.git Propaga_cenit
cd Propaga_cenit/
git remote add upstream https://github.com/ALaDyn/Propaga.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## ALaDyn_cenit
rm -rf ALaDyn_cenit
git clone https://github.com/cenit/ALaDyn.git ALaDyn_cenit
cd ALaDyn_cenit/
git remote add upstream https://github.com/ALaDyn/ALaDyn.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## tools-piccante_cenit
rm -rf tools-piccante_cenit
git clone https://github.com/cenit/tools-piccante.git tools-piccante_cenit
cd tools-piccante_cenit/
git remote add upstream https://github.com/ALaDyn/tools-piccante.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## darknet_cenit
rm -rf darknet_cenit
git clone https://github.com/cenit/darknet.git darknet_cenit
cd darknet_cenit/
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

## matconvnet_cenit
rm -rf matconvnet_cenit
git clone https://github.com/cenit/matconvnet.git matconvnet_cenit
cd matconvnet_cenit/
git clone --mirror https://github.com/vlfeat/matconvnet.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## math_cenit
rm -rf math_cenit
git clone https://github.com/cenit/math.git math_cenit
cd math_cenit/
git remote add upstream https://github.com/boostorg/math.git
git checkout develop
git fetch upstream
git merge upstream/develop
git push
cd ..

# MIRRORED FORKS (we keep synced all the branches from upstream!)
# NOTE!! any custom commit will be overwritten in the next sync due to force push!
# Remove any fork you want to customize from the following list!

## Smilei
rm -rf Smilei
git clone --mirror https://github.com/SmileiPIC/Smilei.git Smilei
cd Smilei/
git remote set-url --push origin https://github.com/ALaDyn/Smilei.git
git fetch -p origin
git push --mirror
cd ..

## PIConGPU
rm -rf picongpu
git clone --mirror https://github.com/ComputationalRadiationPhysics/picongpu.git picongpu
cd picongpu/
git remote set-url --push origin https://github.com/ALaDyn/picongpu.git
git fetch -p origin
git push --mirror
cd ..

## psc
rm -rf psc
git clone --mirror https://github.com/germasch/psc.git psc
cd psc/
git remote set-url --push origin https://github.com/ALaDyn/psc.git
git fetch -p origin
git push --mirror
cd ..

## fbpic
rm -rf fbpic
git clone --mirror https://github.com/fbpic/fbpic.git fbpic
cd fbpic/
git remote set-url --push origin https://github.com/ALaDyn/fbpic.git
git fetch -p origin
git push --mirror
cd ..

## gnuplot-colorbrewer
rm -rf gnuplot-colorbrewer
git clone --mirror https://github.com/aschn/.git gnuplot-colorbrewer
cd gnuplot-colorbrewer/
git remote set-url --push origin https://github.com/ALaDyn/gnuplot-colorbrewer.git
git fetch -p origin
git push --mirror
cd ..

## VTKFortran
rm -rf VTKFortran
git clone --mirror https://github.com/szaghi/VTKFortran.git VTKFortran
cd VTKFortran/
git remote set-url --push origin https://github.com/ALaDyn/VTKFortran.git
git fetch -p origin
git push --mirror
cd ..

## ramses
rm -rf ramses
git clone --mirror https://bitbucket.org/rteyssie/ramses.git ramses
cd ramses/
git remote set-url --push origin https://github.com/ALaDyn/ramses.git
git fetch -p origin
git push --mirror
cd ..

## epoch
rm -rf epoch
git clone --mirror git@cfsa-pmw.warwick.ac.uk:EPOCH/epoch.git epoch
cd epoch/
git remote set-url --push origin https://github.com/ALaDyn/epoch.git
git fetch -p origin
git push --mirror
cd ..

## EPOCH_manuals
rm -rf EPOCH_manuals
git clone --mirror git@cfsa-pmw.warwick.ac.uk:EPOCH/EPOCH_manuals.git EPOCH_manuals
cd EPOCH_manuals/
git remote set-url --push origin https://github.com/ALaDyn/EPOCH_manuals.git
git fetch -p origin
git push --mirror
cd ..


## websocketpp
rm -rf websocketpp
git clone --mirror https://github.com/zaphoyd/websocketpp.git websocketpp
cd websocketpp/
git remote set-url --push origin https://github.com/physycom/websocketpp.git
git fetch -p origin
git push --mirror
cd ..

## curlpp
rm -rf curlpp
git clone --mirror https://github.com/jpbarrette/curlpp.git curlpp
cd curlpp/
git remote set-url --push origin https://github.com/physycom/curlpp.git
git fetch -p origin
git push --mirror
cd ..

## QGIS
rm -rf QGIS
git clone --mirror https://github.com/qgis/QGIS.git QGIS
cd QGIS/
git remote set-url --push origin https://github.com/physycom/QGIS.git
git fetch -p origin
git push --mirror
cd ..

## json
rm -rf json
git clone --mirror https://github.com/nlohmann/json.git json
cd json/
git remote set-url --push origin https://github.com/physycom/json.git
git fetch -p origin
git push --mirror
cd ..

## jsoncons
rm -rf jsoncons
git clone --mirror https://github.com/danielaparker/jsoncons.git jsoncons
cd jsoncons/
git remote set-url --push origin https://github.com/physycom/jsoncons.git
git fetch -p origin
git push --mirror
cd ..

## Nominatim
rm -rf Nominatim
git clone --mirror https://github.com/twain47/Nominatim.git Nominatim
cd Nominatim/
git remote set-url --push origin https://github.com/physycom/Nominatim.git
git fetch -p origin
git push --mirror
cd ..

## mosquitto
rm -rf mosquitto
git clone --mirror https://github.com/eclipse/mosquitto.git mosquitto
cd mosquitto/
git remote set-url --push origin https://github.com/physycom/mosquitto.git
git fetch -p origin
git push --mirror
cd ..

## geopy
rm -rf geopy
git clone --mirror https://github.com/geopy/geopy.git geopy
cd geopy/
git remote set-url --push origin https://github.com/physycom/geopy.git
git fetch -p origin
git push --mirror
cd ..

## pyUblox
rm -rf pyUblox
git clone --mirror https://github.com/tridge/pyUblox.git pyUblox
cd pyUblox/
git remote set-url --push origin https://github.com/physycom/pyUblox.git
git fetch -p origin
git push --mirror
cd ..

## Catch
rm -rf Catch
git clone --mirror https://github.com/philsquared/Catch.git Catch
cd Catch/
git remote set-url --push origin https://github.com/physycom/Catch.git
git fetch -p origin
git push --mirror
cd ..

## RTKLIB
rm -rf RTKLIB
git clone --mirror https://github.com/tomojitakasu/RTKLIB.git RTKLIB
cd RTKLIB/
git remote set-url --push origin https://github.com/physycom/RTKLIB.git
git fetch -p origin
git push --mirror
cd ..

## numerical-methods-fortran
rm -rf numerical-methods-fortran
git clone --mirror https://github.com/planelles20/numerical-methods-fortran.git numerical-methods-fortran
cd numerical-methods-fortran/
git remote set-url --push origin https://github.com/physycom/numerical-methods-fortran.git
git fetch -p origin
git push --mirror
cd ..

## densityClust
rm -rf densityClust
git clone --mirror https://github.com/thomasp85/densityClust.git densityClust
cd densityClust/
git remote set-url --push origin https://github.com/physycom/densityClust.git
git fetch -p origin
git push --mirror
cd ..

## voc-dpm
rm -rf voc-dpm
git clone --mirror https://github.com/rbgirshick/voc-dpm.git voc-dpm
cd voc-dpm/
git remote set-url --push origin https://github.com/physycom/voc-dpm.git
git fetch -p origin
git push --mirror
cd ..

## Dictionaries
rm -rf Dictionaries
git clone --mirror https://github.com/titoBouzout/Dictionaries.git Dictionaries
cd Dictionaries/
git remote set-url --push origin https://github.com/physycom/Dictionaries.git
git fetch -p origin
git push --mirror
cd ..

## Multitarget-tracker_cenit
rm -rf Multitarget-tracker_cenit
git clone --mirror https://github.com/Smorodov/Multitarget-tracker.git Multitarget-tracker_cenit
cd Multitarget-tracker_cenit/
git remote set-url --push origin https://github.com/cenit/Multitarget-tracker.git
git fetch -p origin
git push --mirror
cd ..

## gdl_cenit
rm -rf gdl_cenit
git clone --mirror https://github.com/gnudatalanguage/gdl.git gdl_cenit
cd gdl_cenit/
git remote set-url --push origin https://github.com/cenit/gdl.git
git fetch -p origin
git push --mirror
cd ..

## Detectron_cenit
rm -rf Detectron_cenit
git clone --mirror https://github.com/facebookresearch/Detectron.git Detectron_cenit
cd Detectron_cenit/
git remote set-url --push origin https://github.com/cenit/Detectron.git
git fetch -p origin
git push --mirror
cd ..

## community_bash_style_guide_cenit
rm -rf community_bash_style_guide_cenit
git clone --mirror https://github.com/azet/community_bash_style_guide.git community_bash_style_guide_cenit
cd community_bash_style_guide_cenit/
git remote set-url --push origin https://github.com/cenit/community_bash_style_guide.git
git fetch -p origin
git push --mirror
cd ..

## azure-batch-apps-blender_cenit
rm -rf azure-batch-apps-blender_cenit
git clone --mirror https://github.com/Azure/azure-batch-apps-blender.git azure-batch-apps-blender_cenit
cd azure-batch-apps-blender_cenit/
git remote set-url --push origin https://github.com/cenit/azure-batch-apps-blender.git
git fetch -p origin
git push --mirror
cd ..

## L1--L2---Computation-of-satellite-and-receiver-position_cenit
rm -rf L1--L2---Computation-of-satellite-and-receiver-position_cenit
git clone --mirror https://github.com/kevinsan1/L1--L2---Computation-of-satellite-and-receiver-position.git L1--L2---Computation-of-satellite-and-receiver-position_cenit
cd L1--L2---Computation-of-satellite-and-receiver-position_cenit/
git remote set-url --push origin https://github.com/cenit/L1--L2---Computation-of-satellite-and-receiver-position
git fetch -p origin
git push --mirror
cd ..
