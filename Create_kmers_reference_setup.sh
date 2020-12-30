#This bash script will rename all the fasta file names in a reference file to allow you to run CREATE-KMERS
#WARNING - you need to create a new folder with ONLY the accession numbers file and this script in it. Otherwise anything could happen...
#Emma Thomson July 2019

clear
echo "Welcome to the CREATE-KMERS reference file set up script"
echo "WARNING - you need to create a new folder with ONLY the accession numbers file and this script in it before running. Otherwise anything could happen..."
ls
echo -n "
Enter the name of your accession file if you are happy to proceed from the list above
$"


read accessionfile

echo -n "
Enter the name of your virus and the segment if relevant. 
$ "
read reffile
#Downloads reference files by accession number
#BUG NOTE- remember that sometimes Windows can corrupt files - you need to cut and paste using gedit in Linux

exec < $accessionfile
while read id
    do
     wget -O $id https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore\&id=$id\&rettype=fasta\&retmode=text
done 


#Renames the accession files
rename 's/$/\.fa/g' *
rename 's/\.sh\.fa/\.sh/g' *
mv $accessionfile\.fa $accessionfile

#This renames the header wuth the accession number 
for i in *.fa; do sed -i "1s/.*/>${i%.fa}/" $i; done
cat *.fa > fa1
cp fa1 $reffile\_phylo_refs.fa

#Creating a file called fa1names that has all the old names
grep ">" fa1 | sed 's/ /_/g' | sed 's/\t/_/g'> fa1names

#Count the number of sequences in the reference file
grep ">" fa1| wc -l >refcount
read count < refcount
echo "There are " $count "sequences in your file."

#Creating a file called fa2names that has the new names
#For CREATE-KMERS, the names need to be in the format 1|a|AY_3257789 i.e. genotype, subgenotype, accession

seq 1 $count > fa2names
sed -i 's/^/>/g' fa2names
sed -i 's/$/|a|/g' fa2names

#Replacing the names

##paste fa1names fa2names | while read n k; do sed -i "s/$n/$k/g" fa1 > $reffile\_ck_refs.fa; done
paste fa2names fa1names | sed 's/>//g'| sed 's/\t\>//g'| sed 's/\t//g'| sed 's/^/\>/g'>fa3names

paste fa1names fa3names | while read n k; do sed -i "s/$n/$k/g" fa1; done
mv fa1 $reffile\_ck_refs.fa
clear

echo "Your sequence names have been replaced as follows:
"
paste fa1names fa3names

#Releasing permissions
chmod 777 *
echo "Your output files are " $reffile\_ck_refs.fa "and " $reffile\_phylo_refs.fa

#Tidying
rm -rf refcount fa*name* 


#rm -rf fa1 fa2
#for name in *.fa; do mv $name "$(head -1 $name|sed 's/>//g'| sed 's/ /_/g'| sed 's/\?//g' | sed 's/,//g'| sed 's/complete_genome//g'|sed 's/partial_genome//g'|sed 's/partial_sequence//g' | sed 's/complete_cds//g' | sed 's/partial_cds//g'| sed 's/complete_sequence//g' | sed 's/$/\.fa/g'| sed 's/_\./\./g')"; done
