#!/bin/bash

LOGDIR=$PWD/logs
errfil=$PWD/insert_sacad.err

if [ ! -d $LOGDIR ];then
  mkdir $LOGDIR
fi

if [ -e $errfil ];then
  rm $errfil
  #touch $errfil
fi

tmpstamp=`date +"%Y%m%d_%H_%M_%S"`
#echo "# $tmpstamp" > $errfil

#if [ -d $4 ];then
#  echo "deleting content of $4........"
#  rm $4/* -rf
#fi

if [ $# -lt 4 ];then
echo "Cara pakai:"
echo "      insert_sacad.sh  <PAR_ID> <KEY_FILE> <IN_DIR> <OUT_DIR>"
echo ""
exit
fi

echo $1 $2 $3 $4 > $errfil

indir=$3

for fl in $indir/data*.txt
do
/usr/people/imbangla/didah/official/insert_sacad_mod1.py $1 $2 $fl $4
done


mv $errfil $LOGDIR/$tmpstamp.insert_sacad.err

#diff -y logs/20130213_09_27_49.insert_sacad.err logs/20130213_09_31_07.insert_sacad.err
