#!/bin/sh

#####################################################################################################################
# Configuration
#####################################################################################################################
BASH_SOURCE0=${BASH_SOURCE[0]}
cd $(dirname $BASH_SOURCE0)
scrDirN0FullPath=$(pwd)
#confDir=${scrDirN0FullPath}/conf
logDir=${scrDirN0FullPath}/logs
dtaDir=${scrDirN0FullPath}/data
cfgDir=${scrDirN0FullPath}/conf
outDir=${scrDirN0FullPath}/temp/html
wwwDir=${scrDirN0FullPath}/html
cd $scrDirN0FullPath

source ${cfgDir}/pgcluu.conf

#####################################################
##  Gestion log + affichage sortie standard
#####################################################
stepdate=$(date +"%Y%m%d_%H%M%S")
scrShortFileName=$(basename $0 .sh)
logFile=${logDir}/${scrShortFileName}-`hostname`-${stepdate}.log

# On initialise le fichier log
echo logFile : $logFile > $logFile
# On affiche le contenu du fichier log en le suivant tout en continuant à jouer la suite des commandes
tail -f ${logFile} &
tailpid=$!
# On redirige toute les sorties de commandes vers le fichier de log
exec >> ${logFile} 2>&1
# On active l'affichage des commandes jouées (et donc leur traçage dans le fichier de log)
#set -x

