#!/bin/bash
#
# Author: Daniel Velez Schrod - dvelezs (a) gmail (dot) com - 03.2014
#
# Decrypt and unprotect all PDF files in the current directory
#  All document securities (including "Commenting") should be set to be allowed
#  The command qpdf --decrypt input.pdf output.pdf removes the 'owner' password. 
#  But it does only work, if there is no 'user' password set.
#
# The following commands give out the detailed security settings of the file(s):
#  qpdf --show-encryption input.pdf
#  qpdf --show-encryption output.pdf
#
# Requirements: pdftk & qpdf

for f in *.pdf; do
  qpdf --decrypt $f .${f%%.*}_dec.pdf ; 
  pdftk .${f%%.*}_dec.pdf output ${f%%.*}_dec.pdf allow AllFeatures ;  
done
