declare -a FILE_DA_SCARICARE
FILE_DA_SCARICARE=(`cat diff.txt`)
PERCORSO_FILE=/shared/data/userexternal/plondril/Aladyn
RUN_ESAMINATO=run1_TNSA
for FILE in ${FILE_DA_SCARICARE[*]}
do
   scp -p plondril@sp.sp6.cineca.it:${PERCORSO_FILE}/${RUN_ESAMINATO}/${FILE} ${RUN_ESAMINATO}/.
done
echo -e "Ho finito di scaricare il diff di ${RUN_ESAMINATO}" 