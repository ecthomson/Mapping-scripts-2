#### HCV pipeline for mapping 
#### Emma Thomson 16/12/2019
#### Uses .geno files and produces an input for an R chart

#Remove temp files
rm -rf  *.f5  *.f2  *.stats *.sorted *.newbest* *chart_data

#Description
echo "This script sort out the top 5 genotyping hits and puts them in a file with the name of the file and the results inside"

#Cleaning up the geno file output and extracting the accession details and the %proportion of all unique kmers
#To use coverage rather than proportion, the relevant column can be used instead

for gen in *.geno; do less $gen| cut -f5| sed 's/Genome coverage://g'| grep -v "All kmer matches"| grep -v "Reading"| grep -v "Total"| grep -v "Reference"| grep -v "kmer"| grep -v "Time">$gen\.f5; done
for gen in *.geno; do less $gen| cut -f2| sed 's/Genome coverage://g'| grep -v "All kmer matches"| grep -v "Reading"| grep -v "Total"| grep -v "Reference"| grep -v "kmer"| grep -v "Time">$gen\.f2; done

#Making a summary stats file - .stats
for gen in *.geno; do paste $gen\.f2 $gen\.f5>$gen\.stats; done

#Sorting the stats file by the highest % and removing duplicate entries
for stats in *.stats; do sort -k2 -n $stats | uniq >$stats\.sorted; done

#For the chart - taking the top 5 hits (if more needed, change the tail -5 command)
for sorted in *.sorted; do tail -5 $sorted | tac | cut -f2> $sorted\_chart_data; done
for chart in *chart_data; do rename 's/geno\.stats\.sorted_//g' $chart; done

#Summarising all the data in the folder using paste. The all_chart_data file is the entry file for the R chart
paste *chart_data > all_chart_data

#Remove temp files
rm -rf *f2 *f5

echo "Your data is summarised in the all_chart_data file. Individual results can be found in the *chart_data files."
