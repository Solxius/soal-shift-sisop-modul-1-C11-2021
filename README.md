# soal-shift-sisop-modul-1-C11-2021
## Anggota
* James Raferty Lee 	(05111940000055)
* Mohammad Tauchid		(05111940000136)
* Kevin Davi Samuel		(05111940000157)

# Soal dan Penjelasan Jawaban
## Soal Nomor 1
Ryujin baru saja diterima sebagai IT support di perusahaan Bukapedia. Dia diberikan tugas untuk membuat laporan harian untuk aplikasi internal perusahaan, ticky. Terdapat 2 laporan yang harus dia buat, yaitu laporan **daftar peringkat pesan error** terbanyak yang dibuat oleh ticky dan laporan **penggunaan user** pada aplikasi ticky. Untuk membuat laporan tersebut, Ryujin harus melakukan beberapa hal berikut:

**(a)** Mengumpulkan informasi dari log aplikasi yang terdapat pada file syslog.log. Informasi yang diperlukan antara lain: jenis log (ERROR/INFO), pesan log, dan username pada setiap baris lognya. Karena Ryujin merasa kesulitan jika harus memeriksa satu per satu baris secara manual, dia menggunakan regex untuk mempermudah pekerjaannya. Bantulah Ryujin membuat regex tersebut.

**(b)** Kemudian, Ryujin harus menampilkan semua pesan error yang muncul beserta jumlah kemunculannya.

**(c)** Ryujin juga harus dapat menampilkan jumlah kemunculan log ERROR dan INFO untuk setiap user-nya.

Setelah semua informasi yang diperlukan telah disiapkan, kini saatnya Ryujin menuliskan semua informasi tersebut ke dalam laporan dengan format file csv.

**(d)** Semua informasi yang didapatkan pada poin **b** dituliskan ke dalam file `error_message.csv` dengan header **Error,Count** yang kemudian diikuti oleh daftar pesan error dan jumlah kemunculannya **diurutkan** berdasarkan jumlah kemunculan pesan error dari yang terbanyak.

```
Contoh:
Error,Count
Permission denied,5
File not found,3
Failed to connect to DB,2
```

**(e)** Semua informasi yang didapatkan pada poin **c** dituliskan ke dalam file `user_statistic.csv` dengan header **Username,INFO,ERROR** diurutkan berdasarkan username secara ***ascending***.

```
Contoh:
Username,INFO,ERROR
kaori02,6,0
kousei01,2,2
ryujin.1203,1,3
```

**Catatan**:
- Setiap baris pada file **syslog.log** mengikuti pola berikut:

```
<time> <hostname> <app_name>: <log_type> <log_message> (<username>)
```
- **Tidak boleh** menggunakan AWK

## Jawaban Nomor 1
- Untuk memudahkan pengaturan file, digunakan sebuah variabel untuk menyimpan file.
```bash
input="syslog.log"
error_output="error_message.csv"
user_output="user_statistic.csv"
```

**(a)** Soal nomor 1(a), meminta kita untuk mengumpulkan informasi dari file `syslog.log`. Informasi yang diperlukan antara lain: jenis log (ERROR/INFO), pesan log, dan username pada setiap baris dengan menggunakan regex. Regex yang dapat digunakan antara lain:

```bash
error_regex="(?<=ERROR )(.*)"
info_regex="(?<=INFO )(.*)"
```

Log pada `syslog.log` dipisahkan berdasarkan tipenya (ERROR/INFO) dengan menggunakan regex. `error_regex` digunakan untuk menangani log yang bertipe ERROR, sementara `info_regex` digunakan untuk menangani log yang bertipe INFO. Untuk penjelasannya, bagian `(?<=ERROR )` / `(?<=INFO )` digunakan untuk mengelompokkan log sementara `(.*)` berfungsi untuk menyimpan pesan log.

**(b)** Soal nomor 1(b), meminta kita untuk menampilkan semua pesan error beserta jumlahnya. Untuk menampilkan semua pesan error, kita dapat memanfaatkan regex yang sudah kita buat. 

```bash
error_list=$(grep -oP "${error_regex}(?=\ )" "$input")
```

