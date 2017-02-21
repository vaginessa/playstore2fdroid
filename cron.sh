#!/bin/bash
RACCOON="/raccoonArchive"
FDROID="/fdroid"
OWNER="core:core"

function moveAPK {
	input="$1"
	output="$2"
	ln -s $input $output
	chown $OWNER $output
}


function moveRecursive {
	for item in `ls "$1"` ; do
		if [ -d "$1" ]
		then
			file="$1/$item"
		else
			file="$item"
		fi

		if [ -d "$file" ]
		then
  			moveRecursive "$file"
		else
			FILEEXT=${file##*.}
			FILENAME=`basename "$file"`
			FILENAME=${FILENAME%.*}
			FILEPATH=`/usr/bin/dirname "$file"`
			if [ $FILEEXT == "apk" ]
			then
				moveAPK "$FILEPATH/$FILENAME.$FILEEXT" "$FDROID/repo/$FILENAME.apk"
			fi
		fi
	done
}

#check if there is something to import
if [ -f "/import.txt"]
then
	java -jar /bin/raccoon.jar -a $RACCOON -i /import.txt
fi

java -jar /bin/raccoon.jar -a $RACCOON -u

#check if config is available
if [ -f "$FDROID/config.py" ]
then
	cd $FDROID
  fdroid init
fi

# Link all APKs to FDroid Repo
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
moveRecursive $RACCOON
IFS=$SAVEIFS

cd $FDROID
# Update Fdroid and creat Metadata if needed
fdroid update -c
