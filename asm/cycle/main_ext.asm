//===============================================================================
// Code called from other banks
// Location of this code defined by code_bank in var/global.asm
//===============================================================================

seek(code_bank)

include "common_ext.asm"
include "bank_C0_ext.asm"
include "bank_EE_ext.asm"

log_start("ext code end")