Kita dapat memanfaatkan fungsi grep dengan flag `-o` yang berfungsi untuk menampilkan output yang persis sama, dan flag `-P` untuk menggunakan pearl-regex. Lalu kita menggunakan `${error_regex}` yaitu regex yang telah dibuat untuk error log. Lalu `(?=\ )` digunakan untuk membuang username. Sebenarnya, tidak dibuang juga tidak masalah, namun kemungkinan akan memakan banyak memori. Lalu untuk menampilkan error dan jumlah kemunculannya, kita bisa menggunakan fungsi berikut.

```bash
echo "$error_list" 
echo "$error_list" | wc -l
```

`wc -l` pada baris dua, digunakan untuk menghitung berapa jumlah line (baris) pada `error_list`

**(c)** Soal nomor 1(c) meminta kita untuk menampilkan jumlah kemunculan log (ERROR/INFO) pada setiap usernya. Untuk melakukan hal tersebut, yang pertama dilakukan adalah membuat array untuk menyimpan nama user, jumlah error, dan jumlah info.

```bash
username=()
error_count=()
info_count=()
```

Setelah membuat array, lakukan looping untuk membaca tiap baris pada `syslog.log` dengan perulangan `while`. Lalu cek apakah nama user pada baris tersebut sudah terdapat pada array `username`. Jika tidak ada, tambahkan nama user ke dalam `username` lalu isi `error_count` dan `info_count` pada index yang sama dengan angka 0.

```bash
if [[ ! " ${username[*]} " =~ " $name " ]]
then 
	username+=("$name")
	error_count+=(0)
	info_count+=(0)
fi	
```

Kemudian, cek apakah log tersebut bertipe ERROR atau INFO. Jika ERROR, tambahkan `error_count` dengan 1 pada index yang sama dengan username, begitu pula dengan log bertipe INFO.

```bash
if [[ $p = *ERROR* ]]
then
	for temp in "${username[@]}"
	do 
		if [[ "$temp" == "$name" ]]
		then
			break
		fi
		let index+=1
	done
	let error_count[index]+=1
else 
	for temp in "${username[@]}"
	do 
		if [[ "$temp" == "$name" ]]
		then
			break
		fi
		let index+=1
	done
	let info_count[index]+=1
fi
```

**(d)** Untuk soal nomor 1(d), kita diminta untuk memasukkan semua jenis ERROR beserta kemunculannya pada `error_message.csv` dengan header `Error,Count` diurutkan secara ***descending***. Caranya adalah sebagai berikut.

```bash
grep -oP "${error_regex}(?=\ )" "$input" | sort | uniq -c | sort -nr | grep -oP "^ *[0-9]+ \K.*" | while read -r error_log
do
	count=$(grep "$error_log" <<< "$error_list" | wc -l)
	echo -n "${error_log}," >> $error_output
	echo "$count" >> $error_output
done 
```

Cara diatas masih menggunakan `error_regex` namun ada beberapa kondisi yang harus dipenuhi. Fungsi `sort` digunakan untuk mengurutkan jenis error secara ascending. Setelah itu dikelompokkan berdasarkan jenisnya dengan menggunakan `uniq -c`. Kemudian diurutkan secara descending dengan `sort -nr`. Lalu gunakan regex `^ *[0-9]+ \K.*` untuk menghilangkan angka dari log tersebut, sehingga hanya ada jenis error yang telah diurutkan secara descending berdasarkan jumlah kemunculannya. Lalu lakukan perulangan. `count=$(grep "$error_log" <<< "$error_list" | wc -l)` digunakan untuk menghitung kemunculan tiap baris pada `error_list` (jenis error) di `error_log` (semua error yang muncul). Kemudian masukkan dalam file.

**(e)** Soal 1(e) meminta kita memasukkan jumlah kemunculan error dan info pada setiap user ke dalam file `user_statistic.csv` dengan sebuah header `Username,INFO,ERROR` diurutkan berdasarkan `Username` secara ***ascending***. Kita bisa melakukannya dengan menggunakan iterasi.

```bash
for ((it=0; it<$len; it+=1))
do 
	echo -n "${username[$it]}," >> $user_output
	echo -n "${info_count[$it]}," >> $user_output
	echo "${error_count[$it]}" >> $user_output
done
```

