// is_minter.cdc

import DAAM_V21 from 0xa4ad5ea5c0bd2fba

pub fun main(minter: Address): Bool? {
    return DAAM_V21.isMinter(minter)
}
// nil = not an minter, false = invited to be an minter, true = is an minter