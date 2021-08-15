// is_creator.cdc

import DAAM from 0xf8d6e0586b0a20c7

pub fun main(creator: Address): Bool {
    return DAAM.isCreator(creator)
}