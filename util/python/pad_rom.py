#!/usr/bin/env python3

import os
import sys
import romtools as rt

MAX_SIZE = 0x400000

if __name__ == "__main__":
    try:
        rom_path = sys.argv[1]
        current_size = os.path.getsize(rom_path)
        if current_size < MAX_SIZE:
            pad_size = MAX_SIZE - current_size
            print(f"Padding ROM: Adding {rt.hex_string(pad_size)} bytes")
            rom_file = open(rom_path, 'ab')
            rom_file.write(b'\x00' * pad_size)
            rom_file.close()
    except Exception as e:
        print(f"Error padding ROM: {e}")
        sys.exit(1)