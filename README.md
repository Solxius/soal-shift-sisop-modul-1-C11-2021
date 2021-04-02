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


