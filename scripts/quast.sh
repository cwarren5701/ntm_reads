#!/bin/bash

TARGET_DIR=$(pwd)
COUNT=$(find "$TARGET_DIR" -maxdepth 1 -name "out_IDDLNTM*" | wc -l)

echo "You have selected $TARGET_DIR to be the location scanned. There are $COUNT shovill output folders there."
read -r -p "Do you wish to proceed? y/n " input

if [ "$input" == "n" ]; then
    echo "Exiting script."
    exit 1
fi

cd "$TARGET_DIR" || { echo "Failed to change directory to $TARGET_DIR"; exit 1; }

COMPLETED_COUNT=0
# for each Shovill output folder...
for SHOVILL_OUTPUT in out_IDDLNTM*; do
    # removes the shortest match of 'out_IDDLNTM' from the start of the string
    ASSEMBLY_NUM=${SHOVILL_OUTPUT#out_IDDLNTM}
    print "Processing assembly #: $ASSEMBLY_NUM)"

    # grab the contigs.fa file and run quast on it
    if [[ -f "$SHOVILL_OUTPUT/contigs.fa" ]]; then
        echo "Running Shovill on assembly #: $ASSEMBLY_NUM"
        quast.py "$SHOVILL_OUTPUT/contigs.fa"
    else
        echo "WARNING: Can't find the contigs.fa file for $SHOVILL_OUTPUT"
    fi
    COMPLETED_COUNT=$((COMPLETED_COUNT + 1))
    echo "Ran quast on $COMPLETED_COUNT of $COUNT assemblies."
done
