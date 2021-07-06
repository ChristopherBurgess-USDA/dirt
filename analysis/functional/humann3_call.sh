#! /bin/bash
# To run: SGE_Batch -c "bash humann3_call.sh" -r std_humann3_dirt -P 20 -M burgesch@oregonstate.edu -q makaira


source activate humann3
PERL5LIB=""

reads_path="/dfs/ROOTS/Myrold_Lab/Chris/dirt/filtered/"
save_path="/dfs/ROOTS/Myrold_Lab/Chris/dirt/humann/"

while read sample_id; do

  humann \
    --input ${reads_path}${sample_id}_filtered.fastq.gz \
    --output ${save_path} \
    --output-basename ${sample_id} \
    --threads 20

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
  --output humann_genefamilies_rel.tsv \
  --file_name genefamilies_rel

humann_join_tables \
  --input $save_path \
  --output humann_pathcoverage.tsv \
  --file_name pathcoverage

humann_join_tables \
  --input $save_path \
  --output humann_pathabundance.tsv \
  --file_name pathabundance_rel

source deactivate
