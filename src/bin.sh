#!/bin/bash

# Set the temporary directory
TMP_DIR="${TMPDIR:-/tmp}"
[ -z "$TMP_DIR" ] && TMP_DIR="/tmp/"

# Get the script directory
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DATA_DIR="$DIR/" 
CENTROMERES="$DIR/"

# Check if the data directory exists
[ ! -d "$DATA_DIR" ] && echo "Error: Data directory not found." && exit 1

cd "$DATA_DIR"

# Index BAM files only if the index file does not exist
for file in *.bam; do
    if [ ! -f "$file.bai" ]; then
        samtools index "$file"
    fi
done

# Specify input sample and output paths
SAMPLE="$1"
OUTPUT="$2"

# Set the region size
SIZE=1000000

for ((i = 1; i < 23; i++)); do
    CHR="chr$i"

    # Get the last position for the current chromosome from the centromeres file
    LAST=$(awk -v chr="$CHR" '$1 == chr {last = $3} END {print last}' "$DATA_DIR")

    for ((begin = 0; begin <= LAST; begin += SIZE)); do
        end=$((begin + SIZE))
        CENT=$(awk -v chr="$CHR" -v begin="$begin" -v end="$end" 'BEGIN {bad=0} $1 == chr && $2 < end && $3 > begin {bad=1} END {print bad}' "$CENTROMERES")

        # Skip the region if it overlaps with a centromere
        if ((CENT == 1)); then
            continue
        fi

        echo "$CHR $begin $end"

        # Extract data from BAM files in the region and pass it to the Rust program
        for file in *.bam; do
            [ -f "$file" ] && samtools view "$file" "$CHR:$begin-$end" | awk '{print $9}'
        done
    done | cargo run --manifest-path="$DIR/../Cargo.toml" /dev/stdin "$TMP_DIR/__bins_$$"
done >"$TMP_DIR/__bins_$$"

"$DIR/../target/debug/bamtool" "$TMP_DIR/__bins_$$" "$OUTPUT" 2>/dev/null

# Clean up the temporary file
rm "$TMP_DIR/__bins_$$"
