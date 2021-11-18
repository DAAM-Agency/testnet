// is_minter.cdc

import DAAM from 0xfd43f9148d4b725d

pub fun main(minter: Address): Bool? {
    return DAAM.isMinter(minter)
}