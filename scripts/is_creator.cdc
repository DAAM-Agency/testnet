// is_creator.cdc

import DAAM_V7 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): Bool? {
    return DAAM_V7.isCreator(creator)
}
