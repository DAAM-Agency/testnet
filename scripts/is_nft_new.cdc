// is_nft_new.cdc

<<<<<<< HEAD
import DAAM_V5from 0xa4ad5ea5c0bd2fba
=======
import DAAM_V5 from 0xa4ad5ea5c0bd2fba
>>>>>>> merge_dev

pub fun main(tokenID: UInt64): Bool {
    return DAAM_V5.isNFTNew(id: tokenID)
}