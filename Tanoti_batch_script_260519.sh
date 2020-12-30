# Tanoti pipeline Emma Thomson MRC CVR May 2019 
# Must have desired .fa files in folder
# Must have desired fastq files in folders

clear
echo "Make sure .fa files are in this folder along with .fastq files to be analysed. Remove everything else. 
The mapping score is set at 50% - if you want to change this, open this file and alter before running.
" 
echo "Warning: Do not proceed unless your fastq and fasta files (*.fa format) are in this folder. ALL FASTA FILES IN THE FOLDER WILL BE RUN.  Remove any other files. Files with bad in the name will be deleted
Warning: R1 file number must equal R2 file number"

echo "Your directory list appears below - please check it.
"












clear
echo "Unzipping files"
gunzip *.gz

# This fix is to make sure R1=R2 and does not appear on earlier versions 
ls *R1*fastq>dn1
less dn1| sed 's/R1/R2/g'>dn2
wc -l dn1 > filenodn1
wc -l dn2 > filenodn2
read fdn1 <filenodn1
read fdn2 <filenodn2
cut -f1 -d " " filenodn1 > num1
cut -f1 -d " " filenodn2 > num2
read n1<num1
read n2<num2
echo "R1 files" $n1 "R2 files" $n2  



	echo "Pipeline proceeding"
#Tanoti prep
echo "Preparing tanoti files"
rm -Rf listpre tanlist foo1 foo2 *bad* constats Consensus_95.fasta allconfile samstats
ls *R1*fastq>foo1
less foo1| sed 's/R1/R2/g' >foo2

paste foo1 foo2>listpre
sed 's/\.fastq//g' listpre >tanlist-$$

#Tanoti batch run
while read file
do
fq1=`echo $file|awk '{print $1}' `;
fq2=`echo $file|awk '{print $2}' `;
        for ref in *.fa
        do
                tanoti -i $fq1.fastq $fq2.fastq -r $ref -p 1 -u 0 -o $fq1-$ref.sam -m 50
        done
done < tanlist-$$



#Sam_stats
echo "Running SAM stats..."
for ST in *.sam; do echo $ST>>samstats; SAM_STATS $ST>>samstats; done
#Sam2consensus
for con in *.sam; do SAM2CONSENSUS -i $con>>allconfile; done
for con in *.sam; do SAM2CONSENSUS -i $con>>$con\_consensus\.fa; done
#Consensus files from genomes of minimum 95%
echo "Selecting consensus sequences with >90% coverage..."
ConsensusSorter samstats allconfile 90 >> Consensus_90.fasta
#Removes bad text from output file
sed -i 's/Cannot open output\. Sending the output to STDOUT//g' Consensus*.fasta

echo "Aligning consensus sequences..."
# You can release the lines below by deleting the # if you want to look at a phylogenetic tree (and there are only related viruses in the folder)
#cat Consensus_90.fasta *.fa>>Consensus_plus_refs.fasta
#mafft Consensus_90.fasta > Consensus_90_aligned.fasta
#mafft Consensus_plus_refs.fasta > Consensus_plus_refs_aligned.fasta
#echo "Building nj tree for quick look - to check for contamination..." 
#fasttree -nt Consensus_90_aligned.fasta > consensus_tree_$$
#fasttree -nt Consensus_plus_refs_aligned.fasta > consensus_plus_refs_tree_$$
chmod 777 *
chmod 777 ../*
clear
echo "Analysis complete. Output is *.sam, samstats, allconfile (all consensus sequences) and Consensus_90.fasta (all consensus sequences with coverage of >90%"

