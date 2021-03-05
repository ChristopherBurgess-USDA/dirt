#! /bin/bash
## To run: SGE_Batch -c "bash assembly_mapped.sh" -r std_test_mapped -P 4 -M burgesch@oregonstate.edu


ref="/dfs/ROOTS/Myrold_Lab/Chris/dirt/assembled/DW-10-A_contigs.fa"
reads="/dfs/ROOTS/Myrold_Lab/Chris/dirt/filtered/DW-10-A_filtered.fastq.gz"

save="/dfs/ROOTS/Myrold_Lab/Chris/dirt/mapped/test/DW-10-A/"

/home/roots/burgesch/bin/bbmap/bbmap.sh in=$reads ref=$ref bhist=${save}bhist.txt qhist=${save}qhist.txt aqhist=${save}aqhist.txt lhist=${save}lhist.txt ihist=${save}ihist.txt ehist=${save}ehist.txt qahist=${save}qahist.txt indelhist=${save}indelhist.txt mhist=${save}mhist.txt gchist=${save}gchist.txt idhist=${save}idhist.txt scafstats=${save}scafstats.txt out=${save}mapped.sam t=4