Semua yang pada array, disimpan untuk sementara pada `user_statistic.csv`. Hal ini dikarenakan semua yang ada pada file masih belum urut. Untuk mengurutkannya, diperlukan sebuah variabel sementara untuk menyimpan hasil pengurutan sebelum dikembalikan ke `user_statistic.csv`. Caranya adalah sebagai berikut.

```bash
user_output_sorted=$(cat $user_output | sort | uniq )
echo "Username,INFO,ERROR" > $user_output
echo "$user_output_sorted" >> $user_output
```

## Soal Nomor 2
Steven dan Manis mendirikan sebuah startup bernama “TokoShiSop”. Sedangkan kamu dan Clemong adalah karyawan pertama dari TokoShiSop. Setelah tiga tahun bekerja, Clemong diangkat menjadi manajer penjualan TokoShiSop, sedangkan kamu menjadi kepala gudang yang mengatur keluar masuknya barang.

Tiap tahunnya, TokoShiSop mengadakan Rapat Kerja yang membahas bagaimana hasil penjualan dan strategi kedepannya yang akan diterapkan. Kamu sudah sangat menyiapkan sangat matang untuk raker tahun ini. Tetapi tiba-tiba, Steven, Manis, dan Clemong meminta kamu untuk mencari beberapa kesimpulan dari data penjualan “Laporan-TokoShiSop.tsv”.

**(a)** Steven ingin mengapresiasi kinerja karyawannya selama ini dengan mengetahui Row ID dan profit percentage terbesar (jika hasil profit percentage terbesar lebih dari 1, maka ambil Row ID yang paling besar). Karena kamu bingung, Clemong memberikan definisi dari profit percentage, yaitu:

Profit Percentage = (Profit/Cost Price)*100

Cost Price didapatkan dari pengurangan Sales dengan Profit. (Quantity diabaikan).

**(b)** Clemong memiliki rencana promosi di Albuquerque menggunakan metode MLM. Oleh karena itu, Clemong membutuhkan daftar nama customer pada transaksi tahun 2017 di Albuquerque.

**(c)** TokoShiSop berfokus tiga segment customer, antara lain: Home Office, Customer, dan Corporate. Clemong ingin meningkatkan penjualan pada segmen customer yang paling sedikit. Oleh karena itu, Clemong membutuhkan segment customer dan jumlah transaksinya yang paling sedikit.

**(d)** TokoShiSop membagi wilayah bagian (region) penjualan menjadi empat bagian, antara lain: Central, East, South, dan West. Manis ingin mencari wilayah bagian (region) yang memiliki total keuntungan (profit) paling sedikit dan total keuntungan wilayah tersebut.

## Jawaban Nomor 2

**(a)** 
```awk -F '\t ''BEGIN{max = 0}
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
```
**(b)**
```awk -F '\t''BEGIN{
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
```
**(c)**
```awk -F '\t' 'BEGIN{t = 0}
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
```
**(d)**
```awk -F '\t' 'BEGIN{hasil = 0}
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
```

## Soal Nomor 3
Kuuhaku adalah orang yang sangat suka mengoleksi foto-foto digital, namun Kuuhaku juga merupakan seorang yang pemalas sehingga ia tidak ingin repot-repot mencari foto, selain itu ia juga seorang pemalu, sehingga ia tidak ingin ada orang yang melihat koleksinya tersebut, sayangnya ia memiliki teman bernama Steven yang memiliki rasa kepo yang luar biasa. Kuuhaku pun memiliki ide agar Steven tidak bisa melihat koleksinya, serta untuk mempermudah hidupnya, yaitu dengan meminta bantuan kalian. Idenya adalah :

**(a)** Membuat script untuk mengunduh 23 gambar dari "https://loremflickr.com/320/240/kitten" serta menyimpan log-nya ke file "Foto.log". Karena gambar yang diunduh acak, ada kemungkinan gambar yang sama terunduh lebih dari sekali, oleh karena itu kalian harus menghapus gambar yang sama (tidak perlu mengunduh gambar lagi untuk menggantinya). Kemudian menyimpan gambar-gambar tersebut dengan nama "Koleksi_XX" dengan nomor yang berurutan tanpa ada nomor yang hilang (contoh : Koleksi_01, Koleksi_02, ...)

