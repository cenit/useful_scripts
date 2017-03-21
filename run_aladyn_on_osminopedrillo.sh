#!/bin/bash


TOTAL_NUMBER_OF_CORES=16
EXE_NAME="/tamino/stefano/codice/ALaDyn/bin/ALaDyn"

stderr_file=epic.txt
stdout_file=opic.txt
machine_file=mf.mpi

touch ${stderr_file}
touch ${stdout_file}

echo "osmino.bo.infn.it:8" > $machine_file
echo "pedrillo.bo.infn.it:8" >> $machine_file

echo
echo
echo
echo "Submit your job using these commands:"
echo
echo "$  at now +1 minutes "
echo ">  source $HOME/.bashrc "
echo ">  cd $PWD "
echo ">  mpirun -np ${TOTAL_NUMBER_OF_CORES} --machinefile ${machine_file} ${EXE_NAME} >> ${stdout_file} 2>> ${stderr_file}"
echo 
echo
echo "Then close the command prompt with CTRL + D"
echo
echo

