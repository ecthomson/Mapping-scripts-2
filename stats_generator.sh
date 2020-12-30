#Stats for coverage - best and second best by proportion and by coverage of sam files
#Emma Thomson October 2019

for gen in *.geno; do less $gen| cut -f3| sed 's/Genome coverage://g'| grep -v "All kmer matches"| grep -v "Reading"| grep -v "Total"| grep -v "Reference"| grep -v "kmer"| grep -v "Time">$gen\.f3; done
for gen in *.geno; do paste $gen\.f2 $gen\.f3 $gen\.f5>$gen\.fullstats; done
for stats in *.fullstats; do sort -k2 -n $stats>$stats\.sorted; done
rename 's/fullstats\.sorted/fullstats_prop\.sorted/g' **.sorted
for stats in *.fullstats; do sort -k3 -n $stats>$stats\.sorted; done
rename 's/fullstats\.sorted/fullstats_coverage\.sorted/g' **.sorted
rm -rf coverage_stats_1 prop_stats_1
for tail in *coverage.sorted; do tail -1 $tail >>coverage_stats_1; done
for tail in *prop.sorted; do tail -1 $tail >>prop_stats_1; done
rm -rf coverage_stats_2
for tail in *coverage.sorted; do cat $tail |uniq | sort |tail -n2| head -n1 >>coverage_stats_2; done
rm -rf prop_stats_2
for tail in *prop.sorted; do cat $tail |uniq | sort |tail -n2| head -n1 >>prop_stats_2; done

