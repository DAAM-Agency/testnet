// get_copyright.cdc

import DAAM_V5from 0xa4ad5ea5c0bd2fba

pub fun main(mid: UInt64): DAAM.CopyrightStatus? {
    return DAAM.getCopyright(mid: mid)
}
// nil = non-existent MID