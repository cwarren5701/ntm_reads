#!/bin/bash

read -p "Where do the fastq files live? " path

TARGET_DIR=$path
COUNT_R1=$(find "$TARGET_DIR" -maxdepth 1 -name "R1*" | wc -l)
COUNT_R2=$(find "$TARGET_DIR" -maxdepth 1 -name "R2*" | wc -l)
COMPLETED_COUNT=0
echo "You have selected $path to be the location scanned. There are $COUNT_R1 R1 files and $COUNT_R2 R2 files."

read -p "Do you wish to proceed? y/n how " input

if [ "$input" == "n" ]; then 
    echo "Exiting script."
    exit 1
fi

# for every file with the given suffix, assign it to R1 do the following
for R1 in *_R1.fastq.gz; do
    # strips off suffix to get sample ID
    SAMPLE=$(basename "$R1" _R1.fastq.gz)
    R2="${SAMPLE}_R2.fastq.gz"

    # if R2 is a file...
    if [[ -f "$R2" ]]; then 
        echo "Running Shovill on $SAMPLE..."
        shovill --trim --assembler skesa \
            --outdir "out_${SAMPLE}" \
            --R1 "$R1" --R2 "$R2" \
            --cpus 8
    else
        echo "WARNING: No matching R2 found for $R1, skipping."
    fi      
    COMPLETED_COUNT=$((COMPLETED_COUNT + 1))
    echo "Completed $COMPLETED_COUNT of $COUNT_R1 samples."  
done
    