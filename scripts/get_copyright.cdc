// get_copyright.cdc

import DAAM_V14 from 0xa4ad5ea5c0bd2fba

pub fun main(mid: UInt64): DAAM_V14.CopyrightStatus? {
    return DAAM_V14.getCopyright(mid: mid)
}
// nil = non-existent MID