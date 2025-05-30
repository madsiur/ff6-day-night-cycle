import argparse
import sys
import shutil
from pathlib import Path
from struct import *

# credit to m06 for the checksum calculation code:
# https://github.com/mogue/SNES-SRM-Checksum-Fix/blob/master/FF6_SRM_checksum_fix.py

def modify_save_file(src_path, dst_path, timer_offset, timer_value, flags_offset, flags_value):
    timer_offset = timer_offset - 0x1600
    flags_offset = flags_offset - 0x1600
    checksum_offset = 0x9FE
    timer_bytes = timer_value.to_bytes(2, byteorder='little')

    # Read the original save file
    with open(src_path, 'rb') as f:
        srm = bytearray(f.read())
    
    for i in range(3):
        srm_pos = i * 0xA00

        # write timer and flag values  
        srm[srm_pos+timer_offset:srm_pos+timer_offset+2] = timer_bytes
        srm[srm_pos+flags_offset] = flags_value

        # calculate new checksum
        checksum = 0
        data = srm[srm_pos:srm_pos+checksum_offset]
        for b in data:
            checksum += unpack('i', bytes([b]) + b'\x00\x00\x00')[0]
        
        # write new checksum
        srm[srm_pos+checksum_offset] = checksum & 0xFF
        srm[srm_pos+checksum_offset+1] = (checksum >> 8) & 0xFF    
        print(f"Checksum for save slot {i + 1}: 0x{checksum & 0xFFFF:04X}")

    with open(dst_path, 'wb') as f:
        f.write(srm)
        print(f"Created {dst_path}")



def parse_word(value):
    ivalue = int(value, 0)
    if not (0 <= ivalue <= 0xFFFF):
        raise argparse.ArgumentTypeError(f"Word must be in range 0x0000 to 0xFFFF (got {value})")
    return ivalue

def parse_byte(value):
    ivalue = int(value, 0)
    if not (0 <= ivalue <= 0xFF):
        raise argparse.ArgumentTypeError(f"Byte must be in range 0x00 to 0xFF (got {value})")
    return ivalue

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Modify FF3us save files by writing the 2-byte timer value and the 1-byte initial flags value.")
    parser.add_argument("timer_offset", type=parse_word, help="Offset for timer in SRAM (e.g. 0x1E3D)")
    parser.add_argument("timer_value", type=parse_word, help="Timer value to write (e.g. 0x0E00)")
    parser.add_argument("flags_offset", type=parse_word, help="Offset for flags in SRAM (e.g. 0x1E3F)")
    parser.add_argument("flags_value", type=parse_byte, help="Flags value to write (e.g. 0x88)")
    args = parser.parse_args()

    src_dir = "vanilla"
    dst_dir = "generated"

    src_dir_path = Path(src_dir)
    dst_dir_path = Path(dst_dir)

    if not src_dir_path.exists():
        print(f"Error: Source dir not found: {src_dir}")
        sys.exit(1)

    if dst_dir_path.exists():
        shutil.rmtree(dst_dir_path)
    dst_dir_path.mkdir(parents=True)

    for src_path in src_dir_path.iterdir():
        if src_path.is_file():
            dst_path = dst_dir_path / src_path.name
            modify_save_file(src_path, dst_path, args.timer_offset, args.timer_value, args.flags_offset, args.flags_value)
