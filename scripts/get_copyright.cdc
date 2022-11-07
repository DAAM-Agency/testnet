// get_copyright.cdc

import DAAM_Mainnet from 0xfd43f9148d4b725d

pub fun main(mid: UInt64): DAAM_Mainnet.CopyrightStatus? {
    return DAAM_Mainnet.getCopyright(mid: mid)
}
// nil = non-existent MID