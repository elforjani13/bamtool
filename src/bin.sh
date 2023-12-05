#!/bin/bash

TMP_DIR="${TMPDIR:-/tmp}"
[ -z "$TMP_DIR" ] && TMP_DIR="/tmp/"



DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
DATA_DIR="$DIR/../[DIR]/[FILE]" #


[ ! -d "$DATA_DIR" ] && echo "Error: Data directory not found." && exit 1


SAMPLE="$1"
OUTPUT="$2"

SIZE=1000000

for (( i=1; i<23; i++ )); do
    CHR="chr$i"
    LAST=$(awk -v chr="$CHR" '$1 == chr {last = $3} END {print last}' "$DATA_DIR")

    for (( begin=0; begin<=LAST; begin+=SIZE )); do
        end=$(( begin+SIZE ))
        CENT=$(awk -v chr="$CHR" -v begin="$begin" -v end="$end" 'BEGIN {bad=0} $1 == chr && $2 < end && $3 > begin {bad=1} END {print bad}' "$CENTROMERES")

        if (( CENT == 1 )); then
            continue
        fi

        echo "$CHR $begin $end"

        for file in "$SAMPLE"/*.bam; do
            samtools view "$file" "$CHR:$begin-$end" | awk '{print $9}'
        done | "$DIR/../target/debug/main" /dev/stdin "$TMP_DIR/__bins_$$"
    done
done > "$TMP_DIR/__bins_$$"

"$DIR/../target/debug/main" "$TMP_DIR/__bins_$$" "$OUTPUT"
rm "$TMP_DIR/__bins_$$"
