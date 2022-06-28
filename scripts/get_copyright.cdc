// get_copyright.cdc

import DAAM_V17 from 0xa4ad5ea5c0bd2fba

pub fun main(mid: UInt64): DAAM_V17.CopyrightStatus? {
    return DAAM_V17.getCopyright(mid: mid)
}
// nil = non-existent MID