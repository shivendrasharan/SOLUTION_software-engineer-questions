# ! /bin/sh

#shell script using jq tool to parse json file
#please install jq using steps provided at https://www.cyberithub.com/how-to-install-jq-json-processor-on-rhel-centos-7-8
#place the data.json file along with the script at any location
#give execute permissions to the script and execute it to get the desired output.

scriptLocation="`pwd`"

file="$scriptLocation/data.json"

uniqueRecords="$scriptLocation/unique.json"
touch $uniqueRecords
cat /dev/null > $uniqueRecords

size=`jq '. | length' $file`

i=0 #initialize the counter

while [[ $i -lt $size ]]
do
	jsonName[$i]="`jq .[$i].name $file | sed -e 's/^"//' -e 's/"$//'`"
	jsonAddress[$i]="`jq .[$i].address $file | sed -e 's/^"//' -e 's/"$//'`"
	jsonZip[$i]="`jq .[$i].zip $file | sed -e 's/^"//' -e 's/"$//'`"
	jsonId[$i]="`jq .[$i].id $file | sed -e 's/^"//' -e 's/"$//'`"

	#echo ${jsonName[$i]} "|" ${jsonAddress[$i]} "|" ${jsonZip[$i]} "|" ${jsonId[$i]}

	#check for null or missing name
	if [[ "${jsonName[$i]}" == "" || "${jsonName[$i]}" == "null" ]]; then
		echo ${jsonId[$i]}
		(( i=$i+1 ))
		continue;
	fi

	#check for null or missing address
	if [[ "${jsonAddress[$i]}" == "" || "${jsonAddress[$i]}" == "null" ]]; then
		echo ${jsonId[$i]}
		(( i=$i+1 ))
		continue;
	fi

	#check for null or missing zip
	if [[ "${jsonZip[$i]}" == "" || "${jsonZip[$i]}" == "null" ]]; then
		echo ${jsonId[$i]}
		(( i=$i+1 ))
		continue;
	else
		#check for invalid zip string size
		zipLength="`echo ${jsonZip[$i]} | tr -d '\n' | wc -c`"
		if [ $zipLength -ne 5 ]; then
			echo ${jsonId[$i]}
			(( i=$i+1 ))
			continue;
		fi
	fi

	#check for duplicate but valid record
	checkDuplicate="${jsonName[$i]} | ${jsonAddress[$i]} | ${jsonZip[$i]}"
	uniqueLine="${jsonName[$i]} | ${jsonAddress[$i]} | ${jsonZip[$i]} | ${jsonId[$i]}"
	hasDuplicate="`grep "$checkDuplicate" $uniqueRecords | wc -l`"
	if [ $hasDuplicate -eq 0 ]; then
		(echo "$uniqueLine") >> $uniqueRecords
	else
		echo ${jsonId[$i]}
		duplicateId="`grep "$checkDuplicate" $uniqueRecords | cut -d '|' -f 4 | tr -d ' '`"
		echo $duplicateId
		(( i=$i+1 ))
		continue;
	fi

	(( i=$i+1 ))
done
