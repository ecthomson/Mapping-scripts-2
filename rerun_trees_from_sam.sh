#This script reruns a tree from sam files in the same folder
#Emma Thomson October 2019

#Sam_stats
echo "Running SAM stats..."
for ST in *.sam; do echo $ST>>samstats-$$; SAM_STATS $ST>>samstats-$$; done
#Sam2consensus
for con in *.sam; do SAM2CONSENSUS -i $con>>allconfile-$$; done
#Consensus files from genomes of minimum 90%
echo "Selecting consensus sequences with >90% coverage..."
rm -rf Consensus_90.fasta
ConsensusSorter samstats-$$ allconfile-$$ 90 >> Consensus_90.fasta
#Replace the space in the filenames with an underscore so you can see the number of mapped reads
sed -i 's/ /_/g' Consensus_90.fasta
echo "Aligning consensus sequences..."
cat Consensus_90.fasta /home/EV/Acute_HCV_temp/Scripts/refs/HCV_refs_full_genome_oneline.fasta >Consensus_plus_refs.fasta
mafft Consensus_90.fasta > Consensus_90_aligned.fasta
mafft Consensus_plus_refs.fasta > Consensus_plus_refs_aligned.fasta
echo "Building nj tree for quick look - to check for contamination..."
fasttree -nt Consensus_90_aligned.fasta > consensus_tree_$$
fasttree -nt Consensus_plus_refs_aligned.fasta > consensus_plus_refs_tree_$$
rm -rf foo* r1 r2 listpre *f2 *f5
clear
echo "Analysis complete. Output is *.sam, samstats, allconfile (all consensus sequences) and Consensus_90.fasta (all consensus sequences with coverage of >90%, an alignment file - Consensus_90_aligned.fasta and a neighbour joining tree file called consensus_tree_no.)"
echo "Zipping files - hold on for a few minutes..."
#gzip *fastq
echo "All done."
chmod 777 *

#figtree consensus_plus_refs_tree_$$

#else
#echo "Error: Input R1 and R2 file number is not equal"; exit

