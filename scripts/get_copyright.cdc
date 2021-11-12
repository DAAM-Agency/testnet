// get_copyright.cdc

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

pub fun main(mid: UInt64): DAAM_V5.CopyrightStatus? {
    return DAAM_V5.getCopyright(mid: mid)
}
// nil = non-existent MID