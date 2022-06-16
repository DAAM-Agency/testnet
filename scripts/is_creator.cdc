// is_creator.cdc

<<<<<<< HEAD
import DAAM_V10 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): Bool? {
    return DAAM_V10.isCreator(creator)
=======
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): Bool? {
    return DAAM_V14.isCreator(creator)
>>>>>>> DAAM_V14
}
// nil = not a creator, false = invited to be a creator, true = is a creator