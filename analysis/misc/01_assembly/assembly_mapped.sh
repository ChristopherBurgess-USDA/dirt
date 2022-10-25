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


/home/roots/burgesch/bin/bbmap/bbmap.sh in="/dfs/ROOTS/Myrold_Lab/Chris/dirt/filtered/NR-06-A_filtered.fastq.gz" ref="/dfs/ROOTS/Myrold_Lab/Chris/dirt/assembled/NR-06-A_contigs.fa" scafstats="/dfs/ROOTS/Myrold_Lab/Chris/dirt/mapped/NR-06-A_scafstats.txt" out="/dfs/ROOTS/Myrold_Lab/Chris/dirt/mapped/NR-06-A.bam" t=4 &> "/dfs/ROOTS/Myrold_Lab/Chris/dirt/mapped/NR-06-A_output.txt"