#! /bin/bash
## To run: SGE_Batch -c "bash 01_metaspades_mapping.sh" -r std_metaspades_mapped -P 4 -M burgesch@oregonstate.edu

ref_path="/dfs/ROOTS/Myrold_Lab/Chris/dirt/raw/"
reads_path="/dfs/ROOTS/Myrold_Lab/Chris/dirt/filtered/"
save_path="/dfs/ROOTS/Myrold_Lab/Chris/dirt/mapped/"
while read sample_id; do
  ref="${ref_path}${sample_id}/QC_and_Genome_Assembly/"
  reads="${reads_path}${sample_id}_filtered.fastq.gz"
  /home/roots/burgesch/bin/bbmap/reformat.sh in=${ref}final.contigs.fasta out=${ref}contigs_1k.fa minlength=1000 ow=t &> ${ref}_reads_removed.txt
  /home/roots/burgesch/bin/bbmap/bbmap.sh in=$reads ref=${ref}contigs_1k.fa scafstats=${save_path}${sample_id}_metaspades_scafstats.txt out=${save_path}${sample_id}_metaspades.bam t=4 &> ${save_path}${sample_id}_metaspades_output.txt
done < sample_id.txt