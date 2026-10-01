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
for SHOVILL_OUTPUT in out_IDDLNTM*; do
    ASSEMBLY_ID=${SHOVILL_OUTPUT#out_}
    echo "Processing assembly #: $ASSEMBLY_ID"

    if [[ -f "$SHOVILL_OUTPUT/contigs.fa" ]]; then
        echo "Running bakta on assembly #: $ASSEMBLY_ID"
        # prefix, locus-tag are labels for outputs so because all the contigs files are names the same thing
        bakta --db "$HOME/bakta_db/db-light" \
            --output "bakta_out/$ASSEMBLY_ID" \
            --prefix "$ASSEMBLY_ID" \
            --locus-tag "${ASSEMBLY_ID#IDDLNTM}" \
            --threads 8 \
            "$SHOVILL_OUTPUT/contigs.fa"
        COMPLETED_COUNT=$((COMPLETED_COUNT + 1))
    else 
        echo "WARNING: Can't find the contigs.fa file for $SHOVILL_OUTPUT"
    fi
    echo "Ran bakta on $COMPLETED_COUNT of $COUNT assemblies."
done
    
