// is_creator.cdc

<<<<<<< HEAD
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): Bool? {
    return DAAM_V14.isCreator(creator)
=======
import DAAM_V15 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): Bool? {
    return DAAM_V15.isCreator(creator)
>>>>>>> DAAM_V15
}
// nil = not a creator, false = invited to be a creator, true = is a creator