#!/bin/bash

direcname="Kucing_$(date '+%d-%m-%Y')"
creaturename="kitten"
lastname="Kucing_"

if [ $(($(date '+%d')%2)) -eq 0  ]
then
	mkdir $direcname
	for ((a=0; a<23; a=a+1))
	do
		wget -a /home/solxius/Desktop/Sisop/Modul1/Foto.log "https://loremflickr.com/320/240/kitten" -O /home/solxius/Desktop/Sisop/Modul1/$direcname/$creaturename$a.jpeg
	done
else
	direcname="Kelinci_$(date '+%d-%m-%Y')"
	creaturename="bunny"
	lastname="Kelinci_"
	mkdir $direcname
	for ((a=0; a<23; a=a+1))
	do
		wget -a /home/solxius/Desktop/Sisop/Modul1/Foto.log "https://loremflickr.com/320/240/bunny" -O /home/solxius/Desktop/Sisop/Modul1/$direcname/$creaturename$a.jpeg
	done
fi

awk '/Location/ {print $2}' Foto.log >> check.log

readarray myarray < check.log
indexo=0

for ((a=0; a<23; a=a+1))
do
flag=0
	for ((b=a-1; b>=0; b=b-1))
	do
		if [ ${myarray[a]} == ${myarray[b]} ]
		then
		  flag=1
		  break
		else
		  flag=0
		fi
	done

	if [ $flag -eq 0 ]
	then
		indexo=$(($indexo + 1)) 
		zerotwodee=$(printf "Koleksi_%02d" "$indexo")
		mv /home/solxius/Desktop/Sisop/Modul1/$direcname/$creaturename$a.jpeg /home/solxius/Desktop/Sisop/Modul1/$direcname/$lastname_$zerotwodee.jpeg
	else
		rm /home/solxius/Desktop/Sisop/Modul1/$direcname/$creaturename$a.jpeg
	fi
done

mv /home/solxius/Desktop/Sisop/Modul1/Foto.log /home/solxius/Desktop/Sisop/Modul1/$direcname/Foto.log

rm check.log
