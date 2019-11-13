#execComments: no need to compile, to run type <bash name.sh> or <./name.sh>
#!bash/bin

#var="-l"
#eval "ls $var"

#read input
#eval "ls $input"


echo "--------------------------------------------------------------------------------------"
eval "gcc IVgen.c -o IV"
eval "gcc KEYgen.c -o KEY"
eval "gcc TAGgen.c -o TAG"
eval "make -f makefileAES"
eval "make -f makefileSHA"
echo "--------------------------------------------------------------------------------------"
echo -e

while true; do


	echo -e
	echo "Choose 1 or 2 or 3 for one of the following"
	echo "1: Encrypt a local txt file (as listed above) and store it on google drive"
	echo "2: Decrypt a file on google drive back onto your machine"
	echo "3: EXIT"
	echo -e

	read userinput

	if [[ "$userinput" == 1 ]]; then
		echo "-----List of local Text Files-----"
                eval "ls | grep .txt"
                echo -e "----------------------------------"

		echo -e "Enter in a plain text .txt file you want to encrypt (Case Sensitive):"
		read inputfile
		echo "Enter in a desired file name that will represent the encryped file (Format: <filename>.txt):"
 		read outputfile
		IV=$(eval "./IV $inputfile")
		KEY=$(eval "./KEY $inputfile")
		eval "./cryptomaniac $inputfile $outputfile -mctr -e -k $KEY -i $IV"
		TAG=$(eval "./TAG $inputfile")
		eval "cat $outputfile | ./hmacsha256 $TAG"

		eval "gdrive upload $outputfile"
		eval "gdrive upload tag.txt"
		eval "rm $inputfile"
		eval "rm tag.txt"
	fi

	if [[ "$userinput" == 2  ]]; then

		eval "gdrive list"
		unset inputfile
		echo -e "Enter in the Encrypted txt file in google drive you want to dycrypt:" #get txt file from gdrive
		read inputfile
		echo "Enter in the <filename>TAG.txt name:" #get key to run cat <filename> | ./hmacsha256 $TAG
		read TAGfile;

		fileID=$(eval "gdrive list | grep $inputfile | awk '{print $1}'")
		eval "gdrive download $fileID"
		tagID=$(eval "gdrive list | grep tag.txt | awk '{print $1}'")
		eval "gdrive download $tagID"

		while IFS='' read -r line || [[ -n "$line" ]]; do
                        TAG1=$line #tag 1 is the tag from the gdrive (tag computed during encryption)
                done < "$tag.txt"
		eval "rm tag.txt"

		while IFS='' read -r line || [[ -n "$line" ]]; do
                        tagKEY=$line
                done < "$Tagfile"

		eval "cat $inputfile | ./hmacsha256 $tagKEY"

		while IFS='' read -r line || [[ -n "$line" ]]; do
                        TAG2=$line #tag 2 is computed just now 
                done < "$tag.txt"
		eval "rm tag.txt"

		if [ "$TAG1" -ne "$TAG2"  ]
		then
			echo "Corrupted file, exiting"
			exit 1
		fi
#--------------------------------------------------------------------------------------------------------
		unset IV
		unset KEY
		echo -e
		eval "ls | grep .txt"

		echo -e "Enter in the <filename>KEY.txt name for the file you want to decrypt:"
		read KEYfile
		while IFS='' read -r line || [[ -n "$line" ]]; do
   			KEY=$line
		done < "$KEYfile"


		echo "Enter in the <filename>IV.txt name for the file you want to decrypt:"
		read IVfile
		while IFS='' read -r line || [[ -n "$line" ]]; do
   			IV=$line
		done < "$IVfile"
#-------------------------------------------------------------------------------------------------------
		unset outputfile
		echo "Enter any desired <file name>.txt for the output:"
		read outputfile
		eval "./cryptomaniac $inputfile $outputfile -mctr -d -k $KEY -i $IV"
		echo "decrypted file is now: $outputfile | The IV.txt KEY.txt and TAG.txt file for the output file are now removed"
		eval "rm $TAG"
		eval "rm $KEYfile"
		eval "rm $IVfile"
        fi

	if [[ "$userinput" == 3  ]]; then
		echo "Exiting.."
		exit 1
        fi

	if [[ "$userinput" != 1 && "$userinput" != 2 && "$userinput" != 3   ]]; then
		echo "You chose $userinput"
		echo -e "Please enter in a correct number"
        fi



done
