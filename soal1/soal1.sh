#!/bin/bash

# File management
input="syslog.log"
error_output="error_message.csv"
user_output="user_statistic.csv"

# 1(a)
error_regex="(?<=ERROR )(.*)"
info_regex="(?<=INFO )(.*)"

# 1(b)
error_list=$(grep -oP "${error_regex}(?=\ )" "$input")
# echo "$error_list"
# echo -n "Jumlah ERROR: " 
# echo "$error_list" | wc -l

# 1(c)
username=()
error_count=()
info_count=()
while read p; do
	arr=($p)
	name=${arr[-1]}
	name=${name:1:-2}
	index=0
	# echo -n "$name "
	
	if [[ ! " ${username[*]} " =~ " $name " ]]
	then 
		username+=("$name")
		error_count+=(0)
		info_count+=(0)
	fi

	if [[ $p = *ERROR* ]]
	then
		for temp in "${username[@]}"
		do 
			if [[ "$temp" == "$name" ]]
			then
				# echo $temp
				# echo $index
				break
			fi
			let index+=1
		done
		let error_count[index]+=1
		# echo -n "${username[$index]}"
		# echo "${error_count[$index]}"
	else 
		for temp in "${username[@]}"
		do 
			if [[ "$temp" == "$name" ]]
			then
				# echo $temp
				# echo $index
				break
			fi
			let index+=1
		done
		let info_count[index]+=1
	fi
done < $input

# 1(d) 
echo "Error,Count" > $error_output
grep -oP "${error_regex}(?=\ )" "$input" | sort | uniq -c | sort -nr | grep -oP "^ *[0-9]+ \K.*" | while read -r error_log
do
	count=$(grep "$error_log" <<< "$error_list" | wc -l)
	echo -n "${error_log}," >> $error_output
	echo "$count" >> $error_output
done 

# 1(e)
echo -n "" > $user_output
let len=${#username[*]}
for ((it=0; it<$len; it+=1))
do 
	# echo "$it"
	echo -n "${username[$it]}," >> $user_output
	echo -n "${info_count[$it]}," >> $user_output
	echo "${error_count[$it]}" >> $user_output
done
user_output_sorted=$(cat $user_output | sort | uniq )
echo "Username,INFO,ERROR" > $user_output
echo "$user_output_sorted" >> $user_output

# echo "${username[*]}"
# echo "${error_count[*]}"
# echo "${info_count[*]}"

# cat $error_output
# cat $user_output
