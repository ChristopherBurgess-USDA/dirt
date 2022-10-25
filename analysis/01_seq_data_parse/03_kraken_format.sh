#! /bin/bash
read_path="/home/tunasteak/box/projects/dirt/data/kraken/"
sample_path="/home/tunasteak/box/projects/dirt/data/sample_id.txt"

while read sample_id; do
    python kreport2mpa.py \
        -r "${read_path}${sample_id}_bracken.txt" \
        -o "${read_path}${sample_id}_meta.txt" \
        --display-header \
        --no-intermediate-ranks
    python kreport2krona.py \
        -r "${read_path}${sample_id}_bracken.txt" \
        -o "${read_path}${sample_id}.krona" \
        --no-intermediate-ranks
done < ${sample_path}
