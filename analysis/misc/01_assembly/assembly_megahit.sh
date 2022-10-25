#! /bin/bash
# To run  qsub -t 1-33:1  -r std_batch_assembly -P 20 -m 20G 
## SGE_Array -c array_dirt_megahit_assembly.txt -P 20 -m 10G -b 5 --qsub_options='-m be -M burgesch@oregonstate.edu'
#$ -N batch_assembly
#$ -t 1-33:1
#$ -tc 5
#$ -M burgesch@oregonstate.edu
#$ -m ea

job_id=$(head -n $SGE_TASK_ID file_of_files | tail -n 1)
megahit --12 ../filtered/${job_id}.fastq.gz --presets meta-large -o ../assembled/${job_id}

mv ../assembled/${job_id}/final.contigs.fa ../assembled/complete/${job_id}_contigs.fa