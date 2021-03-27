#!/bin/bash

#2a
awk -F '\t ''BEGIN{max = 0}
{
a =((($21/($18-$21))*100)
if(a >= max)
{
max  = a
transaksi = $1
}
}
END{
print "Transaksi terakhir dengan profit percentage terbesar yaitu %d dengan persentase %d%%\n" transaksi, max
}' Laporan-TokoShisop.tsv >> hasil.txt 

#2b
awk -F '\t''BEGIN{
print"Daftar nama customer di Albuquerque pada tahun 2017 antara lain:\n"
}
{
if($10 == "Albuquerque" && $2 ~ 17){
nc[$7]++
}
}
END{
for(i in nc) print i
print("\n")
}' Laporan-TokoShisop.tsv >> hasil.txt 

#2c
awk -F '\t' 'BEGIN{t = 0}
{
if($8 == "Consumer") x++
else if($8 == "Corporate") y++
else if($8 == "Home Office") z++
if(x<y && x<z){
sc = "Consumer"
t = x
}
else if(y<x && y<z){
sc = "Corporate"
t = y
}
else if(z<x && z<y){
sc = "Home Office"
t = z
}
END{
print "Tipe segmen customer yang penjualannya paling sedikit adalah %s dengan %d transaksi.\n\n",sc,t
}' Laporan-TokoShisop.tsv >> hasil.txt 

#2d
awk -F '\t' 'BEGIN{hasil = 0}
{
if($13 == "Central") i += $21
else if($13 == "East") j += $21
else if($13 == "South") k += $21
else if($13 == "West") l += $21
if(i<j && i<k && i<l){ 
kawasan = "Central"
hasil = p1
}
else if(j<i && j<k && j<l){
kawasan = "East"
hasil = p2
}
else if(k<i && k<j && k<l){
kawasan = "South"
hasil = p3
}
else if(l<i && l<j && l<k){
kawasan = "West"
hasil = p4
}
}
END
{print "Wilayah bagian (region) yang memiliki total keuntungan (profit) yang paling sedikit adalah %s dengan total keuntungan %f\n", kawasan, hasil
}' Laporan-TokoShiSop.tsv >> hasil.txt
