for st in *.sam ; do echo $st>>list-$$; SAM_STATS $st>>list-$$; grep -B 1 "Coverage" list-$$ > finalres-$$; done
