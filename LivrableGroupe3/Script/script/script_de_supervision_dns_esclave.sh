#!/bin/bash

#VARIABLE POUR RELEVER LES ERREURS
MESS_ERROR=/etc/MESS_ERROR.txt
echo "Problème(s): " > MESS_ERROR.txt

#création d'un fichier pour stocker les .csv
DOSSIERCSV=/home/romain/Desktop/DossierCSV
if [ ! -e $DOSSIERCSV ]
then
mkdir $DOSSIERCSV
fi

#CREER LE FICHIER AVEC LA DATE DU JOUR
DATE=`date +"%kh%M-%d.%m.%y"`
touch $DATE.csv

#DONNER L'ADRESSE DU SERVEUR HTTP
Add_HTTP=192.168.132.129

#TEMPS DE REPONSE

ping -c1 $Add_HTTP | cut -d"=" -f4 | sed -n '2p' > $DATE.csv

#DONNER LE NOM DE DOMAINE ET L'IP DU DNS
DOMAIN=cesi.fr
IPDOMAIN=178.170.102.194

#TEST SERVEUR DNS
tmpdns="`nslookup $DOMAIN | sed -n '6p' | cut -d" " -f2`"
echo $tmpdns > tmpdns
if [ "$tmpdns" = "$IPDOMAIN" ]
then
echo On >> $DATE.csv
else
echo Off >> $DATE.csv
echo "Le serveur DNS ne fonctionne pas" >> $MESS_ERROR
fi


#PING SERVEUR HTTP
ping -c1 $Add_HTTP
     if [ $? -eq 0 ]
     then echo On >> $DATE.csv
     else echo Off >> $DATE.csv
     echo "Le serveur HTTP ne fonctionne pas" >> $MESS_ERROR
     fi

#ACCES AU SITE WEB

wget https://www.cesi.fr 2> tmp1.txt
tmp2="`cut tmp1.txt  -d" " -f10 | sed -n '4p'`"
    if [ "$tmp2" = "OK" ]
    then echo On >> $DATE.csv
    rm index.html
    else echo Off >> $DATE.csv
    echo "Le site WEB n'est pas en ligne" >> $MESS_ERROR
    fi

#CREATION D'UNE VARIABLE QUI LIT LE FICHIER TEXTE
var=`cat MESS_ERROR.txt`

#ENVOIE MAIL ERREUR
echo "Ce mail fait suite au rapport $DATE si le message suivant est vide, aucun problèmes. $var" | mail -s "Message d'erreur" root

#SAVE .CSV SUR HTTP
cp -a $DATE.csv /etc/SAVEHTTP.csv
sshpass -p "bule" scp SAVEHTTP.csv romain@192.168.132.129:/home/romain/Desktop

#DEPLACER LE FICHIER .CSV DANS LE BON DOSSIER
mv $DATE.csv /home/romain/Desktop/DossierCSV