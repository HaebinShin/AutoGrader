#!/usr/bin/env bash

# grading all codes in the same directory
# usage : ./grade.sh

function is_exist_txt(){
	if test -e ./$inputfile; then
		if test -e ./$answerfile; then
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
		if [ $i = $1 ]; then
			return 0
		fi
	done
	return 1
}

function compare(){
	if diff <(sed -e '$a\' $outputfile) <(sed -e '$a\' ./$answerfile) ; then
		return 0
	else
		return 1
	fi
}

function get_result(){
	case $extension in
		c )
			gcc -o $compiledname.out $file || return 3
			./$compiledname.out < ./$inputfile > $outputfile ;;
		cpp )
			g++ -o $compiledname.out $file || return 3
			./$compiledname.out < ./$inputfile > $outputfile ;;
		java )
			javac $file || return 3
			java $file_name < ./$inputfile > $outputfile
			mv $file_name.class $compiledname.class ;;
		py )
			python $file < ./$inputfile > $outputfile ;;
		* )
			return 2 ;;
	esac
	test -e $compiledname.* && rm $compiledname.*
	compare
	test -e $outputfile && rm $outputfile
	return $?
}


declare -r inputfile="input.txt"
declare -r answerfile="answer.txt"
declare -a extensionarr=("c" "cpp" "java" "py")
declare -a resultarr=(
	"Correct" 
	"Wrong" 
	"Can not grade this file extension" 
	"Compile Error" )

if ! is_exist_txt; then
	exit 0
fi

for file in *
do
	IFS='.' read file_name extension <<< "$file"
	if ! is_correct_extension $extension; then
		continue
	fi

	timestamp=`date "+%Y%m%d_%H%M%S"`
	compiledname=compiled_$timestamp
	outputfile=output_$timestamp.tmp

	get_result
	echo -e "$file\t${resultarr[$?]}"	
done