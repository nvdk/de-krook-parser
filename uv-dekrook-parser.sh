#!/bin/bash

# this is a wrapper script that provides integration with unified views.
# place the jar and this script in the shell scripts directory of unified views	
CONFIG=$1
OUTPUT_PATH=$2
YEAR=`date "+%Y"`
BASEDIR=`dirname $0`
DOWNLOADURL=`head -n 1 $CONFIG | xargs`
EXTRA_OPTIONS=`sed -n 2p $CONFIG | xargs`
FILE=`sed -n 3p $CONFIG | xargs`
WORKDIR=/tmp/files-to-parse-$RANDOM
LOGFILE=/tmp/dekrookparser.log

echo "krook dataset parse log of `date`" > $LOGFILE
echo "called with params $1 $2 $3" >> $LOGFILE

if [[ $# -ne 2 ]]; then
		echo "error: expected 2 parameters but received $#" >> $LOGFILE
		echo "exiting" >> $LOGFILE
		exit -1;
fi

mkdir -p $WORKDIR

if [[ $FILE == "Uitlening_Tijd" || $FILE == "Uitlening_Lener" ]]; then
		FILE="${FILE}_${YEAR}";
fi

echo "downloading $DOWNLOADURL/$FILE.csv" >> $LOGFILE
curl "$DOWNLOADURL/$FILE.csv" -s -o $WORKDIR/$FILE.csv &>> $LOGFILE

echo "finished downloading files" >> $LOGFILE
echo "java -jar dekrook-parser -i '$WORKDIR' -c '$BASEDIR' -o '$OUTPUT_PATH'" $EXTRA_OPTIONS >> $LOGFILE

pushd $BASEDIR
  /usr/bin/java -jar dekrook-parser.jar -i "$WORKDIR" -c "$BASEDIR" -o "$OUTPUT_PATH" $EXTRA_OPTIONS &>> $LOGFILE
  SUCCESS=$?
  echo "finished parser with exit code $SUCCESS" >> $LOGFILE
popd
	
rm -r $WORKDIR
exit $SUCCESS
