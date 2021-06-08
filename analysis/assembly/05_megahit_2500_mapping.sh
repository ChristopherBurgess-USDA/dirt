#! /bin/bash
## To run: SGE_Batch -c "bash 05_megahit_2500_mapping.sh" -r std_test_mapped -P 4 -M burgesch@oregonstate.edu

ref_path="/dfs/ROOTS/Myrold_Lab/Chris/dirt/assembled/"
reads_path="/dfs/ROOTS/Myrold_Lab/Chris/dirt/filtered/"
save_path="/dfs/ROOTS/Myrold_Lab/Chris/dirt/mapped/"
while read sample_id; do
  ref="${ref_path}${sample_id}_"
  reads="${reads_path}${sample_id}_filtered.fastq.gz"
  /home/roots/burgesch/bin/bbmap/reformat.sh in=ref=${ref}contigs.fa out=${ref}contigs_2500.fa minlength=2500 ow=t &> ${ref}_2500_reads_removed.txt
  /home/roots/burgesch/bin/bbmap/bbmap.sh in=$reads ref=${ref}contigs_2500.fa t=4 &> ${save_path}${sample_id}_megahit_2500_output.txt
done < sample_id.txt
