#!/bin/bash

# dibuat : bayu imbang, 7 Feb 2012
# =================================
# objective : membuat key-file

if [ $# -lt 2 ];then
  echo "bil_make_key_file.sh <input DIR> <output file>"
  echo "==========================================="
  exit
fi

wmocode=/usr/people/imbangla/didah/official/sta_id.txt
database=didah

echo -n "Are you going to retrieve ID stations data ? (y/n)"
read hasil
if [ $hasil == "y" ] || [ $hasil == "Y" ];then
  echo "updating stations..............."
	mysql -udiddba -pQhL40K -hbwdb04 $database --skip-column-names -e"select concat(sta_id,',',name,',',wmocode,',',lat) from stations where coun_id='id'" > $wmocode	
fi

indir=$1
outfil=$2

if [ -e $outfil ];then
  rm $outfil	
fi

maxserid=$(mysql -udiddba -pQhL40K -hbwdb04 $database --skip-column-names -e"select max(ser_id) from series;")
serid=$maxserid

echo -e "WMOcode\tName\tSta_id\tLat\trr\thu\tpp\tss\ttg\ttx\ttn\tfg\tdd\tfx" >> $outfil

#ls ./data.* > fake.tmp

#ls $indir/data*.txt | awk -F. '{print $2}' | uniq -c > key.tmp
ls $indir/data*.txt > key.tmp1

cat key.tmp1 | while read LINE; do basename $LINE; done | awk -F. '{print $2}' | uniq -c > key.tmp

#for FILE in  $indir/*tn*.txt
echo "Creating key file ................."

cat key.tmp | while read FILE
do
  #FILE=$(basename "$FILE")
  wmo=`echo $FILE | awk '{print $2}'`
  echo $wmo
  #export WMO=$wmo
  brs=`awk -F, -v VAR=$wmo '$3==VAR {print}' $wmocode`
  if [ $? -ne 0 ]
  then
    echo "station $wmo can't be found."
    exit

  fi
  name=`echo $brs | awk -F, '{print $2}'`
  staid=`echo $brs | awk -F, '{print $1}'`
  stalat=`echo $brs | awk -F, '{print $4}'`
  tmp=${#stalat}
  if [ $tmp -gt 6 ];then
	stalat=-9999
  else
  	stalat=`echo "scale=1; $stalat/3600" | bc -l`
  fi
  # rr
  cekfl=$indir/data.$wmo.rr.txt
  if [ -e $cekfl ];then
  	let serid="$serid+1"
  	rr=$serid
  else
	rr=///
  fi
  # hu
  cekfl=$indir/data.$wmo.hu.txt
  if [ -e $cekfl ];then
  	let serid="$serid+1"
  	hu=$serid
  else
	hu=///
  fi  
# pp
  cekfl=$indir/data.$wmo.pp.txt
  if [ -e $cekfl ];then
  	let serid="$serid+1"
  	pp=$serid
  else
	pp=///
  fi  
# ss
  cekfl=$indir/data.$wmo.ss.txt
  if [ -e $cekfl ];then
  	let serid="$serid+1"
  	ss=$serid
  else
	ss=///
  fi  
# tg
  cekfl=$indir/data.$wmo.tg.txt
  if [ -e $cekfl ];then
  	let serid="$serid+1"
  	tg=$serid
  else
	tg=///
  fi  
# tx
  cekfl=$indir/data.$wmo.tx.txt
  if [ -e $cekfl ];then
  	let serid="$serid+1"
  	tx=$serid
  else
	tx=///
  fi
  # tn
  cekfl=$indir/data.$wmo.tn.txt
  if [ -e $cekfl ];then
  	let serid="$serid+1"
  	tn=$serid
  else
	tn=///
  fi
  # fg
  cekfl=$indir/data.$wmo.fg.txt
  if [ -e $cekfl ];then
  	let serid="$serid+1"
  	fg=$serid
  else
	fg=///
  fi
  # dd
  cekfl=$indir/data.$wmo.dd.txt
  if [ -e $cekfl ];then
  	let serid="$serid+1"
  	dd=$serid
  else
	dd=///
  fi
  # fx
  cekfl=$indir/data.$wmo.fx.txt
  if [ -e $cekfl ];then
  	let serid="$serid+1"
  	fx=$serid
  else
	fx=///
  fi

   
  printf "%s\t%s\t%s\t%s\t" "$wmo" "$name" "$staid" "$stalat" >> $outfil
  printf "%s\t%s\t%s\t%s\t" $rr $hu $pp $ss >> $outfil
  printf "%s\t%s\t%s\t%s\t%s\t%s\n" $tg $tx $tn $fg $dd $fx >> $outfil
  #printf "%-8s %-8s %-8s\n" "$wmo" "$staid" "$stalat" >> $outfil
  #echo $wmo $name $staid
done
