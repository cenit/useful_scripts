#! /usr/bin/env bash

#RUN_LOCALE=Comb
RUN_REMOTO=run4_El
##### CINECA_DATA
PERCORSO_FILE=/shared/data/userexternal/plondril/Aladyn
#scp -p plondril@sp.sp6.cineca.it:${PERCORSO_FILE}/${RUN_REMOTO}/files.txt .
########################
##### CINECA_SCRATCH
#PERCORSO_FILE=/gpfs/scratch/userexternal/plondril/Aladyn
# copiare manualmente files.txt ed editarlo per rimuovere i dump binari
########################
#declare -a FILE_DA_SCARICARE
#FILE_DA_SCARICARE=(`cat files.txt`)
#mkdir ${RUN_LOCALE}
#for FILE in ${FILE_DA_SCARICARE[*]}
#do
   scp -rp plondril@sp.sp6.cineca.it:${PERCORSO_FILE}/${RUN_REMOTO} .
#   scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_REMOTO}/${FILE} ${RUN_LOCALE}/.
#done
echo -e "Ho finito di scaricare il ${RUN_REMOTO} in ${RUN_LOCALE}"
