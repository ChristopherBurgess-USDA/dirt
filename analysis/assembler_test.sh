#SGE_Batch -c "bash assembler_test.sh" -r std_assembler -P 25 -M burgesch@oregonstate.edu

metaspades.py --12 QC_Filtered_Raw_Data/12291.6.250265.TGACTGA-GTCAGTC.filter-METAGENOME.fastq.gz -t 25 -k 27,37,47,57,67,77,87,97,107,117,127 -o spades_test

megahit --12 QC_Filtered_Raw_Data/12291.6.250265.TGACTGA-GTCAGTC.filter-METAGENOME.fastq.gz --presets meta-large -t 25 -o megahit_test --verbose