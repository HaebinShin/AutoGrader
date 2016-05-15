#!/usr/bin/env bash

# grading all codes in the same directory
# usage : ./grade.sh

function is_exist_txt(){
	if test -e ./"$inputfile"; then
		if test -e ./"$answerfile"; then
			return 0
		else
			echo "Error : Not exist answer.txt in this directory"
		fi
	else
		echo "Error : Not exist input.txt in this directory"
	fi

	return 1
}

function is_correct_extension(){
	for i in "${extensionarr[@]}"
	do
		if [ "$i" = "$1" ]; then
			return 0
		fi
	done
	return 1
}

function compare(){
DIFF="$(diff <(sed -e '$a\' $outputfile) <(sed -e '$a\' ./$answerfile))"
if [ "$DIFF" != "" ]
then
  echo 1
else
  echo 0
fi
}

function get_result(){
  com=0
	case "$extension" in
		c )
			gcc -o "$compiledname".out "$file" >& /dev/null || com=3
      if [ "$com" -ne 3 ]
      then
        ./"$compiledname".out < ./"$inputfile" > "$outputfile"
      fi
      ;;
		cpp )
			g++ -o "$compiledname".out "$file" >& /dev/null || com=3
      if [ "$com" -ne 3 ]
      then
        ./"$compiledname".out < ./"$inputfile" > "$outputfile"
      fi
      ;;
		java )
			javac "$file" >& /dev/null || com=3
      if [ "$com" -ne 3 ]
      then
        java "$file_name" < ./"$inputfile" > "$outputfile"
        mv "$file_name".class "$compiledname".class
      fi
      ;;
		py )
      python "$file" < ./"$inputfile" >& /dev/null || com=3
      if [ "$com" -ne 3 ]
      then
        python "$file" < ./"$inputfile" > "$outputfile"
      fi
      ;;
		* )
			echo 2 ;;
	esac
  if [ "$com" -ne 3 ]
  then
    test -e "$compiledname".* && rm "$compiledname".*
    com=`compare`
    test -e "$outputfile" && rm "$outputfile"
  fi
  echo "$com"
}


declare -r inputfile="input.txt"
declare -r answerfile="answer.txt"
declare -a extensionarr=("c" "cpp" "java" "py")
if [ "$(uname)" == "Darwin" ]; then
  declare -a resultarr=(
    "\x1B[92mCorrect\x1B[39m" 
    "\x1B[91mWrong\x1B[39m" 
    "Can not grade this file extension" 
    "\x1B[94mCompile Error\x1B[39m" )
else
  declare -a resultarr=(
    "\e[92mCorrect\e[39m" 
    "\e[91mWrong\e[39m" 
    "Can not grade this file extension" 
    "\e[94mCompile Error\e[39m" )
fi

if ! is_exist_txt; then
	exit 0
fi

for file in *
do
	IFS='.' read file_name extension <<< "$file"
	if ! is_correct_extension "$extension"; then
		continue
	fi

	timestamp=`date "+%Y%m%d_%H%M%S"`
	compiledname=compiled_"$timestamp"
	outputfile=output_"$timestamp".tmp

	res=`get_result`
  echo -e "$file\t${resultarr[$res]}"	
done
