// is_minter.cdc

<<<<<<< HEAD
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

pub fun main(minter: Address): Bool? {
    return DAAM_V14.isMinter(minter)
=======
import DAAM_V15 from 0xa4ad5ea5c0bd2fba

pub fun main(minter: Address): Bool? {
    return DAAM_V15.isMinter(minter)
>>>>>>> DAAM_V15
}
// nil = not an minter, false = invited to be an minter, true = is an minter