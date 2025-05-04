# Spreadsheets

`data.ods` is a Libre Office spreadsheet that can edits data for the hack and export bin files to `asm/data`. The `maps` sheet will produce `map_enable.bin` and `map_freeze.bin`. The `backgrounds` sheet will produce `bg_enable.bin` and `bg_palette.bin`. Finally the `events` sheet will produce `events.bin`.

You just need to change values and click "Export data" in the sheet you edited. For anyone wanting to unprotect a sheet, all three sheets are protected with the password "`ff6`". Note that the columns between the table and the export button a hidden and protected, this is where the macros take the binary values.

The macros used are made in Libre Office Basic. They are included in the file `macros.bas`.