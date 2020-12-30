#### HCV pipeline for mapping 
#### Emma Thomson 17/3/18 ALTERED FOR SULTAN'S SINGLE FILES... 19/9/18
#### Uses Sreenu Vattipally's CREATE KMERS and Tanoti programmes
#### Will produce sam alignment files, create consensus sequences and make a fast tree 



echo "HCV mapping pipeline has started...
"
echo "Output files are as follows: 
Input files (genolist)
Genotyping results (.geno)
Closest reference sequence (.newbest)
Alignment files (.sam)
Reference sequence are donwloaded from e-utilities (named by accession number)
Consensus sequence file - allconfile 
Consensus sequences file >90% - Consensus_90.fa)"

gunzip *.gz

ls *fq>r1
less r1 |sed 's/R1/R2/g' >r2
less r1 | sed 's/\.fq//g'>genolist-$$

#Genotyping
#TROUBLESHOOTING Be careful that your reference file is in the correct format and that it is ok for unix - you can fix this with tr -d '\r' <infile >outfile if needed

echo "Genotyping..."
while read file
do
fq1=`echo $file|awk '{print $1}' `;
fq2=`echo $file|awk '{print $2}' `;

CREATE_KMERS-FQ-T -i /home/db/Genomes/Virus/HCV_Refs.fa -1 $fq1.fq -c 1 -p 1 -v >> $fq1.geno
		
done < genolist-$$

echo "Removing dead wood..."
rm -rf  *.f5  *.f2  *.stats *.sorted *.newbest 
echo "Sorting out the best reference..."
for gen in *.geno; do less $gen| cut -f5| sed 's/Genome coverage://g'| grep -v "All kmer matches"| grep -v "Reading"| grep -v "Total"| grep -v "Reference"| grep -v "kmer"| grep -v "Time">$gen\.f5; done

for gen in *.geno; do less $gen| cut -f2| sed 's/Genome coverage://g'| grep -v "All kmer matches"| grep -v "Reading"| grep -v "Total"| grep -v "Reference"| grep -v "kmer"| grep -v "Time">$gen\.f2; done

for gen in *.geno; do paste $gen\.f2 $gen\.f5>$gen\.stats; done

for stats in *.stats; do sort -k2 -n $stats>$stats\.sorted; done

for sorted in *.sorted; do tail -1 $sorted|cut -f1>$sorted\.newbest; done

rename 's/\.geno\.stats\.sorted\.newbest/\.newbest/g' *.newbest

# Pulls out the best genome for mapping
for br in *.newbest; do less $br|sed 's/All kmer matches//g'>>bestgenomes-$$; done
sort bestgenomes-$$| uniq | tr -d '\r' >uniquegenomes-$$

rm -rf a1 b1 uniquegenomes 

# Downloads all genomes for mapping
echo "Downloading reference sequences from ncbi..."

exec < uniquegenomes-$$
while read id
	do
	 wget -O $id https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore\&id=$id\&rettype=fasta\&retmode=text
done

echo "Tanoti pipeline proceeding..."

#Tanoti prep
echo "Preparing tanoti files"
rm -Rf listpre tanlist foo1 foo2 *bad* constats Consensus_95.fasta allconfile samstats
ls *R1*fq>>foo1

paste foo1>listpre
sed -e 's/\.fq//g' listpre >>tanlist-$$

#Tanoti batch run
while read file
do
fq1=`echo $file|awk '{print $1}' `;
fq2=`echo $file|awk '{print $2}' `;
tanoti -i $fq1.fq -r $(less $fq1.newbest) -p 0 -u 0 -o $fq1-$(less $fq1.newbest|tr -d '\r').sam -m 50
done < tanlist-$$



#Sam_stats
echo "Running SAM stats..."

for ST in *.sam; do echo $ST>>samstats-$$; SAM_STATS $ST>>samstats-$$; done
#Sam2consensus
for con in *.sam; do SAM2CONSENSUS -i $con>>allconfile-$$; done
#Consensus files from genomes of minimum 95%
echo "Selecting consensus sequences with >90% coverage..."
ConsensusSorter samstats-$$ allconfile-$$ 90 > Consensus_90.fasta
echo "Aligning consensus sequences..."
cat Consensus_90.fasta /home/db/Genomes/Virus/HCV_Refs.fa>>Consensus_plus_refs.fasta
mafft Consensus_90.fasta > Consensus_90_aligned.fasta
mafft Consensus_plus_refs.fasta > Consensus_plus_refs_aligned.fasta
echo "Building nj tree for quick look - to check for contamination..."
fasttree -nt Consensus_90_aligned.fasta > consensus_tree_$$
fasttree -nt Consensus_plus_refs_aligned.fasta > consensus_plus_refs_tree_$$
clear
echo "Analysis complete. Output is *.sam, samstats, allconfile (all consensus sequences) and Consensus_90.fasta (all consensus sequences with coverage of >90%, an alignment file - Consensus_90_aligned.fasta and a neighbour joining tree file called consensus_tree_no.)"
#figtree consensus_plus_refs_tree_$$

#gzip *fq &

#else
#echo "Error: Input R1 and R2 file number is not equal"; exit

