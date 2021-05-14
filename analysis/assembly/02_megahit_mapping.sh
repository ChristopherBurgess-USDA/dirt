#! /bin/bash
## To run: SGE_Batch -c "bash assembly_mapped.sh" -r std_test_mapped -P 4 -M burgesch@oregonstate.edu

ref_path="/dfs/ROOTS/Myrold_Lab/Chris/dirt/assembled/"
reads_path="/dfs/ROOTS/Myrold_Lab/Chris/dirt/filtered/"
save_path="/dfs/ROOTS/Myrold_Lab/Chris/dirt/mapped/"
while read sample_id; do
  ref="${ref_path}${sample_id}_contigs.fa"
  reads="${reads_path}${sample_id}_filtered.fastq.gz"
  /home/roots/burgesch/bin/bbmap/bbmap.sh in=$reads ref=$ref scafstats=${save_path}${sample_id}_megahit_scafstats.txt out=${save_path}${sample_id}_megahit.bam t=4 &> ${save_path}${sample_id}_megahit_output.txt
done < sample_id.txt
