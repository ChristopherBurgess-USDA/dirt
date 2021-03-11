#! /bin/bash
## To run: SGE_Batch -c "bash assembly_mapped.sh" -r std_test_mapped -P 4 -M burgesch@oregonstate.edu

ref_path="/dfs/ROOTS/Myrold_Lab/Chris/dirt/assembled/"
reads_path="/dfs/ROOTS/Myrold_Lab/Chris/dirt/filtered/"
save_path="/dfs/ROOTS/Myrold_Lab/Chris/dirt/mapped/"
while read sample_id; do
  ref="${ref_path}${sample_id}_contigs.fa"
  reads="${reads_path}${sample_id}_filtered.fastq.gz"
  /home/roots/burgesch/bin/bbmap/bbmap.sh in=$reads ref=$ref scafstats=${save}${sample_id}_scafstats.txt out=${save}${sample_id}.bam t=4 &> ${save}${sample_id}_output.txt
done < sample_id.txt
