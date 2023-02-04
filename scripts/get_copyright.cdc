// get_copyright.cdc

import DAAM from 0x7db4d10c78bad30a

pub fun main(mid: UInt64): DAAM.CopyrightStatus? {
    return DAAM.getCopyright(mid: mid)
}
// nil = non-existent MID