#!/bin/bash

#cek 9999
# input :
#   $1 = input directory
#   $2 = output directory
#created by Bayu Imbang L,12 Feb 2013 @KNMI
#==========================================
indir=$1
outdir=$2

if [ $# -lt 2 ];then
echo "Cara pakai:"
echo "      cek_9999.sh <inDIR> <outDIR>"
echo ""
exit
fi

outfil=$PWD/9999.out

if [ ! -d $outdir ];then
  mkdir $outdir
fi

if [ -e $outfil ];then
   rm $outfil
fi

if [ -e $outfil.sort ];then
   rm $outfil.sort
fi

#echo "please wait......."
for fl in $indir/data*
do
  res=`awk '$3>5000' $fl | wc -l`
  #if [ $res -gt 0 ];then
  echo "$fl $res" >> $outfil
  #fi
  echo "$fl $res"
done

#sort -nk 2 $outfil | awk '$2>0 {print}' > $outfil.sort
sort -nk 2 $outfil > $outfil.sort

cat $outfil.sort | while read LINE
do
  nmfil=`echo $LINE | awk '{print $1}'`
  res=`echo $LINE | awk '{print $2}'`
  tmp=`echo $LINE | awk '{print $1}' | awk -F"/" '{print $2}'`
  if [ $res -gt 0 ];then
  echo "reformat $nmfil to $outdir/$tmp ........."
  awk '{if ($3>5000) print $1,$2,-9999;else print $1,$2,$3;}' $nmfil > $outdir/$tmp
  else
  echo "Copying $nmfil to $outdir/$tmp ........."
  cp $nmfil $outdir/$tmp
  fi
done
