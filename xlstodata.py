#!/usr/bin/python

import xlrd
import sys
from calendar import monthrange

infile = sys.argv[1]
kode = sys.argv[2]

fixtahun= 3 # 4:bulan 1-31:tanggal
fixrow= 0
workbook = xlrd.open_workbook(infile)
worksheets = workbook.sheet_names()
  
for wsname in worksheets:
	tmp="+ %s : diproses (tg,tx,tn,rr,ss,pp,hu,fg,dd,wx,quit) : " % wsname
	ele = raw_input(tmp)
	if ele=='quit':
		break
	if ele=='':
		continue
	ws = workbook.sheet_by_name(wsname)
	#print ws.nrows
	i=0
	faktor=1
	fid = open("data.%s.%s.txt" % (kode,ele),'w')
	while True:
		i=i+1;
		if i>ws.nrows-1:
			break		
		cellthn = int(ws.cell_value(fixrow+i,fixtahun))
		cellbln = int(ws.cell_value(fixrow+i,fixtahun+1))		
		if i==1:
			cellvalue = ws.cell_value(fixrow+i,fixtahun+2)
			faktor = raw_input("%s - faktor : " % cellvalue)
			faktor = float(faktor)			
		#print cellthn,cellbln
		ranges = monthrange(cellthn, cellbln)[1]
		for tgl in range(1,ranges+1):
			try:
				celltype = ws.cell_type(fixrow+i,fixtahun)
				if celltype==0:
					cellvalue=-9999
				elif ele=='rr' or ele=='dd' or ele=='fg' or ele=='fx' or ele=='hu':
					cellvalue = int(ws.cell_value(fixrow+i,fixtahun+1+tgl))
				else:	
					cellvalue = float(ws.cell_value(fixrow+i,fixtahun+1+tgl))
			except:
				cellvalue = -9999
				print "error : ",ele,cellthn,cellbln,tgl,cellvalue
				#sys.exit(1)
			
						
			if cellvalue!=-9999:
				cellvalue=cellvalue*faktor
			
			print cellthn,cellbln,tgl,cellvalue
			if ele=='rr' or ele=='dd' or ele=='fg' or ele=='fx' or ele=='hu':
				fid.write("%s %s-%s-%s %d\n" % (kode,cellthn,cellbln,tgl,cellvalue))
			else:
				fid.write("%s %s-%s-%s %.1f\n" % (kode,cellthn,cellbln,tgl,cellvalue))			
		#cellbln = ws.cell_value(currow,col+bln)
	fid.close()
