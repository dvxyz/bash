#!/bin/bash

date

export diffpdf=/cygdrive/c/Users/dvelezs/Downloads/DiffPDF/diffpdf.exe
export blank=../blank20.pdf

for t in $(find . -mindepth 1 -maxdepth 1 -type d -o -path ./HCM -prune); do 
	( cd $t && pwd && \

		for d in $(find . -mindepth 1 -maxdepth 1 -type d); do 

			echo $d
			
			if [ -z ${sed_pattern+x} ] ; then
				export sed_pattern="00000${d:23:6}";
			fi ;
			
			if [ ! -f $d.pdf ]; then 
			
				rm -f $d/*/last/*.pdf
				
				for pdf in $(find $d -maxdepth 2 -iname '*.pdf') ; do
				
					mkdir -p $(dirname ${pdf})/last
					
					num_pages=$(pdftk $pdf dump_data |  grep NumberOfPages | tr -d $'\r' | cut -d ' ' -f 2 )

					if [ ! -f $(dirname ${pdf})/last/$(basename ${pdf}) ]; then 
						if [ $num_pages -ge 20 ] ; then
							num_pages=20
							pdftk ${pdf} cat r${num_pages}-end output $(dirname ${pdf})/last/$(basename ${pdf});
						else
							blank_pages=$(expr 20 - ${num_pages})
							# pdftk A=${blank} B=${pdf} cat A1-${blank_pages} B=r$(expr ${num_pages})-end output $(dirname ${pdf})/last/$(basename ${pdf});
							pdftk A=${pdf} B=${blank} cat Br${blank_pages}-end Ar${num_pages}-end output $(dirname ${pdf})/last/$(basename ${pdf});
						fi ;
					fi ;
					
				done

				pdftk $(find $d/*/last -iname '*.pdf' | sort) cat output $d.pdf ;  
			fi ;
			
		done ;
		
		if [ ! -f dta.txt ]; then
			echo $sed_pattern
			sed -e "s/$sed_pattern/00000000000/g" $(find */DTA -iname *.txt -type f | sort) > dta.txt ; 
			unset sed_pattern;
		fi ;
	)
done ;

echo ">>> Diff DTA..."

for t in $(find . -mindepth 1 -maxdepth 1 -name 'Nach*' -type d ); do 
	diff -y --suppress-common-lines Vorher/dta.txt $t/dta.txt
done ;

echo ">>> PDF Diff"
for pdf in Vorher/*.pdf ; do 
	echo " -> $pdf vs Nachher/${pdf:7:18}*.pdf"
	$diffpdf $pdf Nachher/${pdf:7:18}*.pdf ; 
done ; 
