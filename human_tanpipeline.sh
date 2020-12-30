# Tanoti pipeline Emma Thomson MRC CVR August 2016 
# Must have desired .fa files in folder

#clear
#echo "Make sure .fa files are in this folder along with .fastq files to be analysed. Remove everything else. 
#The mapping score is set at 50% - if you want to change this, open this file and alter before running.
#" 
#echo "Warning: Do not proceed unless your fastq and fasta files (*.fa format) are in this folder. ALL FASTA FILES IN THE FOLDER WILL BE RUN.  Remove any other files. Files with bad in the name will be deleted
#"
#echo "Your directory list appears below - please check it.
#"
#ls
## Check that you want to proceed if setup is ok
#while true; do
#    read -p "
#Have you put the run.sh, fa files and fastq files in this folder? Please answer yes or no - type either y or n and return: " yn
#    case $yn in
#        [Yy]* ) break;;
#        [Nn]* ) exit;;
#        * ) echo "Please answer yes or no.";;
#    esac
#done
gunzip -f *fastq.gz
clear
#Tanoti prep
echo "Preparing tanoti files"
rm -Rf listpre tanlist foo1 foo2 *bad* constats Consensus_95.fasta allconfile samstats
ls *R1*fastq>foo1
less foo1|sed 's/R1/R2/g' >foo2

paste foo1 foo2>listpre
sed -e 's/\.fastq//g' listpre >>tanlist-$$

#Tanoti batch run
while read file
do
fq1=`echo $file|awk '{print $1}' `;
fq2=`echo $file|awk '{print $2}' `;
        for ref in *.fas
        do
                tanoti -i $fq1.fastq $fq2.fastq -r $ref -p 1 -u 0 -o $fq1-$ref.sam -m 90
        done
done < tanlist-$$



Sam_stats
echo "Running SAM stats..."
for ST in *mtDNA*.sam; do echo $ST>>human_samstats-$$; SAM_STATS $ST>>human_samstats-$$; done
#Sam2consensus
for con in *mtDNA*.sam; do SAM2CONSENSUS -i $con>>human_allconfile-$$; done
#Consensus files from genomes of minimum 95%
ConsensusSorter human_samstats-$$ human_allconfile-$$ 60 >> Consensus_60_human.fasta
sed -i 's/Cannot open output\. Sending the output to STDOUT//g' Consensus_60_human.fasta

#Remove the Ns and the ns
sed 's/n//g' Consensus_60_human.fasta | sed 's/N//g' > Consensus_60_human.fasta_clean

#Remove the text breaks using awk
for one in *_clean; do cat $one | awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}'>$one\.oneline; done

#Align
mafft Consensus_60_human_clean.oneline > Consensus_60_human_aligned.fasta
#Tree
fasttree -nt Consensus_60_human_aligned.fasta > human.tree
clear
echo "Analysis complete. Output is *.sam, samstats, allconfile (all consensus sequences) and Consensus_60.fasta (all consensus sequences with coverage of >60% and a tree called human.tree)"


