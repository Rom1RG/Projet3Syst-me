#!/bin/bash

DONNEEHTTP=/home/romain/Desktop/donnéesHTTP.txt
TRY2=/home/romain/Desktop/try2.txt
DONNEEIP=/home/romain/Desktop/donnéeIP.txt
ERROR=/home/romain/Desktop/error.txt
SAVEHTTP=/home/romain/Desktop/SAVEHTTP.csv

Site=/var/www/html/index.html

cat /var/log/apache2/access.log | wc -l > $DONNEEHTTP

#comptage du nombre de connexions au site web.
cat /var/log/apache2/access.log > $TRY2
#copy du dossier des ip des utilisateurs ayant visité le site vers un fichier modifiable.
cat $TRY2 | cut -d' ' -f1 | sort | uniq | wc -l >> $DONNEEHTTP
#trie et réduit le nombre d'ip pour enlever les doublons afin de savoir combien d'utilisateurs différents ont vu le site.
cat $TRY2 | cut -d' ' -f1 | sort | uniq -c > $DONNEEIP

free -h --total > $TRY2
#RAM -> fichier modifiable.
sed -n "2p" $TRY2 | cut -c15-19 >> $DONNEEHTTP
sed -n "4p" $TRY2 | cut -c39-43 >> $DONNEEHTTP
#récupération des valeurs que l'on souhaite exploiter.
df -h --total > $TRY2
#Stockage -> fichier modifiable.
sed -n "24p" $TRY2 | cut -c22-26 >> $DONNEEHTTP
sed -n "24p" $TRY2 | cut -c29-33 >> $DONNEEHTTP
#Récupération des valeurs que l'on souhaite exploiter.
cat $SAVEHTTP >> $DONNEEHTTP 2> $ERROR
#récupération des valeurs traitées et reçues du serveur DNS.



#---------------- * Passage vers le code HTML * ---------------# 

nbip=`sed -n "1p" $DONNEEHTTP` 
echo $nbip
nbvisit=`sed -n "2p" $DONNEEHTTP` 
echo $nbvisit
RamMax=`sed -n "3p" $DONNEEHTTP` 
echo $RamMax
RamUtil=`sed -n "4p" $DONNEEHTTP` 
echo $RamUtil
SpaceMax=`sed -n "6p" $DONNEEHTTP` 
echo $SpaceMax
SpaceUtil=`sed -n "5p" $DONNEEHTTP` 
echo $SpaceUtil
Ping=`sed -n "7p" $DONNEEHTTP` 
echo $Ping
DNS=`sed -n "8p" $DONNEEHTTP` 
echo $DNS
HTTP=`sed -n "9p" $DONNEEHTTP` 
echo $HTTP
WEB=`sed -n "10p" $DONNEEHTTP` 
echo $WEB
error=`cat $ERROR`


a=0
echo "<!DOCTYPE html>
<html>
	<head>
		<META HTTP-EQUIV='Refresh' CONTENT='3; URL=index.html'> 
		<link href='style2.css' media='all' rel='stylesheet' type='text/css' />
		<title>Carnoflux Website</title>
	</head>

	<body>
		<span class='bandeau'></span>
		<h1>* Control Panel *</h1>
		<p class='titre1'> Nombres de visites / jours : </p>
		<p class='titre2'> Nombre de visiteurs / jours :</p>
		<p class='titre3'> RAM libre :</p>	
		<p class='titre4'> Espace Disque libre :</p>
		<P class='titre5'> Temps de reponse Serveur :</p>
		<P class='titre6'> Serveur DNS :</p>
		<p class='titre7'> Serveur HTTP :</p>
		<p class='titre8'> Site WEB :</p>" > $Site

echo "		<p class='value1'>$nbip</p>" >> $Site
echo "		<p class='value2'>$nbvisit</p>" >> $Site
if [ $nbvisit -gt 0 ]
	then
	echo "		<li><p class='value2'> 1 </p>" >> $Site
	echo "		 <ul>" >> $Site
	while [ $a -ne $nbvisit ]
  		do
		a=$(($a + 1))
		ip=`sed -n "$a p" $DONNEEIP | cut -d' ' -f5`
		nb=`sed -n "$a p" $DONNEEIP | cut -d' ' -f4`
		echo "		  <li><p>$ip    ,$nb fois</p></li>" >> $Site
	done
	echo "		 </ul>
		</li>" >> $Site
	  	
else
echo "		<p class='value2'>$nbvisit</p>" >> $Site	  
fi

echo "		<p class='value3'>$RamUtil / $RamMax</p>" >> $Site
echo "		<p class='value4'>$SpaceUtil / $SpaceMax</p>" >> $Site
echo "		<p class='value5'>$Ping</p>" >> $Site
echo "		<p class='value6'>$DNS</p>" >> $Site
echo "		<p class='value7'>$HTTP</p>" >> $Site
echo "		<p class='value8'>$WEB</p>" >> $Site
echo "		<P class='error'>$error</p>" >> $Site

echo "	</body>


</html> " >> $Site



cat $ERROR

rm $TRY2
rm $DONNEEHTTP
rm $DONNEEIP
rm $ERROR

