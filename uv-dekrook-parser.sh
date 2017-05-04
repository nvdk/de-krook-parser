#!/bin/bash

# this is a wrapper script that provides integration with unified views.
# place the jar and this script in the shell scripts directory of unified views	
CONFIG=$1
OUTPUT_PATH=$2
YEAR=`date "+%Y"`
BASEDIR=`dirname $0`
DOWNLOADURL=`head -n 1 $CONFIG | xargs`
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


for x in Locatie Werk Exemplaar Uitlening_Lener_$YEAR Uitlening_Tijd_$YEAR;do
  curl $DOWNLOADURL/$x.csv -s -o $WORKDIR/$x.csv &>> $LOGFILE
done

echo "finished downloading files" >> $LOGFILE
echo "java -jar dekrook-parser -i '$DIR' -c '$BASEDIR' -o '$OUTPUT_PATH'" >> $LOGFILE

pushd $BASEDIR
  /usr/bin/java -jar dekrook-parser.jar -i $WORKDIR -c $BASEDIR -o $OUTPUT_PATH &>> $LOGFILE
  SUCCESS=$?
  echo "finished parser with exit code $SUCCESS" >> $LOGFILE
popd
	
rm -r $WORKDIR
exit $SUCCESS
