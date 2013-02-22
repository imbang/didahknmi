#!/bin/bash

fakedir=fake
tmpfile=tmp.fake
#oridir=ori

if [ ! -d $fakedir ];then
  mkdir $fakedir
fi

#if [ ! -d $oridir ];then
#	mkdir $oridir
#fi


if [ -e $tmpfile ];then
	rm $tmpfile
fi

# menghilangkan file yg all -9999
for fl in data*.txt
do
	echo $fl
	l1=`cat $fl | wc -l`
	l2=`awk '$3==-9999 {print}' $fl | wc -l`
	if [ $l1 -eq $l2 ];then
		echo "Fake file...moving $fl"
		mv $fl $fakedir/
	fi
done

# menghilangkan data -9999 pada awal & akhir file
echo "============================================================"
echo "menghilangkan series -9999 pada awal dan akhir file........."
echo "============================================================"
for fl in data*.txt
do
	echo "$fl to bak.$fl"	
	l1=`cat $fl | wc -l`
	curbrs=`awk -f /usr/people/imbangla/didah/official/fake.awk $fl`
	endbrs=`cat $fl | sort -nrk 2 | awk -f /usr/people/imbangla/didah/official/fake.awk`	
	if [ $curbrs -eq 0 ];then
		curbrs=1
	else
		let curbrs=$curbrs+1
	fi
	cp $fl bak.$fl
	sed -n "$curbrs,$"p bak.$fl > tmp.1
	awk '{print $1,$2,$3,NR}' tmp.1 | sort -nrk 4 > tmp.10
	endbrs=`awk -f /usr/people/imbangla/didah/official/fake.awk tmp.10`
	if [ $endbrs -eq 0 ];then
		endbrs=1
	else
		let endbrs=$endbrs+1
	fi	
	sed -n "$endbrs,$"p tmp.10 | sort -nk 4 > tmp.3
	awk '{print $1,$2,$3}' tmp.3 > $fl
	
	#if [ $endbrs -eq 0 ];then
	#	
	#else
	#	cp $fl bak.$fl
	#	let l1=$l1-$endbrs
	#	echo "$curbrs - $l1"
	#	sed -n "$curbrs,$l1"p bak.$fl > $fl
	#fi

done

rm tmp.*

#===========================================================
# menghilangkan data blank pada awal & akhir file
#echo "============================================================"
#echo "menghilangkan series blank pada awal dan akhir file........."
#echo "============================================================"
#for fl in data*.txt
#do
#	l1=`cat $fl | wc -l`
#	curbrs=`awk -f /usr/people/imbangla/didah/official/fakeBlank.awk $fl`
#	endbrs=`cat $fl | sort -nrk 2 | awk -f /usr/people/imbangla/didah/official/fakeBlank.awk`
#	if [[ $curbrs -ne 0 || $endbrs -ne 0 ]];then
#		echo "$fl to baw.$fl"
#		cp $fl baw.$fl
#		echo "$fl" >> $tmpfile
#		if [ $curbrs -eq 0 ];then
#			curbrs=1
#		else
#			let curbrs=$curbrs+1
#		fi
#		let l1=$l1-$endbrs
#		sed -n "$curbrs","$l1"p baw.$fl > $fl	
#	fi
#done
#=======================================================

#eles=('tg' 'tx' 'tn' 'pp' 'hu' 'fg' 'fx')
#echo "============================================================"
#echo "menghilangkan series 0 pada awal dan akhir file........."
#echo "============================================================"
#echo "# ================== series 0" >> $tmpfile
#for ele in ${eles[@]}
#do
#	for fl in data*$ele.txt
#	do
#		if [ ! -e $fl ];then
#			continue
#		fi
#		isfl=`cat $tmpfile | grep $fl | wc -l`
#		if [ $isfl -ne 0 ];then
#			continue
#		fi		
#		l1=`cat $fl | wc -l`
#		curbrs=`awk -f /usr/people/imbangla/didah/official/fake0.awk $fl`
#		endbrs=`cat $fl | sort -nrk 2 | awk -f /usr/people/imbangla/didah/official/fake0.awk`
#		if [[ $curbrs -ne 0 || $endbrs -ne 0 ]];then
#			echo "$fl to bac.$fl"
#			cp $fl bac.$fl
#			echo "$fl" >> $tmpfile
#			if [ $curbrs -eq 0 ];then
#				curbrs=1
#			else
#				let curbrs=$curbrs+1
#			fi
#			let l1=$l1-$endbrs
#			sed -n "$curbrs","$l1"p bac.$fl > $fl	
#		fi
#	done
#done

#mv *.ori $oridir/
echo "all DONE. GOOD JOB."
