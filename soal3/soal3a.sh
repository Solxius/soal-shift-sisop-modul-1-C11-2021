#!/bin/bash

for ((a=0; a<23; a=a+1))
do
	wget -a /home/solxius/Desktop/Sisop/Modul1/Foto.log "https://loremflickr.com/320/240/kitten" -O /home/solxius/Desktop/Sisop/Modul1/kitten"$a".jpeg
done

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
		mv /home/solxius/Desktop/Sisop/Modul1/kitten"$a".jpeg /home/solxius/Desktop/Sisop/Modul1/$zerotwodee.jpeg
	else
		rm /home/solxius/Desktop/Sisop/Modul1/kitten"$a".jpeg
	fi
done

rm check.log
