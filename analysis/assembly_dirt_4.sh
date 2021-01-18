# TO Run: SGE_Batch -c "bash assembly_dirt_4.sh" -r std_assembly_dirt_4 -P 20 -M burgesch@oregonstate.edu
## bin bash thing doesn't work with thsi for some reason
megahit --12 ../filtered/NL-07-B_filtered.fastq.gz --presets meta-large --min-contig-len 1000 -o ../assembled/NL-07-B; mv ../assembled/NL-07-B/final.contigs.fa ../assembled/NL-07-B_contigs.fa
megahit --12 ../filtered/NL-11-A_filtered.fastq.gz --presets meta-large --min-contig-len 1000 -o ../assembled/NL-11-A; mv ../assembled/NL-11-A/final.contigs.fa ../assembled/NL-11-A_contigs.fa
megahit --12 ../filtered/NL-11-B_filtered.fastq.gz --presets meta-large --min-contig-len 1000 -o ../assembled/NL-11-B; mv ../assembled/NL-11-B/final.contigs.fa ../assembled/NL-11-B_contigs.fa
megahit --12 ../filtered/NR-01-A_filtered.fastq.gz --presets meta-large --min-contig-len 1000 -o ../assembled/NR-01-A; mv ../assembled/NR-01-A/final.contigs.fa ../assembled/NR-01-A_contigs.fa
megahit --12 ../filtered/NR-01-B_filtered.fastq.gz --presets meta-large --min-contig-len 1000 -o ../assembled/NR-01-B; mv ../assembled/NR-01-B/final.contigs.fa ../assembled/NR-01-B_contigs.fa
megahit --12 ../filtered/NR-04-A_filtered.fastq.gz --presets meta-large --min-contig-len 1000 -o ../assembled/NR-04-A; mv ../assembled/NR-04-A/final.contigs.fa ../assembled/NR-04-A_contigs.fa
megahit --12 ../filtered/NR-04-B_filtered.fastq.gz --presets meta-large --min-contig-len 1000 -o ../assembled/NR-04-B; mv ../assembled/NR-04-B/final.contigs.fa ../assembled/NR-04-B_contigs.fa
megahit --12 ../filtered/NR-06-A_filtered.fastq.gz --presets meta-large --min-contig-len 1000 -o ../assembled/NR-06-A; mv ../assembled/NR-06-A/final.contigs.fa ../assembled/NR-06-A_contigs.fa
megahit --12 ../filtered/NR-06-B_filtered.fastq.gz --presets meta-large --min-contig-len 1000 -o ../assembled/NR-06-B; mv ../assembled/NR-06-B/final.contigs.fa ../assembled/NR-06-B_contigs.fa