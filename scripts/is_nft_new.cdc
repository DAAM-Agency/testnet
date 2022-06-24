// is_nft_new.cdc

<<<<<<< HEAD
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

pub fun main(tokenID: UInt64): Bool {
    return DAAM_V14.isNFTNew(id: tokenID)
=======
import DAAM_V15 from 0xa4ad5ea5c0bd2fba

pub fun main(tokenID: UInt64): Bool {
    return DAAM_V15.isNFTNew(id: tokenID)
>>>>>>> DAAM_V15
}