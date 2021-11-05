// get_copyright.cdc

import DAAM from 0xfd43f9148d4b725d

pub fun main(mid: UInt64): DAAM.CopyrightStatus? {
    return DAAM.getCopyright(mid: mid)
}
// nil = non-existent MID