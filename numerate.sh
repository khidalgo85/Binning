#!/bin/bash
################################################################################################
# Author: 		Paul Weibert (paul.weibert@gmail.com)
# Version:		0.1
# Dependencies: ls, sort, printf, mv, grep
# Features: 	Performs numbering of files from the specified input folder. 
#				Input files are sorted before numbering. Leading zeros can be added
# 				to the targetnumber (option -L <number of digits>).  Also a pre- and a suffix can be 
#				added to the target name (-p and -s). The sorting method can be specified (-o); 				
################################################################################################

PATHTOFOLDER=""
PREFIX=""
SUFFIX=""
SORT="numerically"
NUMBER=$(( 0 ))
LSCOMMAND="ls -1"
DIGITFORMAT="%d";
RENAME=0
GREPCMD="grep"
FILTER="\'.*\'" #match all by default

# define print function for error messages
echoerr(){ echo "$@" 1>&2;}

# prints usage information
printUsage(){ 
	echoerr "usage: numerate -d \"<path to filefolder>\" [-p \"<file prefix>\"] [-s \"<file suffix>\"] [-b <first number of target file>] [-o <order input={numerically/extension/modtime/none}>] [-L <number of digits in target number>] [-f <filename filter in grep syntax>]";
}

OPTIND=1 #Reset (just in case of prior usage)
while getopts "d:p:s:b:L:o:rf:" opt 
do
#Parse arguments
	case $opt in
		d) PATHTOFOLDER="$OPTARG";;
		p) PREFIX="$OPTARG";;
		s) SUFFIX="$OPTARG";;
		b) NUMBER="$OPTARG";;
		o) SORT="$OPTARG";;
		L) DIGITFORMAT="%0""$OPTARG""d";;
		r) RENAME=1;;
		f) FILTER="$OPTARG";;
		?) printUsage;
		   exit 1;;
	esac
done

#directory parameter is mandatory
if [ "$PATHTOFOLDER" == "" ] || [ ! -d "$PATHTOFOLDER" ]; then
	printUsage
exit 1;
fi

#parse sorting parameter for the input files
echo "Set file filter to: $FILTER"
case $SORT in 
	"modtime") 
		files=$($LSCOMMAND $PATHTOFOLDER -t | $GREPCMD "$FILTER");;
	"extension") 
		files=$($LSCOMMAND $PATHTOFOLDER -X | $GREPCMD "$FILTER");;
	"none") 
		files=$($LSCOMMAND $PATHTOFOLDER -U | $GREPCMD "$FILTER");;
	"numerically") 
		files=$($LSCOMMAND $PATHTOFOLDER -U | $GREPCMD "$FILTER" | sort -n );;
	*) 
		echoerr "unvalid order parameter -o <param>!"
		printUsage;
		exit 1;;
esac


# save value before changing it
TMPIFS=$IFS
IFS=$( echo -en "\n\b")
# perform / simulate rename operations
for f in $files;
do
		## format number
		NUMBERSTR=$( printf "$DIGITFORMAT" $NUMBER ) 
		SOURCE="$PATHTOFOLDER/$f"
		TARGET="$PATHTOFOLDER/$PREFIX$NUMBERSTR$SUFFIX"
		PROCESSDESCRIPTION="simulating rename"
		
		if [ $RENAME == 1 ];
		then 
			PROCESSDESCRIPTION="performing rename"
			mv $SOURCE $TARGET
		fi
		
		echo "$PROCESSDESCRIPTION \"$SOURCE\" to \"$TARGET\"";
		
		NUMBER=$(( $NUMBER + 1 ))
done

IFS=$TMPIFS