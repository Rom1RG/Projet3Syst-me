#!/bin/bash
#On d�finit nos variables, et nos lieux o� se trouvent nos r�pertoires
BACKUP_AP=/etc/apache2
BACKUP_WWW=/var/www
BACKUP_DOSS=/home/adminserveur/Desktop/Backup
DATE=`date '+%d-%m-%y_%HH%M'`
LOG_FILE=/var/log.txt 

#On cr�er la fonction qui nous permet de faire la premi�re sauvegard compl�te
save_comp()
{
echo -e "--- SAUVEGARDE COMPLETE ---" >> $LOG_FILE
#On regarde dans nos repertoires s'il y a des dossiers ou r�pertoires � sauvegarder, si il ny en � pas on ne sauvegarde pas
NBRE_FILES=`find $BACKUP_AF -type f 2>/dev/null | wc -l`
if [[ $NBRE_FILES == 0 ]]
then
	echo -e "Il n'y a aucun fichier � sauvegarde dans $BACKUP_AF, donc pas de sauvegarde. \n" >> $LOG_FILE
else
#On regarde si le dossier o� l'on met nos sauvegardes existes
	if [ -e $BACKUP_DOSS ]
        then 
                echo -e "Le dossier de sauvegarde existe" >> $LOG_FILE
		tar -czf $BACKUP_DOSS/SAVE_COMP_$DATE.tgz $BACKUP_AP $BACKUP_WWW 2>/dev/null
        	echo -e "Sauvegarde du $DATE bien cr��. \n" >> $LOG_FILE
        else
        	echo -e "Le dossier de sauvegrde n'exite pas. Cr�ation en cours... Dossier cr�e. \n" >> $LOG_FILE
        	mkdir "$BACKUP_DOSS"
		tar -czf $BACKUP_DOSS/SAVE_COMP_$DATE.tgz $BACKUP_AP $BACKUP_WWW 2>/dev/null
		echo -e "Sauvegarde du $DATE bien cr��. \n" >> $LOG_FILE
	fi
fi
}


save_incr()
{
echo -e "--- SAUVEGARDE INCREMENTALE ---" >> $LOG_FILE
NBRE_FILES=`find $BACKUP_AP -type f -mtime -1 2>/dev/null | wc -l`
NBRE_FILES2=`find $BACKUP_WWW -type f -mtime-1 2>/dev/null | wc -l`
if [ $NBRE_FILES == 0 ] && [ $NBRE_FILES2 == 0 ]
then
	echo -e "Il n'y a pas eu de modifcations dans les dossiers. PAS DE SAUVEGARDE." >> $LOG_FILE
else
	if [ $NBRE_FILES != 0 ] && [ $NBRE_FILES2 != 0 ]
	then
		echo -e "Les deux dossiers ont �t� modifi�. SAUVEGARDE EN COURS..." >> $LOG_FILE
		tar -czf $BACKUP_DOSS/SAVE_INC_$DATE.tgz `find $BACKUP_AP $BACKUP_WWW -type f -mtime -1` 2>/dev/null
	else
		if [[ $NBRE_FILES == 0 ]]
		then
			echo -e "Le fichier WWW a �t� modifi�. SAUVEGARDE EN COURS..." >> $LOG_FILE
			tar -czf $BACKUP_DOSS/SAVE_INC_$DATE.tgz `find $BACKUP_WWW -type f -mtime -1` 2>/dev/null
		else
			echo -e "Le fichier Apache2 a �t� modifi�. SAUVEGARDE EN COURS..." >> $LOG_FILE
			tar -czf $BACKUP_DOSS/SAVE_INC_$DATE.tgz `find $BACKUP_AP -type f -mtime -1` 2>/dev/null
		fi
	fi
fi
}


mailsave()
{
#On d�finit deux variables qui regardent si il y a des modifications dans les configurations serveur
NBRE_FILES=`find $BACKUP_AP -type f -mtime -1 2>/dev/null | wc -l`
NBRE_FILES2=`find $BACKUP_WWW -type f -mtime-1 2>/dev/null | wc -l`
#Si le fichier de backup n'existe pas et qu'il n'y a pas de modifications, il n'y a pas de probl�me de sauvegarde
if [ ! -e $BACKUP_DOSS/SAVE_INC_$DATE.tgz ] && [ $NBRE_FILES == 0 ] || [ $NBRE_FILES2 == 0 ]
then
	echo -e "Il n'y a pas de probl�me. \n" >> $LOG_FILE
else 
	#Sinon on envoie un mail d'erreur au root (en local)
	echo "Erreur de sauvegarde incr�mentale du $DATE" | mail -s "Erreur de sauvegarde" root 
fi
}


espace_disque()
{
#On affiche l espace disque, la ligne qu'on veut ainsi que la colonne pour r�cup�rer le % d'espace pris
ESPACE=`df -h / | sed -n 2p | cut -c35-36`
if [[ ESPACE -ge 90 ]]
then
	#Si l'espace pris est sup�rieur � 90%, on envoie aussi un mail d erreur de sauvegarde � cause d un manque de place
	echo "Plus assez de place sur le disque dur!!" | mail -s "Manque de place sur le disque" root
	echo "Il n'y a plus de place sur le disque dur." >> $LOG_FILE
	exit 0
else
	#Sinon on affiche sur le fichier de log (doc txt) qu'on peut faire une sauvegarde
	echo "Il y a $ESPACE % d'espace disque utilis�, on peut donc faire une sauvegarde de plus." >> $LOG_FILE 
fi
}


limit_backup()
{
#Ici, on cr�er une variable qui va afficher le nombre de ligne comprenant les caract�res SAVE_INC
LIMITE=`ls -lt $BACKUP_DOSS | grep SAVE_INC | wc -l`
#Si le nombre de ligne est sup�rieur � 3, on rentre dans le dossier o� on a nos backup et on supprime le fichier le plus vieux
if (( $LIMITE >= 3 ))
	then
	cd $BACKUP_DOSS
	rm -f $(ls -1t | tail -1)
	echo "Suppression de la sauvegarde la plus vieille" >> $LOG_FILE
fi
}

 
echo -e " --- Backup du `date +%D` � `date +%H:%M` ---" >> $LOG_FILE
#On appelle nos fonctions 
limit_backup
espace_disque
#On regarde si une sauvegarde compl�te existe 
NBRE_FULL=`ls $BACKUP_DOSS/SAVE_COMP_* 2>/dev/null | wc -l`
if [[ $NBRE_FULL > 0 ]];
then
	echo -e "Il y a une sauvegarde compl�te on peut donc faire des incr�mentales" >> $LOG_FILE
	save_incr
	mailsave
else
	save_comp
fi