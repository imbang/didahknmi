#!/usr/bin/python
# -*- coding: utf-8 -*-

#===================================
# input : parid keyfile indir outdir
# created by Bayu Imbang Laksono,12 feb 2013 @KNMI
# 1. read all files inside indir
# 2. lookup in keyfile (get staid,seriesid,eleid)
# 3. create file certain staid,ele,value*10 / -9999
#===================================
import sys
import os
import MySQLdb as mdb

def is_number(cellvalue):
    try:
        float (cellvalue)
        return True
    except ValueError:
        return False

#keydata={10:{'hu'=,'pp'=,},}
ref_ele={'rr':10,'hu':6,'pp':35,'tg':36,'tx':16,'tn':14,'fg':4,'dd':3,'fx':5,'ss':34}
keydata={}
outdir=''

def lookupToSQL(nmfile,wmo,ele):
  global outdir,keydata,parid,ref_ele
  key = keydata[wmo]
  outfile = nmfile.replace('txt','sql')
  outfile = outfile.split('/')[-1]
  fullfile = os.path.join(outdir,outfile)
  fd = open(fullfile,'w')
  fid = open(nmfile,'r')
  ferr = open('insert_sacad.err','a')
  print "+ Processing %s" % (nmfile)
  i=0
  while True:
    rd = fid.readline()
    dt = rd.split()
    if len(dt)<=1:
      break
    sta = dt[0];wkt = dt[1];
  
    if len(dt)==2:
	value='-9999'
    else:
    	value = dt[2]
    
    #if ele=='dd':
      
    if (value=='NULL' or is_number(value)==False):
      print " ++ blank/not numeric value",wmo,ele,wkt
      value = -9999
      #print wmo,ele,wkt,value,len(value)
    else:
      value = float(value)
      
    if (value!=-9999 and (ele=='tg' or ele=='tn' or ele=='tx' or ele=='rr' or ele=='ss' or ele=='pp' or ele=='fg' or ele=='wx')):
      value = int(value*10)
    else:
      value = int(value)
      
    if (value>5000 and ele=='rr'):
      print " ++ rr > 500",wmo,ele,wkt,value
      tmp="%s,%s,%s,%s,%.1f,%s\n" % (wmo,key[ele],ele,wkt,value/10.0,key['nama'])
      ferr.write(tmp)
      # ===== ubah disini kalo nilai-nya akan dipertahankan
      #value=-9999
      # ===================================================
    elif (value>360 and ele=='dd'):
      print " ++ dd > 360",wmo,ele,wkt,value
      #value=-9999
      tmp="%s,%s,%s,%s,%d,%s\n" % (wmo,key[ele],ele,wkt,value,key['nama'])
      ferr.write(tmp)
    elif (value>500 and (ele=='tg' or ele=='tn' or ele=='tx')):
      print " ++ tn,tg,tx > 50",wmo,ele,wkt,value
      tmp="%s,%s,%s,%s,%.1f,%s\n" % (wmo,key[ele],ele,wkt,value/10.0,key['nama'])
      ferr.write(tmp)
    elif (value>11000 and ele=='pp'):
      print " ++ pp > 1100",wmo,ele,wkt,value
      tmp="%s,%s,%s,%s,%.1f,%s\n" % (wmo,key[ele],ele,wkt,value/10.0,key['nama'])
      ferr.write(tmp)
    elif (value>1000 and ele=='ss'):
      print " ++ ss > 100",wmo,ele,wkt,value
      tmp="%s,%s,%s,%s,%.1f,%s\n" % (wmo,key[ele],ele,wkt,value/10.0,key['nama'])
      ferr.write(tmp)
      
    if i==0:
	#cek ser_id existing
	con = None

	try:
		con = mdb.connect('bwdb04', 'diddba', 'QhL40K', 'didah');
		cur = con.cursor()
		cur.execute("select count(*) from series where ser_id=%s" % key[ele])
		data = int(cur.fetchone()[0])
    		#print "jumlah data : %d " % data
		if data==0:
			tmp="insert into series(ser_id,ele_id,sta_id,par_id,perm_id) values(%s,%d,%s,%s,1);\n" % (key[ele],ref_ele[ele],key['staid'],parid)
			fd.write(tmp)
			i=i+1
    	except mdb.Error, e:
		print "Error %d: %s" % (e.args[0],e.args[1])
		return 0,fullfile
    	finally:
		if con:    
			con.close()
	
    if i>0:
	tmp="insert into series_%s(ser_id,ser_date,%s,qc,qcm,qca) values(%s,'%s',%d,-9,-9,-9);\n" % (ele,ele,key[ele],wkt,value)
	fd.write(tmp)
    
  ferr.close()
  fid.close()
  fd.close()
  return 1,fullfile

def run(direktori):
  for root,dirs,files in os.walk(direktori):
        if len(files)>0:
            for i in range(len(files)):
                nmfile=files[i]
		tmp = nmfile.split('.')
		if len(tmp)==0:
			continue
		if tmp[0]=='data':
			wmo = tmp[1].strip()
			ele = tmp[2].strip()
			print "+++++++++++++++++++++",wmo,os.path.join(root,nmfile),dirs
                	lookupToSQL(os.path.join(root,nmfile),wmo,ele)

def readKeyFile(nmfile):
  global keydata
  wmo=0;nama=1
  staid=2;rr=4;hu=5;pp=6;ss=7
  tg=8;tx=9;tn=10;fg=11;dd=12;fx=13
  #print "Reading key file : ",nmfile
  fid=open(nmfile,'r')
  hd = fid.readline().split('\t')
  while True:
    tmp={}
    line = fid.readline()
    line = line.split('\t')
    if len(line)<=1:
      break
    wmocode = line[wmo].strip()
    tmp['staid'] = line[staid].strip();
    if tmp['staid']=='':
      print wmocode,"sta_id tidak ditemukan."
      sys.exit(1)
      
    tmp['nama'] = line[nama].strip();
    tmp['rr'] = line[rr].strip();tmp['hu'] = line[hu].strip();tmp['pp'] = line[pp].strip()
    tmp['ss'] = line[ss].strip()
    tmp['tg'] = line[tg].strip();tmp['tx'] = line[tx].strip();tmp['tn'] = line[tn].strip()
    tmp['fg'] = line[fg].strip();tmp['dd'] = line[dd].strip();tmp['fx'] = line[fx].strip()
    keydata[wmocode] = tmp
    del tmp
  fid.close()

if __name__ == '__main__':
  
  if len(sys.argv)<4:
    print "Cara pakai:"
    print "      insert_sacad.py <PAR_ID> <KEY_FILE> <IN_FILE> <OUT_DIR>\n"
    sys.exit()

  parid=sys.argv[1]
  keyfile=sys.argv[2]
  infile=sys.argv[3]
  outdir=sys.argv[4]
  
  if not os.path.exists(outdir):
    os.makedirs(outdir)

  readKeyFile(keyfile)
  #print keydata
  #print "Processing file : ",infile


  tmp = os.path.basename(infile) 
  tmp = tmp.split('.')
  wmo = tmp[1].strip()
  ele = tmp[2].strip()
  [status,nmfl] = lookupToSQL(infile,wmo,ele)
  if status==0:
	os.remove(nmfl)
