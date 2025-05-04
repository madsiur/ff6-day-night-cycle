#!/bin/bash

# Build script

# Set hack name and timestamp
HACK_NAME="day_night_cycle_nh"
TEMP_NAME="transition"
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
MAX_SIZE=$((0x400000))

# find the first .smc or .sfc file in the vanilla directory
ORIGINAL_ROM=$(find vanilla -maxdepth 1 -type f \( -iname "*.smc" -o -iname "*.sfc" \) | head -n 1)

# validate ROM was found
if [[ -z "$ORIGINAL_ROM" ]]; then
    echo "Error: No .smc or .sfc ROM file found in the vanilla directory"
    exit 1
fi

TEMP_ROM="rom/${TEMP_NAME}.smc"
HACKED_ROM="rom/${HACK_NAME}.smc"
PATCH_NAME="rom/${HACK_NAME}_${TIMESTAMP}.ips"

cp "$ORIGINAL_ROM" "$TEMP_ROM"

# get current ROM size
ROM_SIZE=$(stat -c%s "$TEMP_ROM")

# check if it's smaller than 4MB and pad if so
if (( ROM_SIZE < MAX_SIZE )); then
    PAD_SIZE=$((MAX_SIZE - ROM_SIZE))
    echo "Padding ROM: adding $PAD_SIZE bytes"
    dd if=/dev/zero bs=1 count="$PAD_SIZE" >> "$TEMP_ROM" status=none
fi

cp "$TEMP_ROM" "$HACKED_ROM"

# apply bass hack
util/bass -o "$HACKED_ROM" asm/main.asm
if [[ $? -ne 0 ]]; then
    echo "Error: assembling with bass failed"
    exit 1
fi

# create IPS patch
util/flips --create --ips "$TEMP_ROM" "$HACKED_ROM" "$PATCH_NAME" > /dev/null
if [[ $? -ne 0 ]]; then
    echo "Error: patch creation with flips failed"
    exit 1
fi

# delete temp ROM
if [[ -f "$TEMP_ROM" ]]; then
    rm "$TEMP_ROM"
fi

echo "ROM $HACKED_ROM successfully created!"
echo "IPS patch $PATCH_NAME successfully created!"