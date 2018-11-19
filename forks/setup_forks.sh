#! /usr/bin/env bash

## Smilei
rm -rf Smilei
git clone https://github.com/ALaDyn/Smilei.git
cd Smilei/
git remote add upstream https://github.com/SmileiPIC/Smilei.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## PIConGPU
rm -rf picongpu
git clone https://github.com/ALaDyn/picongpu.git
cd picongpu/
git remote add upstream https://github.com/ComputationalRadiationPhysics/picongpu.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## psc
rm -rf psc
git clone https://github.com/ALaDyn/psc.git
cd psc/
git remote add upstream https://github.com/germasch/psc.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## fbpic
rm -rf fbpic
git clone https://github.com/ALaDyn/fbpic.git
cd fbpic/
git remote add upstream https://github.com/fbpic/fbpic.git
git checkout dev
git fetch upstream
git merge upstream/dev
git push
cd ..

## gnuplot-colorbrewer
rm -rf gnuplot-colorbrewer
git clone https://github.com/ALaDyn/gnuplot-colorbrewer.git
cd gnuplot-colorbrewer/
git remote add upstream https://github.com/aschn/gnuplot-colorbrewer.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## VTKFortran
rm -rf VTKFortran
git clone https://github.com/ALaDyn/VTKFortran.git
cd VTKFortran/
git remote add upstream https://github.com/szaghi/VTKFortran.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## ramses
rm -rf ramses
git clone https://github.com/ALaDyn/ramses.git
cd ramses/
git remote add upstream https://bitbucket.org/rteyssie/ramses.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## epoch
rm -rf epoch
git clone https://github.com/ALaDyn/epoch.git
cd epoch/
git remote add upstream git@cfsa-pmw.warwick.ac.uk:EPOCH/epoch.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## EPOCH_manuals
rm -rf EPOCH_manuals
git clone https://github.com/ALaDyn/EPOCH_manuals.git
cd EPOCH_manuals/
git remote add upstream git@cfsa-pmw.warwick.ac.uk:EPOCH/EPOCH_manuals.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## ============================

## websocketpp
rm -rf websocketpp
git clone https://github.com/physycom/websocketpp.git
cd websocketpp/
git remote add upstream https://github.com/zaphoyd/websocketpp.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

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

## curlpp
rm -rf curlpp
git clone https://github.com/physycom/curlpp.git
cd curlpp/
git remote add upstream https://github.com/jpbarrette/curlpp.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## QGIS
rm -rf QGIS
git clone https://github.com/physycom/QGIS.git
cd QGIS/
git remote add upstream https://github.com/qgis/QGIS.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## json
rm -rf json
git clone https://github.com/physycom/json.git
cd json/
git remote add upstream https://github.com/nlohmann/json.git
git checkout develop
git fetch upstream
git merge upstream/develop
git push
cd ..

## jsoncons
rm -rf jsoncons
git clone https://github.com/physycom/jsoncons.git
cd jsoncons/
git remote add upstream https://github.com/danielaparker/jsoncons.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## Nominatim
rm -rf Nominatim
git clone https://github.com/physycom/Nominatim.git
cd Nominatim/
git remote add upstream https://github.com/twain47/Nominatim.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## mosquitto
rm -rf mosquitto
git clone https://github.com/physycom/mosquitto.git
cd mosquitto/
git remote add upstream https://github.com/eclipse/mosquitto.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## geopy
rm -rf geopy
git clone https://github.com/physycom/geopy.git
cd geopy/
git remote add upstream https://github.com/geopy/geopy.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## pyUblox
rm -rf pyUblox
git clone https://github.com/physycom/pyUblox.git
cd pyUblox/
git remote add upstream https://github.com/tridge/pyUblox.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## Catch
rm -rf Catch
git clone https://github.com/physycom/Catch.git
cd Catch/
git remote add upstream https://github.com/philsquared/Catch.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## RTKLIB
rm -rf RTKLIB
git clone https://github.com/physycom/RTKLIB.git
cd RTKLIB/
git remote add upstream https://github.com/tomojitakasu/RTKLIB.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## numerical-methods-fortran
rm -rf numerical-methods-fortran
git clone https://github.com/physycom/numerical-methods-fortran.git
cd numerical-methods-fortran/
git remote add upstream https://github.com/planelles20/numerical-methods-fortran.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## densityClust
rm -rf densityClust
git clone https://github.com/physycom/densityClust.git
cd densityClust/
git remote add upstream https://github.com/thomasp85/densityClust.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## voc-dpm
rm -rf voc-dpm
git clone https://github.com/physycom/voc-dpm.git
cd voc-dpm/
git remote add upstream https://github.com/rbgirshick/voc-dpm.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## Dictionaries
rm -rf Dictionaries
git clone https://github.com/physycom/Dictionaries.git
cd Dictionaries/
git remote add upstream https://github.com/titoBouzout/Dictionaries.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## ============================

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
git remote add upstream https://github.com/vlfeat/matconvnet.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## Multitarget-tracker_cenit
rm -rf Multitarget-tracker_cenit
git clone https://github.com/cenit/Multitarget-tracker.git Multitarget-tracker_cenit
cd Multitarget-tracker_cenit/
git remote add upstream https://github.com/Smorodov/Multitarget-tracker.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## gdl_cenit
rm -rf gdl_cenit
git clone https://github.com/cenit/gdl.git gdl_cenit
cd gdl_cenit/
git remote add upstream https://github.com/gnudatalanguage/gdl.git
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

## Detectron_cenit
rm -rf Detectron_cenit
git clone https://github.com/cenit/Detectron.git Detectron_cenit
cd Detectron_cenit/
git remote add upstream https://github.com/facebookresearch/Detectron.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## community_bash_style_guide_cenit
rm -rf community_bash_style_guide_cenit
git clone https://github.com/cenit/community_bash_style_guide.git community_bash_style_guide_cenit
cd community_bash_style_guide_cenit/
git remote add upstream https://github.com/azet/community_bash_style_guide.git
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

## azure-batch-apps-blender_cenit
rm -rf azure-batch-apps-blender_cenit
git clone https://github.com/cenit/azure-batch-apps-blender.git azure-batch-apps-blender_cenit
cd azure-batch-apps-blender_cenit/
git remote add upstream https://github.com/Azure/azure-batch-apps-blender.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..

## L1--L2---Computation-of-satellite-and-receiver-position_cenit
rm -rf L1--L2---Computation-of-satellite-and-receiver-position_cenit
git clone https://github.com/cenit/L1--L2---Computation-of-satellite-and-receiver-position L1--L2---Computation-of-satellite-and-receiver-position_cenit
cd L1--L2---Computation-of-satellite-and-receiver-position_cenit/
git remote add upstream https://github.com/kevinsan1/L1--L2---Computation-of-satellite-and-receiver-position.git
git checkout master
git fetch upstream
git merge upstream/master
git push
cd ..
