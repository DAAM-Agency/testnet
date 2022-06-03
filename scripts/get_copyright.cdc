// get_copyright.cdc

import DAAM_V11 from 0xfd43f9148d4b725d

pub fun main(mid: UInt64): DAAM_V11.CopyrightStatus? {
    return DAAM_V11.getCopyright(mid: mid)
}
// nil = non-existent MID