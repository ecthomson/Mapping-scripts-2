##Renaming fasta file of reference sequences for CREATE KMERS
##Emma Thomson July 2019

#Count the number of fasta files




for name in *.fa; do mv $name "$(head -1 $name|sed 's/>//g'| sed 's/ /_/g'| sed 's/\?//g' | sed 's/,//g'| sed 's/complete_genome//g'|sed 's/partial_genome//g'|sed 's/partial_sequence//g' | sed 's/complete_cds//g' | sed 's/partial_cds//g'| sed 's/complete_sequence//g' | sed 's/$/\.fa/g'| sed 's/_\./\./g')"; done
