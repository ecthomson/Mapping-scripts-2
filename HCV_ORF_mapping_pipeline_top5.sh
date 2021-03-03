g### HCV pipeline for mapping top 5 genotypes
#### Emma Thomson 16/12/2019 and updated 21/02/2021 with new reference file locations
#### Uses Sreenu Vattipally's CREATE KMERS and Tanoti programmes
#### Will produce sam alignment files, create consensus sequences and make a fast tree 
#### This version runs tanoti against the top 5 Create kmers hits

echo "HCV mapping pipeline has started - includes reference sequences from the top 5 genotyping hits...
"
echo "Output files are as follows: 
Input files (genolist)
Genotyping results (.geno)
Closest reference sequence (.newbest1, newbest2 and newbest3)
Alignment files (.sam)
Reference sequence are donwloaded from e-utilities (named by accession number)
Consensus sequence file - allconfile 
Consensus sequences file >90% - Consensus_90.fa)"

#gunzip *fastq.gz

ls *R1*fastq>r1
sed 's/R1/R2/g' r1 >r2
paste r1 r2|sed 's/.fastq//g'>genolist-$$

#Genotyping
#TROUBLESHOOTING Be careful that your reference file is in the correct format and that it is ok for unix - you can fix this with tr -d '\r' <infile >outfile if needed

echo "Genotyping..."
while read file
do
fq1=`echo $file|awk '{print $1}' `;
fq2=`echo $file|awk '{print $2}' `;

##CHANGE TO THE 7 HERE
CREATE_KMERS-FQ-T -i /home2/HCV2/Uganda/Scripts/Mapping-scripts-2/HCV_Refs_ORF_full_oneline.fasta -1 $fq1.fastq -2 $fq2.fastq  -c 1 -p 1 -v >> $fq1.geno
		
done < genolist-$$

echo "Removing dead wood..."
rm -rf  *.f5  *.f2  *.stats *.sorted *.newbest 
echo "Sorting out the best reference..."
for gen in *.geno; do less $gen| cut -f5| sed 's/Genome coverage://g'| grep -v "All kmer matches"| grep -v "Reading"| grep -v "Total"| grep -v "Reference"| grep -v "kmer"| grep -v "Time">$gen\.f5; done

for gen in *.geno; do less $gen| cut -f2| sed 's/Genome coverage://g'| grep -v "All kmer matches"| grep -v "Reading"| grep -v "Total"| grep -v "Reference"| grep -v "kmer"| grep -v "Time">$gen\.f2; done

for gen in *.geno; do paste $gen\.f2 $gen\.f5>$gen\.stats; done

for stats in *.stats; do sort -k2 -n $stats | uniq >$stats\.sorted; done

#This bit pulls out the top 5 hits
for sorted in *.sorted; do tail -1 $sorted|cut -f1>$sorted\.newbest1; done
for sorted in *.sorted; do tail -2 $sorted|head -1 |cut -f1>$sorted\.newbest2; done
for sorted in *.sorted; do tail -3 $sorted|head -1 |cut -f1>$sorted\.newbest3; done
for sorted in *.sorted; do tail -4 $sorted|head -1 |cut -f1>$sorted\.newbest4; done
for sorted in *.sorted; do tail -5 $sorted|head -1 |cut -f1>$sorted\.newbest5; done


rename 's/\.geno\.stats\.sorted\.newbest1/\.newbest1/g' *.newbest1
rename 's/\.geno\.stats\.sorted\.newbest2/\.newbest2/g' *.newbest2
rename 's/\.geno\.stats\.sorted\.newbest3/\.newbest3/g' *.newbest3
rename 's/\.geno\.stats\.sorted\.newbest4/\.newbest4/g' *.newbest4
rename 's/\.geno\.stats\.sorted\.newbest5/\.newbest5/g' *.newbest5

# Pulls out the best genome for mapping
for br in *.newbest*; do less $br|sed 's/All kmer matches//g'>>bestgenomes-$$; done
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
ls *R1*fastq>>foo1
less foo1| sed 's/R1/R2/g' >>foo2

paste foo1 foo2>>listpre
sed -e 's/\.fastq//g' listpre >>tanlist-$$

#Tanoti batch run
while read file
do
fq1=`echo $file|awk '{print $1}' `;
fq2=`echo $file|awk '{print $2}' `;
tanoti -i $fq1.fastq $fq2.fastq -r  /home2/HCV2/Uganda/Scripts/Mapping-scripts-2/ORF_refs/$(less $fq1.newbest1).fa -p 1 -u 0 -o $fq1-$(less $fq1.newbest1|tr -d '\r').sam -m 50
tanoti -i $fq1.fastq $fq2.fastq -r /home2/HCV2/Uganda/Scripts/Mapping-scripts-2/ORF_refs/$(less $fq1.newbest2).fa -p 1 -u 0 -o $fq1-$(less $fq1.newbest2|tr -d '\r').sam -m 50
tanoti -i $fq1.fastq $fq2.fastq -r /home2/HCV2/Uganda/Scripts/Mapping-scripts-2/ORF_refs/$(less $fq1.newbest3).fa -p 1 -u 0 -o $fq1-$(less $fq1.newbest3|tr -d '\r').sam -m 50
tanoti -i $fq1.fastq $fq2.fastq -r /home2/HCV2/Uganda/Scripts/Mapping-scripts-2/ORF_refs/$(less $fq1.newbest4).fa -p 1 -u 0 -o $fq1-$(less $fq1.newbest4|tr -d '\r').sam -m 50
done < tanlist-$$
tanoti -i $fq1.fastq $fq2.fastq -r /home2/HCV2/Uganda/Scripts/Mapping-scripts-2/ORF_refs/$(less $fq1.newbest5).fa -p 1 -u 0 -o $fq1-$(less $fq1.newbest5|tr -d '\r').sam -m 50
< tanlist-$$


#Sam_stats
#echo "Running SAM stats..."

for ST in *.sam; do echo $ST>>samstats-$$; SAM_STATS $ST>>samstats-$$; done
#Sam2consensus
for con in *.sam; do SAM2CONSENSUS -i $con>>allconfile-$$; done
#Consensus files from genomes of minimum 95%
#echo "Selecting consensus sequences with >90% coverage..."
ConsensusSorter samstats-$$ allconfile-$$ 90 >> Consensus_90.fasta
#echo "Aligning consensus sequences..."
sed -i 's/Cannot open output\. Sending the output to STDOUT//g' Consensus*.fasta
cat Consensus_90.fasta /home2/HCV2/Uganda/Scripts/HCV_Refs_ORF_full_oneline.fasta >>Consensus_plus_refs.fasta
mafft Consensus_90.fasta > Consensus_90_aligned.fasta
mafft Consensus_plus_refs.fasta > Consensus_plus_refs_aligned.fasta
echo "Building nj tree for quick look - to check for contamination..."
fasttree -nt Consensus_90_aligned.fasta > consensus_tree_$$
fasttree -nt Consensus_plus_refs_aligned.fasta > consensus_plus_refs_tree_$$
chmod 777 *
#clear
#echo "Analysis complete. Output is *.sam, samstats, allconfile (all consensus sequences) and Consensus_90.fasta (all consensus sequences with coverage of >90%, an alignment file - Consensus_90_aligned.fasta and a neighbour joining tree file called consensus_tree_no.)"
#figtree consensus_plus_refs_tree_$$

#gzip *fastq &

#else
echo "Error: Input R1 and R2 file number is not equal"; exit