#####################################################
##  Traitement
#####################################################
# (pas besoin de rediriger les logs)
stepdate=$(date +"%Y%m%d_%H%M%S")
if [ "${outDir}" != "" ]; then

	nbserver=${#tabpgserver[@]}
	imaxserver=$(($nbserver-1))
	
	idx=0
	while [ "$idx" -le "$imaxserver" ]
	do
		pgserver=${tabpgserver[$idx]}
		pgport=""
		if [ "${tabpgport[$idx]}" = "" ]; then
			pgport=${pgdefaultport}
		else
			pgport=${tabpgport[$idx]}
		fi

		pguser=""
		if [ "${tabpguser[$idx]}" = "" ]; then
			pguser=${pgdefaultuser}
		else
			pguser=${tabpguser[$idx]}
		fi
		
		pgssh=""
		if [ "${tabpgssh[$idx]}" = "" ]; then
			pgssh=${pgdefaultssh}
		else
			pgssh=${tabpgssh[$idx]}
		fi
		
		PGCLUULOGDIR=${scrDirN0FullPath}/logs/${pgserver}-${pgport}
		[ -d "${PGCLUULOGDIR}" ] || mkdir -p ${PGCLUULOGDIR}
		chown -R ${PGCLUUUSER}:${PGCLUUGROUP} ${PGCLUULOGDIR}

		PGCLUUDATADIR=${scrDirN0FullPath}/data/${pgserver}-${pgport}
		[ -d "${PGCLUUDATADIR}" ] || mkdir -p ${PGCLUUDATADIR}
		chown -R ${PGCLUUUSER}:${PGCLUUGROUP} ${PGCLUUDATADIR}
		
		
		echo ""
		echo "###  ${scrShortFileName} : ${pgserver}-${pgport}"
		echo "#########################################################"
		
		# un créneau de 6:00 permet d'avoir une transformation des données en html rapide
		
		myyear=$(date +%Y)
		mymonth=$(date +%m)
		myday=$(date +%d)
		myhour=$(date +%H)
		
		myprecyear=$(date --date='now-4 hour' +%Y)
		myprecmonth=$(date --date='now-4 hour' +%m)
		myprecday=$(date --date='now-4 hour' +%d)
		
		
		# A la première execution dans un nouveau créneau, on génère pour la dernière fois le html du créneau précédent, puis on purge les datas
		if [ "${myhour}" -lt "6" ]; then
			echo "myhour < 6"
			if [ ! -d "${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_00-06" ]; then
				echo "dir ${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_00-06 doesn't exist"
				htmldirsrc="${outDir}/${pgserver}-${pgport}/${myprecyear}/${myprecmonth}/${myprecday}"
				htmldirtarget="${wwwDir}/${pgserver}-${pgport}/${myprecyear}/${myprecmonth}/${myprecday}_18-24"
				nextdirtarget="${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_00-06"
				cleandata=1
			else
				echo "dir ${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_00-06 exist"
				htmldirsrc="${outDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}"
				htmldirtarget="${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_00-06"
				cleandata=0
			fi
		elif [ "${myhour}" -ge "6" ] && [ "${myhour}" -lt "12" ]; then
			echo "6 <= myhour < 12"
			if [ ! -d "${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_06-12" ]; then
				echo "dir ${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_06-12 doesn't exist"
				htmldirsrc="${outDir}/${pgserver}-${pgport}/${myprecyear}/${myprecmonth}/${myprecday}"
				htmldirtarget="${wwwDir}/${pgserver}-${pgport}/${myprecyear}/${myprecmonth}/${myprecday}_00-06"
				nextdirtarget="${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_06-12"
				cleandata=1
			else
				echo "dir ${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_06-12 exist"
				htmldirsrc="${outDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}"
				htmldirtarget="${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_06-12"
				cleandata=0
			fi
		elif [ "${myhour}" -ge "12" ] && [ "${myhour}" -lt "18" ]; then
			echo "12 <= myhour < 18"
			if [ ! -d "${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_12-18" ]; then
				echo "dir ${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_12-18 doesn't exist"
				htmldirsrc="${outDir}/${pgserver}-${pgport}/${myprecyear}/${myprecmonth}/${myprecday}"
				htmldirtarget="${wwwDir}/${pgserver}-${pgport}/${myprecyear}/${myprecmonth}/${myprecday}_06-12"
				nextdirtarget="${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_12-18"
				cleandata=1
			else
				echo "dir ${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_12-18 exist"
				htmldirsrc="${outDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}"
				htmldirtarget="${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_12-18"
				cleandata=0
			fi
		elif [ "${myhour}" -ge "18" ]; then
			if [ ! -d "${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_18-24" ]; then
				echo "dir ${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_18-24 doesn't exist"
				htmldirsrc="${outDir}/${pgserver}-${pgport}/${myprecyear}/${myprecmonth}/${myprecday}"
				htmldirtarget="${wwwDir}/${pgserver}-${pgport}/${myprecyear}/${myprecmonth}/${myprecday}_12-18"
				nextdirtarget="${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_18-24"
				cleandata=1
			else
				echo "dir ${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_18-24 exist"
				htmldirsrc="${outDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}"
				htmldirtarget="${wwwDir}/${pgserver}-${pgport}/${myyear}/${mymonth}/${myday}_18-24"
				cleandata=0
			fi
		fi
		
		echo ""
		echo "## Génération du html à partir des datas dans un répertoire temporaire"
		set -x
		rm -rvf ${outDir}/${pgserver}-${pgport}
		mkdir -pv ${outDir}/${pgserver}-${pgport}
		disablesar=""
		if [ "${pgssh}" = "false" ]; then
			disablesar="--disable-sar"
		fi
		${scrDirN0FullPath}/pgcluu -v ${disablesar} -o ${outDir}/${pgserver}-${pgport}/ ${dtaDir}/${pgserver}-${pgport}/
		set +x
		
		echo ""
		echo "## Synchronisation du contenu html vers le bon répertoire en ligne Apache"
		set -x
		echo ""
		mkdir -pv "${htmldirtarget}"
		echo ""
		rsync -rv "${htmldirsrc}/" "${htmldirtarget}/"
		echo ""
		cp -vf ${outDir}/${pgserver}-${pgport}/*.css ${wwwDir}/${pgserver}-${pgport}/
		echo ""
		cp -vf ${outDir}/${pgserver}-${pgport}/*.js ${wwwDir}/${pgserver}-${pgport}/
		set +x
		
		if [ "${cleandata}" = "1" ]; then
			echo "## Suppression des datas pour que la prochaine génération du html soit celle du créneau actuel et préparation du prochain dossier cible"
			set -x
			echo ""
			rm -rvf ${dtaDir}/${pgserver}-${pgport}/*
			echo ""
			mkdir ${nextdirtarget}
			set +x
		fi
		
		idx=$(($idx + 1))
	done
	
	if [ "${wwwDir}" != "" ]; then
		find ${wwwDir}/*/*/*/* -type d -mtime +15  -exec rm -r {} \;
		find ${wwwDir}/ -type d -empty -exec rm -r {} \;
	fi
	if [ "${logDir}" != "" ]; then
		find ${logDir}/ -type f -mtime +1 -delete
	fi
fi


#####################################################
##  Au revoir
#####################################################
set +x
sleep 1;kill $tailpid



