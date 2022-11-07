// is_minter.cdc

import DAAM_Mainnet from 0xfd43f9148d4b725d

pub fun main(minter: Address): Bool? {
    return DAAM_Mainnet.isMinter(minter)
}
// nil = not an minter, false = invited to be an minter, true = is an minter