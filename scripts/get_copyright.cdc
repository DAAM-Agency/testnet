// get_copyright.cdc

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

pub fun main(mid: UInt64): DAAM_Mainnet.CopyrightStatus? {
    return DAAM_Mainnet.getCopyright(mid: mid)
}
// nil = non-existent MID