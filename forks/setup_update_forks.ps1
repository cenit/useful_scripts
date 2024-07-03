#!/usr/bin/env pwsh

param(
    [string]$onlyThisRepo = ""
)

$version = "1.2.0"
Write-Host "Running setup_update_forks.ps1 version $version" -ForegroundColor Green

$repositoriesCustomized = @(
    @{
        'name' = 'cmake_cenit'
        'url' = 'https://gitlab.kitware.com/cenit/cmake'
        'upstream' = 'https://gitlab.kitware.com/cmake/cmake.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'count'
        'url' = 'https://github.com/cenit/count'
        'upstream' = 'https://github.com/dimroc/count.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'crowd-counting'
        'url' = 'https://github.com/physycom/crowd-counting.git'
        'upstream' = 'https://github.com/hankong/crowd-counting.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'sudoku-detector_cenit'
        'url' = 'https://github.com/cenit/sudoku-detector.git'
        'upstream' = 'https://github.com/aishack/sudoku-detector.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'ProteinPipe_cenit'
        'url' = 'https://github.com/cenit/ProteinPipe.git'
        'upstream' = 'https://github.com/Nico-Curti/ProteinPipe.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'Data-Analysis_cenit'
        'url' = 'https://github.com/cenit/Data-Analysis.git'
        'upstream' = 'https://github.com/Nico-Curti/Data-Analysis.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'nocs_cenit'
        'url' = 'https://github.com/cenit/nocs.git'
        'upstream' = 'https://github.com/matteomonti/nocs.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'meep_cenit'
        'url' = 'https://github.com/cenit/meep.git'
        'upstream' = 'https://github.com/NanoComp/meep.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'voc-release4.01_cenit'
        'url' = 'https://github.com/cenit/voc-release4.01.git'
        'upstream' = 'https://github.com/rbgirshick/voc-release4.01.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'libsvm_cenit'
        'url' = 'https://github.com/cenit/libsvm.git'
        'upstream' = 'https://github.com/cjlin1/libsvm.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'vlfeat_cenit'
        'url' = 'https://github.com/cenit/vlfeat.git'
        'upstream' = 'https://github.com/vlfeat/vlfeat.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'vcpkg_cenit'
        'url' = 'https://github.com/cenit/vcpkg.git'
        'upstream' = 'https://github.com/microsoft/vcpkg.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'Yolo_mark'
        'url' = 'https://github.com/cenit/Yolo_mark.git'
        'upstream' = 'https://github.com/AlexeyAB/Yolo_mark.git'
        'local_branch' = 'main'
        'upstream_branch' = 'main'
        'skip' = $false
    },
    @{
        'name' = 'vcpkg-tool_cenit'
        'url' = 'https://github.com/cenit/vcpkg-tool.git'
        'upstream' = 'https://github.com/microsoft/vcpkg-tool.git'
        'local_branch' = 'main'
        'upstream_branch' = 'main'
        'skip' = $false
    },
    @{
        'name' = 'FastIMU_cenit'
        'url' = 'https://github.com/cenit/FastIMU.git'
        'upstream' = 'https://github.com/LiquidCGS/FastIMU.git'
        'local_branch' = 'main'
        'upstream_branch' = 'main'
        'skip' = $false
    },
    @{
        'name' = 'RTDE_Python_Client_Library'
        'url' = 'https://github.com/cenit/RTDE_Python_Client_Library.git'
        'upstream' = 'https://github.com/UniversalRobots/RTDE_Python_Client_Library.git'
        'local_branch' = 'main'
        'upstream_branch' = 'main'
        'skip' = $false
    },
    @{
        'name' = 'MPU6x00'
        'url' = 'https://github.com/cenit/MPU6x00.git'
        'upstream' = 'https://github.com/Reefwing-Software/MPU6x00.git'
        'local_branch' = 'main'
        'upstream_branch' = 'main'
        'skip' = $false
    },
    @{
        'name' = 'llama-gpt_cenit'
        'url' = 'https://github.com/cenit/llama-gpt.git'
        'upstream' = 'https://github.com/getumbrel/llama-gpt.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'llm.c_cenit'
        'url' = 'https://github.com/cenit/llm.c.git'
        'upstream' = 'https://github.com/karpathy/llm.c.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'llama2.c_cenit'
        'url' = 'https://github.com/cenit/llama2.c.git'
        'upstream' = 'https://github.com/karpathy/llama2.c.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'MixedReality-HolographicRemoting-Samples'
        'url' = 'https://github.com/cenit/MixedReality-HolographicRemoting-Samples.git'
        'upstream' = 'https://github.com/microsoft/MixedReality-HolographicRemoting-Samples.git'
        'local_branch' = 'main'
        'upstream_branch' = 'main'
        'skip' = $false
    },
    @{
        'name' = 'Propaga_cenit'
        'url' = 'https://github.com/cenit/Propaga.git'
        'upstream' = 'https://github.com/ALaDyn/Propaga.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'ALaDyn_cenit'
        'url' = 'https://github.com/cenit/ALaDyn.git'
        'upstream' = 'https://github.com/ALaDyn/ALaDyn.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'tools-piccante_cenit'
        'url' = 'https://github.com/cenit/tools-piccante.git'
        'upstream' = 'https://github.com/ALaDyn/tools-piccante.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'matconvnet_cenit'
        'url' = 'https://github.com/cenit/matconvnet.git'
        'upstream' = 'https://github.com/vlfeat/matconvnet.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'bin2header'
        'url' = 'https://github.com/cenit/bin2header.git'
        'upstream' = 'https://github.com/AntumDeluge/bin2header.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'Blob.js'
        'url' = 'https://github.com/cenit/Blob.js.git'
        'upstream' = 'https://github.com/eligrey/Blob.js.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'dotfiles'
        'url' = 'https://github.com/cenit/dotfiles.git'
        'upstream' = 'https://github.com/mathiasbynens/dotfiles.git'
        'local_branch' = 'main'
        'upstream_branch' = 'main'
        'skip' = $false
    },
    @{
        'name' = 'Aravis-OpenCV-Wrapper'
        'url' = 'https://github.com/cenit/Aravis-OpenCV-Wrapper.git'
        'upstream' = 'https://github.com/kushalvyas/Aravis-OpenCV-Wrapper.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'Microsoft-MPI'
        'url' = 'https://github.com/cenit/Microsoft-MPI.git'
        'upstream' = 'https://github.com/microsoft/Microsoft-MPI.git'
        'local_branch' = 'master'
        'upstream_branch' = 'master'
        'skip' = $false
    },
    @{
        'name' = 'boost_math_cenit'
        'url' = 'https://github.com/cenit/math.git'
        'upstream' = 'https://github.com/boostorg/math.git'
        'local_branch' = 'develop'
        'upstream_branch' = 'develop'
        'skip' = $false
    }
)

