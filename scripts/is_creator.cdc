// is_creator.cdc

import DAAM from 0xfd43f9148d4b725d

pub fun main(creator: Address): Bool? {
    return DAAM.isCreator(creator)
}