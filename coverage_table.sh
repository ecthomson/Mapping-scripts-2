#Script for creating a table at the end of the tanoti pipeline for coverage plot figures using R
#Input is samstats file e.g. samstats_orf-95132
#Emma Thomson 15th August 2019

cut -f 3,5 samstats | sed 's/Coverage://g'| sed 's/Total reads://g'| sed 's/\%//g'|grep -v "Sorry Ref Genome size is shorter" > tab
grep "sam" tab > fn1
grep -v "sam" tab > tab1
paste fn1 tab1 > coverage_tab
rm -rf tab tab1 fn1 