$repositoriesCloned = @(
    @{
        'name' = 'Smilei'
        'url' = 'https://github.com/ALaDyn/Smilei.git'
        'upstream' = 'https://github.com/SmileiPIC/Smilei.git'
        'skip' = $false
    },
    @{
        'name' = 'picongpu'
        'url' = 'https://github.com/ALaDyn/picongpu.git'
        'upstream' = 'https://github.com/ComputationalRadiationPhysics/picongpu.git'
        'skip' = $false
    },
    @{
        'name' = 'psc'
        'url' = 'https://github.com/ALaDyn/psc.git'
        'upstream' = 'https://github.com/germasch/psc.git'
        'skip' = $false
    },
    @{
        'name' = 'fbpic'
        'url' = 'https://github.com/ALaDyn/fbpic.git'
        'upstream' = 'https://github.com/fbpic/fbpic.git'
        'skip' = $false
    },
    @{
        'name' = 'gnuplot-colorbrewer'
        'url' = 'https://github.com/ALaDyn/gnuplot-colorbrewer.git'
        'upstream' = 'https://github.com/aschn/gnuplot-colorbrewer.git'
        'skip' = $false
    },
    @{
        'name' = 'VTKFortran'
        'url' = 'https://github.com/ALaDyn/VTKFortran.git'
        'upstream' = 'https://github.com/szaghi/VTKFortran.git'
        'skip' = $false
    },
    @{
        'name' = 'ramses'
        'url' = 'https://github.com/ALaDyn/ramses.git'
        'upstream' = 'https://bitbucket.org/rteyssie/ramses.git'
        'skip' = $false
    },
    @{
        'name' = 'epoch'
        'url' = 'https://github.com/ALaDyn/epoch.git'
        'upstream' = 'git@cfsa-pmw.warwick.ac.uk:EPOCH/epoch.git'
        'skip' = $true
    },
    @{
        'name' = 'EPOCH_manuals'
        'url' = 'https://github.com/ALaDyn/EPOCH_manuals.git'
        'upstream' = 'git@cfsa-pmw.warwick.ac.uk:EPOCH/EPOCH_manuals.git'
        'skip' = $true
    },
    @{
        'name' = 'grub'
        'url' = 'https://github.com/cenit/grub.git'
        'upstream' = 'https://git.savannah.gnu.org/git/grub.git'
        'skip' = $false
    },
    @{
        'name' = 'websocketpp'
        'url' = 'https://github.com/physycom/websocketpp.git'
        'upstream' = 'https://github.com/zaphoyd/websocketpp.git'
        'skip' = $false
    },
    @{
        'name' = 'curlpp'
        'url' = 'https://github.com/physycom/curlpp.git'
        'upstream' = 'https://github.com/jpbarrette/curlpp.git'
        'skip' = $false
    },
    @{
        'name' = 'json'
        'url' = 'https://github.com/physycom/json.git'
        'upstream' = 'https://github.com/nlohmann/json.git'
        'skip' = $false
    },
    @{
        'name' = 'jsoncons'
        'url' = 'https://github.com/physycom/jsoncons.git'
        'upstream' = 'https://github.com/danielaparker/jsoncons.git'
        'skip' = $false
    },
    @{
        'name' = 'Nominatim'
        'url' = 'https://github.com/physycom/Nominatim.git'
        'upstream' = 'https://github.com/twain47/Nominatim.git'
        'skip' = $false
    },
    @{
        'name' = 'mosquitto'
        'url' = 'https://github.com/physycom/mosquitto.git'
        'upstream' = 'https://github.com/eclipse/mosquitto.git'
        'skip' = $false
    },
    @{
        'name' = 'geopy'
        'url' = 'https://github.com/physycom/geopy.git'
        'upstream' = 'https://github.com/geopy/geopy.git'
        'skip' = $false
    },
    @{
        'name' = 'pyUblox'
        'url' = 'https://github.com/physycom/pyUblox.git'
        'upstream' = 'https://github.com/tridge/pyUblox.git'
        'skip' = $false
    },
    @{
        'name' = 'Catch'
        'url' = 'https://github.com/physycom/Catch.git'
        'upstream' = 'https://github.com/philsquared/Catch.git'
        'skip' = $false
    },
    @{
        'name' = 'RTKLIB'
        'url' = 'https://github.com/physycom/RTKLIB.git'
        'upstream' = 'https://github.com/tomojitakasu/RTKLIB.git'
        'skip' = $false
    },
    @{
        'name' = 'numerical-methods-fortran'
        'url' = 'https://github.com/physycom/numerical-methods-fortran.git'
        'upstream' = 'https://github.com/planelles20/numerical-methods-fortran.git'
        'skip' = $false
    },
    @{
        'name' = 'densityClust'
        'url' = 'https://github.com/physycom/densityClust.git'
        'upstream' = 'https://github.com/thomasp85/densityClust.git'
        'skip' = $false
    },
    @{
        'name' = 'voc-dpm'
        'url' = 'https://github.com/physycom/voc-dpm.git'
        'upstream' = 'https://github.com/rbgirshick/voc-dpm.git'
        'skip' = $false
    },
    @{
        'name' = 'Dictionaries'
        'url' = 'https://github.com/physycom/Dictionaries.git'
        'upstream' = 'https://github.com/titoBouzout/Dictionaries.git'
        'skip' = $false
    }
)

