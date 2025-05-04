#!/bin/bash

HACK_NAME="day_night_cycle_nh"
TEMP_NAME="temp"

# find the first .smc or .sfc file in the vanilla directory
ORIGINAL_ROM=$(find vanilla -maxdepth 1 -type f \( -iname "*.smc" -o -iname "*.sfc" \) | head -n 1)

# validate that a ROM was found
if [[ -z "$ORIGINAL_ROM" ]]; then
    echo "Error: No .smc or .sfc ROM file found in the vanilla directory"
    exit 1
fi

TEMP_ROM="rom/${TEMP_NAME}.smc"
HACKED_ROM="rom/${HACK_NAME}.smc"
PATCH_NAME="rom/${HACK_NAME}" 
PATCH_NAME_IPS="${PATCH_NAME}.ips"
PATCH_NAME_BPS="${PATCH_NAME}.bps"

cp "$ORIGINAL_ROM" "$TEMP_ROM"

# pad ROM to 32 Mbit if smaller
python util/python/pad_rom.py "$TEMP_ROM"

cp "$TEMP_ROM" "$HACKED_ROM"

# apply bass hack
util/bass -o "$HACKED_ROM" asm/main.asm
if [[ $? -ne 0 ]]; then
    echo "Error: assembling with bass failed"
    exit 1
fi

echo "ROM $HACKED_ROM successfully created!"

# fix SNES checksum
python util/python/fix_checksum.py "$HACKED_ROM"

# create IPS patch
util/flips --create --ips "$TEMP_ROM" "$HACKED_ROM" "$PATCH_NAME_IPS" > /dev/null
if [[ $? -ne 0 ]]; then
    echo "Error: IPS patch creation with flips failed"
    exit 1
fi

echo "IPS patch $PATCH_NAME_IPS successfully created!"

# create BPS patch
util/flips --create --bps "$TEMP_ROM" "$HACKED_ROM" "$PATCH_NAME_BPS" > /dev/null
if [[ $? -ne 0 ]]; then
    echo "Error: BPS patch creation with flips failed"
    exit 1
fi

echo "BPS patch $PATCH_NAME_BPS successfully created!"

# delete temp ROM
if [[ -f "$TEMP_ROM" ]]; then
    rm "$TEMP_ROM"
fi




