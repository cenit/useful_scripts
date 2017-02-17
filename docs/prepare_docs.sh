#!/bin/bash

cd ~/Codice

repo_doxygenate=("calib_lib" "math_lib" "rdp_lib" "vbb_datastore" "vbb_meta" "vbb_texa" "texabox")
for repo in ${repo_doxygenate[*]} ; do
  if [ -d $repo ]; then
    cd $repo
    pandoc --from=markdown README.md .pandoc.yml -o ../${repo}.pdf
    cd ..
  fi
done

#special treatment for metabox (due to SVN folder structure)
repo="metabox"
if [ -d $repo ]; then
  cd $repo/trunk
  pandoc --from=markdown README.md .pandoc.yml -o ../${repo}.pdf
  cd ../..
fi


repo_soloreadme=("data_tools" "datalogger" "distance_stats" "get_nominatim_info" "inertial_tools" "json_distance" "json_packer" "json_to_html" "json_to_kml" "kml_to_json" "libgnssconv" "list_to_json" "log_parser" "Quaternioni" "ubx_to_json")
for repo in ${repo_soloreadme[*]} ; do
  if [ -d $repo ]; then
    cd $repo
    pandoc --from=markdown README.md -o ../${repo}.pdf
    cd ..
  fi
done