**(b)** Karena Kuuhaku malas untuk menjalankan script tersebut secara manual, ia juga meminta kalian untuk menjalankan script tersebut sehari sekali pada jam 8 malam untuk tanggal-tanggal tertentu setiap bulan, yaitu dari tanggal 1 tujuh hari sekali (1,8,...), serta dari tanggal 2 empat hari sekali(2,6,...). Supaya lebih rapi, gambar yang telah diunduh beserta log-nya, dipindahkan ke folder dengan nama tanggal unduhnya dengan format "DD-MM-YYYY" (contoh : "13-03-2023").

**(c)** Agar kuuhaku tidak bosan dengan gambar anak kucing, ia juga memintamu untuk mengunduh gambar kelinci dari "https://loremflickr.com/320/240/bunny". Kuuhaku memintamu mengunduh gambar kucing dan kelinci secara bergantian (yang pertama bebas. contoh : tanggal 30 kucing > tanggal 31 kelinci > tanggal 1 kucing > ... ). Untuk membedakan folder yang berisi gambar kucing dan gambar kelinci, nama folder diberi awalan "Kucing_" atau "Kelinci_" (contoh : "Kucing_13-03-2023").

**(d)** Untuk mengamankan koleksi Foto dari Steven, Kuuhaku memintamu untuk membuat script yang akan memindahkan seluruh folder ke zip yang diberi nama “Koleksi.zip” dan mengunci zip tersebut dengan password berupa tanggal saat ini dengan format "MMDDYYYY" (contoh : “03032003”).

**(e)** Karena kuuhaku hanya bertemu Steven pada saat kuliah saja, yaitu setiap hari kecuali sabtu dan minggu, dari jam 7 pagi sampai 6 sore, ia memintamu untuk membuat koleksinya ter-zip saat kuliah saja, selain dari waktu yang disebutkan, ia ingin koleksinya ter-unzip dan tidak ada file zip sama sekali.

## Jawaban Nomor 3

**(a)** 
```bash
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
```

Pertama, kita mendownload 23 gambar kucing dari website yang diberi. Kita menggunakan 'wget -a /home/solxius/Desktop/Sisop/Modul1/Foto.log' untuk men-append log kepada Foto.log. Kita menggunakan '-O /home/solxius/Desktop/Sisop/Modul1/kitten"$a".jpeg' supaya gambar yang didownload memiliki nama "kitten(angka-sekarang).jpeg" supaya mudah diorganisir.

```bash
wget -a /home/solxius/Desktop/Sisop/Modul1/Foto.log "https://loremflickr.com/320/240/kitten" -O /home/solxius/Desktop/Sisop/Modul1/kitten"$a".jpeg
```

Selanjutnya, kita mengerti bahwa di dalam log terdapat lokasi gambar di dalam website, sehingga kita dapat menggunakan itu untuk mengidentifikasi gambar yang duplikat. Jadi, kita menggunakan "awk '/Location/ {print $2}' Foto.log >> check.log" untuk mencari lokasi link dari setiap gambar dan menaruhkannya di check.log. Lalu, kita membuat check.log menjadi array, supaya bisa dengan mudah dicek oleh program. Gambar indeks ke-0 memiliki lokasi di array indeks ke-0, dan selanjutnya.

```bash
awk '/Location/ {print $2}' Foto.log >> check.log

readarray myarray < check.log
indexo=0
```

Lalu, kita looping, dan untuk setiap gambar, kita mengecek linknya dengan segala link gambar di sebelumnya. Contohnya, gambar indeks ke-2 akan dicek dengan gambar ke-1 dan ke-0. Jika ada yang memiliki link lokasi yang sama, dikasih flag 1. Jika flag 1, dihapus.

Jika flag-nya 0, jadi gambar tersebut tidak duplikat kepada gambar apapun di sebelumnya, jadi kita mengganti namanya dengan indeks yang benar. Variabel indexo untuk namanya, supaya kita mengetahui sementara gambar nomor berapa. Lalu, setelah semua selesai, tinggal menghapus check.log.

```bash
indexo=$(($indexo + 1)) 
zerotwodee=$(printf "Koleksi_%02d" "$indexo")
mv /home/solxius/Desktop/Sisop/Modul1/kitten"$a".jpeg /home/solxius/Desktop/Sisop/Modul1/$zerotwodee.jpeg
```