$repositoriesClonedCenit = @(
    @{
        'name' = 'coulomb_oscillators'
        'url' = 'https://github.com/cenit/coulomb_oscillators.git'
        'upstream' = 'https://github.com/locuoco/coulomb_oscillators.git'
        'skip' = $false
    },
    @{
        'name' = 'openMVG'
        'url' = 'https://github.com/cenit/openMVG.git'
        'upstream' = 'https://github.com/openMVG/openMVG.git'
        'skip' = $false
    },
    @{
        'name' = 'elmerfem'
        'url' = 'https://github.com/cenit/elmerfem.git'
        'upstream' = 'https://github.com/ElmerCSC/elmerfem.git'
        'skip' = $false
    },
    @{
        'name' = 'BBAPI'
        'url' = 'https://github.com/cenit/BBAPI.git'
        'upstream' = 'https://github.com/Beckhoff/BBAPI.git'
        'skip' = $false
    },
    @{
        'name' = 'BBAPI'
        'url' = 'https://github.com/cenit/PoissonRecon.git'
        'upstream' = 'https://github.com/mkazhdan/PoissonRecon.git'
        'skip' = $false
    },
    @{
        'name' = 'openeb'
        'url' = 'https://github.com/cenit/openeb.git'
        'upstream' = 'https://github.com/prophesee-ai/openeb.git'
        'skip' = $false
    },
    @{
        'name' = 'nbody'
        'url' = 'https://github.com/cenit/nbody.git'
        'upstream' = 'https://github.com/thegtproject/nbody.git'
        'skip' = $false
    },
    @{
        'name' = 'Multitarget-tracker'
        'url' = 'https://github.com/cenit/Multitarget-tracker.git'
        'upstream' = 'https://github.com/Smorodov/Multitarget-tracker.git'
        'skip' = $false
    },
    @{
        'name' = 'gdl'
        'url' = 'https://github.com/cenit/gdl.git'
        'upstream' = 'https://github.com/gnudatalanguage/gdl.git'
        'skip' = $false
    },
    @{
        'name' = 'Detectron'
        'url' = 'https://github.com/cenit/Detectron.git'
        'upstream' = 'https://github.com/facebookresearch/Detectron.git'
        'skip' = $false
    },
    @{
        'name' = 'community_bash_style_guide'
        'url' = 'https://github.com/cenit/community_bash_style_guide.git'
        'upstream' = 'https://github.com/azet/community_bash_style_guide.git'
        'skip' = $false
    },
    @{
        'name' = 'azure-batch-apps-blender'
        'url' = 'https://github.com/cenit/azure-batch-apps-blender.git'
        'upstream' = 'https://github.com/Azure/azure-batch-apps-blender.git'
        'skip' = $false
    },
    @{
        'name' = 'doxygen'
        'url' = 'https://github.com/cenit/doxygen.git'
        'upstream' = 'https://github.com/doxygen/doxygen.git'
        'skip' = $false
    },
    @{
        'name' = 'exafmm'
        'url' = 'https://github.com/cenit/exafmm.git'
        'upstream' = 'https://github.com/exafmm/exafmm.git'
        'skip' = $false
    },
    @{
        'name' = 'Urti-2d'
        'url' = 'https://github.com/cenit/Urti-2d.git'
        'upstream' = 'https://github.com/GabrieleCalarota/Urti-2d.git'
        'skip' = $false
    },
    @{
        'name' = 'L1--L2---Computation-of-satellite-and-receiver-position'
        'url' = 'https://github.com/cenit/L1--L2---Computation-of-satellite-and-receiver-position'
        'upstream' = 'https://github.com/kevinsan1/L1--L2---Computation-of-satellite-and-receiver-position.git'
        'skip' = $false
    }
)

