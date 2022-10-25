#! /bin/bash
# To run: SGE_Batch -c "bash humann3_call_take3.sh" -r std_humann3_dirt_take3 -P 20 -M burgesch@oregonstate.edu -q makaira


source activate humann3
PERL5LIB=""

reads_path="/dfs/ROOTS/Myrold_Lab/Chris/dirt/filtered/"
save_path="/dfs/ROOTS/Myrold_Lab/Chris/dirt/humann/"

humann \
  --input ${reads_path}NL-07-A_filtered.fastq.gz \
  --output ${save_path} \
  --output-basename NL-07-A \
  --threads 20

humann \
  --input ${reads_path}NI-49-A_filtered.fastq.gz \
  --output ${save_path} \
  --output-basename NI-49-A \
  --threads 20

while read sample_id; do
   humann_renorm_table \
    --input ${sample_id}_genefamilies.tsv \
    --output ${sample_id}_genefamilies_rel.tsv \
    --units relab

    humann_renorm_table \
    --input ${sample_id}_pathabundance.tsv \
    --output ${sample_id}_pathabundance_rel.tsv \
    --units relab

done < sample_id.txt

humann_join_tables \
  --input $save_path \
  --output ${save_path}humann_genefamilies_rel.tsv \
  --file_name genefamilies_rel

humann_join_tables \
  --input $save_path \
  --output ${save_path}humann_pathcoverage.tsv \
  --file_name pathcoverage

humann_join_tables \
  --input $save_path \
  --output ${save_path}humann_pathabundance_rel.tsv \
  --file_name pathabundance_rel

humann_join_tables \
  --input $save_path \
  --output ${save_path}humann_genefamilies.tsv \
  --file_name genefamilies

humann_join_tables \
  --input $save_path \
  --output ${save_path}humann_pathabundance.tsv \
  --file_name pathabundance

source deactivate
