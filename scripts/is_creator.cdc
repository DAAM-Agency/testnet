// is_creator.cdc

import DAAM_V21 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): Bool? {
    return DAAM_V21.isCreator(creator)
}
// nil = not a creator, false = invited to be a creator, true = is a creator