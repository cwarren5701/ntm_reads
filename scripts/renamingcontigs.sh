#!/bin/bash

TARGET_DIR=$(pwd)
COUNT=$(find "$TARGET_DIR" -maxdepth 1 -name "out_IDDLNTM*" | wc -l)

echo "You have selected $TARGET_DIR to be the location scanned. There are $COUNT shovill output folders there."
read -r -p "Do you wish to proceed? y/n " input

read -r -p "What would you like the name of output folder to be? " new_dir
mkdir "$new_dir"

if [ "$input" == "n" ]; then
    echo "Exiting script"
    exit 1
fi

cd "$TARGET_DIR" || { echo "Failed to change directory to $TARGET_DIR"; exit 1; }

COMPLETED_COUNT=0
for SHOVILL_OUTPUT in out_IDDLNTM*; do
    ASSEMBLY_ID=${SHOVILL_OUTPUT#out_}
    echo "Copying and renaming assembly #: $ASSEMBLY_ID"

    if [[ -f "$SHOVILL_OUTPUT/contigs.fa" ]]; then
        echo cp "$SHOVILL_OUTPUT.contigs.fa" "$new_dir/$ASSEMBLY_ID.fa"
        COMPLETED_COUNT=$((COMPLETED_COUNT +1))
    fi
    echo "Copied and renamed $COMPLETED_COUNT of $COUNT contig.fa files."
done
