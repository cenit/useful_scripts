#CINECA_DATA
#PERCORSO_FILE=/shared/data/userexternal/plondril/Aladyn
#BGP_SCRATCH
PERCORSO_FILE=/gpfs/scratch/userexternal/plondril/Aladyn
RUN_ORIGINALE=run6
RUN_DESTINAZIONE=run1_TNSA
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/E?fout07.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/I*06.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/I*07.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/B*06.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/B*07.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/B*02.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/B*04.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/*.out ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/input.data ${RUN_DESTINAZIONE}/.
RUN_ORIGINALE=run1
RUN_DESTINAZIONE=run7b_TNSA
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/*.out ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/input.data ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/B*02.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/B*04.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/B*06.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/E*02.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/E*04.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/P*04.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/P*06.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/I*02.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/I*04.bin ${RUN_DESTINAZIONE}/.
RUN_ORIGINALE=run3
RUN_DESTINAZIONE=run8_TNSA
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/*.out ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/input.data ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/B*02.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/B*04.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/B*06.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/B*08.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/P*08.bin ${RUN_DESTINAZIONE}/.
scp -p plondril@login.bgp.cineca.it:${PERCORSO_FILE}/${RUN_ORIGINALE}/I*08.bin ${RUN_DESTINAZIONE}/.
echo -e "Ho finito di scaricare i nuovi files" 