#!/bin/bash

read -r -p "Where do the fastq files live? " path

TARGET_DIR=$path
# any file name that includes "_1" is the forward read, any file name that includes "_2" is the reverse read
COUNT_1=$(find "$TARGET_DIR" -maxdepth 1 -name "*_1*" | wc -l)
COUNT_2=$(find "$TARGET_DIR" -maxdepth 1 -name "*_2*" | wc -l)
COMPLETED_COUNT=0
echo "You have selected $path to be the location scanned. There are $COUNT_1 R1 files and $COUNT_2 R2 files."

read -r -p "Do you wish to proceed? y/n " input

if [ "$input" == "n" ]; then 
    echo "Exiting script."
    exit 1
fi

# for every file with the given suffix, assign it to R1 do the following

for R1 in *_1.fastq.gz; do
    # strips off suffix to get sample ID
    print "Processing file: $R1"
    SAMPLE=$(basename "$R1" _1.fastq.gz)
    print "Sample ID: $SAMPLE"
    R2="${SAMPLE}_2.fastq.gz"

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
    echo "Completed $COMPLETED_COUNT of $COUNT_1 samples."  
done
    