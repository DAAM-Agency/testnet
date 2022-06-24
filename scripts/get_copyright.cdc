// get_copyright.cdc

import DAAM_V15 from 0xa4ad5ea5c0bd2fba

pub fun main(mid: UInt64): DAAM_V15.CopyrightStatus? {
    return DAAM_V15.getCopyright(mid: mid)
}
// nil = non-existent MID