// is_creator.cdc

import DAAM_Mainnet from 0xfd43f9148d4b725d

pub fun main(creator: Address): Bool? {
    return DAAM_Mainnet.isCreator(creator)
}
// nil = not a creator, false = invited to be a creator, true = is a creator