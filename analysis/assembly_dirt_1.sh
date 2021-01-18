# TO Run: SGE_Batch -c "bash assembly_dirt_1.sh" -r std_assembly_dirt_1 -P 20 -M burgesch@oregonstate.edu

## BIN BASH DOESN'T WORK WITH MEGAHIT INSTALL FOR SOME REASON
megahit --12 ../filtered/CO-08-A_filtered.fastq.gz --presets meta-large --min-contig-len 1000 -o ../assembled/CO-08-A; mv ../assembled/CO-08-A/final.contigs.fa ../assembled/CO-08-A_contigs.fa
megahit --12 ../filtered/CO-08-B_filtered.fastq.gz --presets meta-large --min-contig-len 1000 -o ../assembled/CO-08-B; mv ../assembled/CO-08-B/final.contigs.fa ../assembled/CO-08-B_contigs.fa
megahit --12 ../filtered/CO-12-A_filtered.fastq.gz --presets meta-large --min-contig-len 1000 -o ../assembled/CO-12-A; mv ../assembled/CO-12-A/final.contigs.fa ../assembled/CO-12-A_contigs.fa
megahit --12 ../filtered/CO-12-B_filtered.fastq.gz --presets meta-large --min-contig-len 1000 -o ../assembled/CO-12-B; mv ../assembled/CO-12-B/final.contigs.fa ../assembled/CO-12-B_contigs.fa
megahit --12 ../filtered/CO-14-A_filtered.fastq.gz --presets meta-large --min-contig-len 1000 -o ../assembled/CO-14-A; mv ../assembled/CO-14-A/final.contigs.fa ../assembled/CO-14-A_contigs.fa
megahit --12 ../filtered/CO-14-B_filtered.fastq.gz --presets meta-large --min-contig-len 1000 -o ../assembled/CO-14-B; mv ../assembled/CO-14-B/final.contigs.fa ../assembled/CO-14-B_contigs.fa
megahit --12 ../filtered/DL-02-B_filtered.fastq.gz --presets meta-large --min-contig-len 1000 -o ../assembled/DL-02-B; mv ../assembled/DL-02-B/final.contigs.fa ../assembled/DL-02-B_contigs.fa
megahit --12 ../filtered/DL-13-A_filtered.fastq.gz --presets meta-large --min-contig-len 1000 -o ../assembled/DL-13-A; mv ../assembled/DL-13-A/final.contigs.fa ../assembled/DL-13-A_contigs.fa
megahit --12 ../filtered/DL-13-B_filtered.fastq.gz --presets meta-large --min-contig-len 1000 -o ../assembled/DL-13-B; mv ../assembled/DL-13-B/final.contigs.fa ../assembled/DL-13-B_contigs.fa