function Update-Repo ($repo_name, $local_branch, $upstream_branch) {
    if (Test-Path $repo_name) {
        Set-Location -Path $repo_name
        git fetch -p origin
        git checkout $local_branch
        git fetch upstream
        git merge upstream/$upstream_branch
        git push
        Set-Location -Path ..
    } else {
        Write-Host "Unable to find --- $repo_name --- skipping" -ForegroundColor Yellow
    }
}

if ($onlyThisRepo -ne "") {
    $repositoriesCustomized = $repositoriesCustomized | Where-Object { $_.name -eq $onlyThisRepo }
    $repositoriesCloned = $repositoriesCloned | Where-Object { $_.name -eq $onlyThisRepo }
    $repositoriesClonedCenit = $repositoriesClonedCenit | Where-Object { $_.name -eq $onlyThisRepo }
}

foreach ($repo in $repositoriesCustomized) {
    if ($($repo.skip)) {
        Write-Host "Skipping --- $($repo.name)" -ForegroundColor Yellow
        continue
    }
    if (!(Test-Path $($repo.name))) {
        git clone $($repo.url) $($repo.name)
        if (Test-Path $($repo.name)) {
            Set-Location -Path $($repo.name)
            git remote add upstream $($repo.upstream)
            git checkout $($repo.local_branch)
            git fetch upstream
            git merge upstream/$($repo.upstream_branch)
            git push
            Set-Location -Path ..
        } else {
            Write-Output "Failed cloning --- $($repo.name)" -ForegroundColor Red
        }
    }
    else {
        Update-Repo $($repo.name) $($repo.local_branch) $($repo.upstream_branch)
    }
}

