for sam in *.sam; do getSameerReport $sam $sam\.fa.anno; mkdir $sam\.dir/; mv Sameer-Res/ $sam\.dir/; done
for dir in *.sam.dir; do rename 's/.sam.dir//g' $dir; done
