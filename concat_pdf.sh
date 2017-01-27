#!/bin/bash

export diffpdf=/cygdrive/c/Users/dvelezs/Downloads/DiffPDF/diffpdf.exe

for t in $(find . -mindepth 1 -maxdepth 1 -type d -o -path ./HCM -prune); do 
	( cd $t && pwd && \

		for d in $(find . -mindepth 1 -maxdepth 1 -type d); do 
			echo $d
			if [ -z ${sed_pattern+x} ] ; then
				export sed_pattern="00000${d:23:6}";
			fi ;
			
			if [ ! -f $d.pdf ]; then 
				pdftk $(find $d -iname '*.pdf' | sort) cat output $d.pdf ;  
			fi ;
		done ;

		if [ ! -f dta.txt ]; then
			echo $sed_pattern
			sed -e "s/$sed_pattern/00000000000/g" $(find */DTA -iname *.txt -type f | sort) > dta.txt ; 
			unset sed_pattern;
		fi ;
	)
done ;

for t in $(find . -mindepth 1 -maxdepth 1 -name 'Nach*' -type d ); do 
	diff -y --suppress-common-lines Vorher/dta.txt $t/dta.txt
done ;

for pdf in Vorher/*.pdf ; do 
	echo $pdf
	$diffpdf $pdf Nachher/${pdf:7:18}*.pdf ; 
done ;
