// is_minter.cdc

import DAAM_V6 from 0xa4ad5ea5c0bd2fba

pub fun main(minter: Address): Bool? {
    return DAAM_V6.isMinter(minter)
}