foreach ($repo in $repositoriesCloned) {
    if ($($repo.skip)) {
        Write-Host "Skipping --- $($repo.name)" -ForegroundColor Yellow
        continue
    }
    Remove-Item -Recurse -Force $($repo.name) -ErrorAction Ignore
    if (!(Test-Path $($repo.name))) {
        git clone --mirror $($repo.upstream) $($repo.name)
        if (Test-Path $($repo.name)) {
            Set-Location $($repo.name)
            git remote set-url --push origin $($repo.url)
            git fetch -p origin
            git push --mirror
            Set-Location ..
        } else {
            Write-Output "Failed cloning --- $($repo.name)" -ForegroundColor Red
        }
    }
    Remove-Item -Recurse -Force $($repo.name) -ErrorAction Ignore
}

foreach ($repo in $repositoriesClonedCenit) {
    if ($($repo.skip)) {
        Write-Host "Skipping --- $($repo.name)" -ForegroundColor Yellow
        continue
    }
    Remove-Item -Recurse -Force "$($repo.name)_cenit" -ErrorAction Ignore
    if (!(Test-Path "$($repo.name)_cenit")) {
        git clone --mirror $($repo.upstream) "$($repo.name)_cenit"
        if (Test-Path "$($repo.name)_cenit") {
            Set-Location "$($repo.name)_cenit"
            git remote set-url --push origin $($repo.url)
            git fetch -p origin
            git push --mirror
            Set-Location ..
        } else {
            Write-Output "Failed cloning --- $($repo.name)" -ForegroundColor Red
        }
    }
    Remove-Item -Recurse -Force "$($repo.name)_cenit" -ErrorAction Ignore
}

# Special case for darknet
if (($onlyThisRepo -eq "darknet_cenit") -or ($onlyThisRepo -eq "")) {
  if (!(Test-Path "darknet_cenit")) {
      git clone https://github.com/cenit/darknet.git darknet_cenit
      if (Test-Path darknet_cenit) {
          Set-Location -Path darknet_cenit
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
          Set-Location -Path ..
      } else {
          Write-Output "Failed cloning --- $($repo.name)" -ForegroundColor Red
      }
  }
  else {
      Set-Location -Path "darknet_cenit"
      git checkout "master"
      git fetch "upstream_pj"
      git merge "upstream_pj/master"
      git push
      git checkout "dev/alexey/master"
      git fetch "upstream_ax"
      git merge "upstream_ax/master"
      git push
      git checkout "master"
      Set-Location -Path ..
  }
}
Write-Host "Finished running setup_update_forks.ps1" -ForegroundColor Green