**(b)** 
```bash
#!/bin/bash

mkdir /home/solxius/Desktop/Sisop/Modul1/$(date '+%d-%m-%Y')

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
		mv /home/solxius/Desktop/Sisop/Modul1/kitten"$a".jpeg /home/solxius/Desktop/Sisop/Modul1/$(date '+%d-%m-%Y')/$zerotwodee.jpeg
	else
		rm /home/solxius/Desktop/Sisop/Modul1/kitten"$a".jpeg
	fi
done

mv /home/solxius/Desktop/Sisop/Modul1/Foto.log /home/solxius/Desktop/Sisop/Modul1/$(date '+%d-%m-%Y')/Foto.log

rm check.log
```

Soal 3b hampir sama persis dengan 3a. Perbedaannya hanya saat pemindahan file. Jika flag sama dengan 0, dipindah ke folder '$(date '+%d-%m-%Y')', yaitu tanggal sekarang. 
```bash
mv /home/solxius/Desktop/Sisop/Modul1/kitten"$a".jpeg /home/solxius/Desktop/Sisop/Modul1/$(date '+%d-%m-%Y')/$zerotwodee.jpeg
```

Foto.log juga dipindah ke folder tersebut.

```bash
0 20 1,8,15,22,29,2,6,10,14,18,26,30 * * bash soal3b.sh
```

Arti dari crontab di atas adalah bahwa pada setiap tanggal di atas (yaitu setiap 7 hari dari tanggal 1, dan setiap 4 hari dari tanggal 2), pada jam 20:00, akan dijalankan program soal3b.sh.

**(c)** 

```bash
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
```

Kerangka dari 3c mirip dengan 3a, dengan beberapa perbedaan. Pertama, terdapat variable direcname, creaturename, dan lastname. direcname untuk mengetahui nama folder yang akan dibuat, creaturename untuk mengetahui format nama gambar, dan lastname untuk mengetahui format nama akhir. Karena disuruh bergantian, kita menggunakan if. Jika tanggal sekarang genap, akan mendownload kucing, jika ganjil, akan mendownload kelinci.
```bash
if [ $(($(date '+%d')%2)) -eq 0  ]
```

Akhirnya, dengan variabel baru sebelumnya, tinggal memindahkan gambar yang tidak duplikat sesuai direcname, creaturename, dan lastname.

**(d)** 
```bash
#!/bin/bash

cd /home/solxius/Desktop/Sisop/Modul1/
zip --password "$(date '+%m%d%Y')" -rm Koleksi.zip */
```

Pertama, kita pindah ke folder yang mengandung folder-folder, supaya tidak dengan tidak sengaja men-zip file di home. 

Selanjutnya, kita menzip dengan command zip. --password digunakan supaya kita men-zip dengan password, dan "$(date '+%m%d%Y')" setelahnya adalah passwordnya, dengan format mm-dd-yyyy tanggal sekarang. -r digunakan agar men-zip folder secara rekursif. -m digunakan supaya folder yang di-zip dihapuskan setelah di-zip. Koleksi.zip adalah nama zip yang ingin kita buat. */ adalah wildcard yang artinya adalah semua folder.

**(e)** 
```bash
0 7 * * 1-5 bash /home/solxius/Desktop/Sisop/Modul1/soal3d.sh
0 18 * * 1-5 cd /home/solxius/Desktop/Sisop/Modul1/ && unzip -P `date +\%m\%d\%Y` Koleksi.zip && rm Koleksi.zip
```

Artinya adalah saat jam 7.00 setiap hari senin-jumat, akan dijalankan soal3d.sh di direktori /home/solxius/Desktop/Sisop/Modul1/.

Arti line ke-2 adalah, pada saat jam 18.00 setiap hari senin-jumat (sabtu dan minggu tidak diperlukan karena orang ini hanya men-zip saat dia kuliah), akan pindah ke folder yang mengandung folder gambar. Lalu, men-unzip Koleksi.zip dengan password `date +\%m\%d\%Y`, yaitu tanggal sekarang dengan format mm-dd-yyyy tanggal sekarang (password yang kita pakai pada nomor 3d. Terakhir, tinggal dihapus Koleksi.zip.
