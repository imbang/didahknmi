#!/bin/bash

# ====================================================================
# created by Bayu Imbang L, 20 Feb 2013 @KNMI
# objective : retrieve data dari file CSV Pak Urip -> data.WMO.ELE.txt
# ====================================================================

tmpfile=urip.tmp
cmd=`ls $tmpfile* | wc -l`
if [ $cmd -ne 0 ];then
rm $tmpfile*
fi

for fl in ./*
do
echo $fl
wmo=`echo $fl | awk -F_ '{print $1}'`
wmo=`echo $wmo | awk -F/ '{print $2}'`
sed -n '6,$p' $fl > $tmpfile.$wmo
done

for fl in $tmpfile*
do
echo "Creating fklim.$wmo.csv ...."
wmo=`echo $fl | awk -F. '{print $3}'`
awk -F, -v VAR=$wmo '{print VAR","$2","$3","$4","$8","$9","$10","$11","$12"," \
                 $14","$19","$20","$21","$22}' $fl > fklim.$wmo.csv
done
