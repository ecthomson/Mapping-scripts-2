

#Script for creating a table at the end of the tanoti pipeline for coverage plot figures using R
#Input is samstats file e.g. samstats_orf-95132
#Emma Thomson and James Shepherd 5th September 2019

#Copy the Rscript coverage_mapped_reads.R into the same folder
#cp /home2/HCV2/Uganda/Scripts/coverage_mapped_reads.R .

for stats in *samstats

do cat $stats | sed '$!N;/Coverage/P;D'| cut -f 3,5 | sed 's/Coverage://g'| sed 's/Total reads://g'| sed 's/\%//g'> tab_$stats

grep "sam" tab_$stats | cut -f 1 -d "_"> fn1_$stats

grep -v "sam" tab_$stats > tab1_$stats

#The above script only pulls out the sam files that have a positive readout (and contain "Coverage") in the following line. To get the negatives, the script reads the input file backwards using tac (catrev haha) x 2

tac $stats| sed '/Coverage/I,+1 d'| tac | grep sam | cut -f 1 -d "_" | sed 's/$/\t 0 \t 0/g' > neg_$stats

#Makes the full table
paste fn1_$stats tab1_$stats >pos_$stats 

cat pos_$stats neg_$stats | sort -k 2n > $stats.table

#This is the R script bit (file MUST be in the folder)
Rscript coverage_mapped_reads_96.R $stats.table

rm -rf tab_$stats fn1_$stats tab1_$stats neg_$stats pos_$stats

echo "Data analysis complete. Sample statistics are found in the coverage_table file and in the corresponding pdf"
done



