// is_creator.cdc

import DAAM_V11 from 0xfd43f9148d4b725d

pub fun main(creator: Address): Bool? {
    return DAAM_V11.isCreator(creator)
}
// nil = not a creator, false = invited to be a creator, true = is a creator